import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'initialize_default_database.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Recipes, Ingredients, RecipeIngredients, RecipeSteps, Units],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      beforeOpen: (details) async {
        await initializeDefaultDatabase(this);
      },
    );
  }

  // --- Unit Queries ---
  Future<List<Unit>> getAllUnits() => select(units).get();
  Future<int> insertUnit(UnitsCompanion unit) => into(units).insert(unit);

  // --- Recipe Queries ---
  Future<List<Recipe>> getAllRecipes() => select(recipes).get();
  Stream<List<Recipe>> watchAllRecipes() => select(recipes).watch();
  Future<int> insertRecipe(RecipesCompanion recipe) =>
      into(recipes).insert(recipe);
  Future<bool> updateRecipe(Recipe recipe) => update(recipes).replace(recipe);
  Future<int> deleteRecipe(Recipe recipe) => delete(recipes).delete(recipe);

  // --- Ingredient Queries ---
  Future<List<Ingredient>> getAllIngredients() => select(ingredients).get();
  Stream<List<Ingredient>> watchAllIngredients() => select(ingredients).watch();
  Future<int> insertIngredient(IngredientsCompanion ingredient) =>
      into(ingredients).insert(ingredient);
  Future<bool> updateIngredient(Ingredient ingredient) =>
      update(ingredients).replace(ingredient);
  Future<int> deleteIngredient(Ingredient ingredient) =>
      delete(ingredients).delete(ingredient);

  Stream<List<Ingredient>> searchIngredients(String query) {
    if (query.isEmpty) return Stream.value([]);
    
    // split query into words and filter out small connectors like "de", "el", "y"
    final terms = query.toLowerCase().split(' ')
        .where((term) => term.length > 2)
        .toList();
    
    if (terms.isEmpty) {
      // if all words were filtered, fallback to simple contains with the original query
      return (select(ingredients)
            ..where((t) => t.name.contains(query.trim()))
            ..limit(5))
          .watch();
    }

    return (select(ingredients)
          ..where((t) {
            // match if the name contains ANY of the significant terms
            final expressions = terms.map((term) => t.name.contains(term)).toList();
            return expressions.reduce((a, b) => a | b);
          })
          ..limit(10)) // increased limit for related results
        .watch();
  }

  // --- Relationship Queries ---
  Future<List<RecipeIngredient>> getIngredientsForRecipe(String recipePk) {
    return (select(
      recipeIngredients,
    )..where((t) => t.recipeFk.equals(recipePk))).get();
  }

  // --- Complex Queries ---
  Future<void> mergeIngredients(
    Ingredient oldIngredient,
    Ingredient newIngredient,
  ) async {
    await transaction(() async {
      // 1. update recipeingredients
      final recipeIngredientsToUpdate = await (select(recipeIngredients)
            ..where((t) => t.ingredientFk.equals(oldIngredient.ingredientPk)))
          .get();

      for (final entry in recipeIngredientsToUpdate) {
        final existingNewEntry = await (select(recipeIngredients)
              ..where((t) => t.recipeFk.equals(entry.recipeFk))
              ..where((t) => t.ingredientFk.equals(newIngredient.ingredientPk)))
            .getSingleOrNull();

        if (existingNewEntry != null) {
          await (update(recipeIngredients)
                ..where(
                  (t) => t.recipeIngredientPk.equals(
                    existingNewEntry.recipeIngredientPk,
                  ),
                ))
              .write(
            RecipeIngredientsCompanion(
              amountNeeded:
                  Value(existingNewEntry.amountNeeded + entry.amountNeeded),
            ),
          );
          await (delete(recipeIngredients)
                ..where(
                  (t) => t.recipeIngredientPk.equals(entry.recipeIngredientPk),
                ))
              .go();
        } else {
          await (update(recipeIngredients)
                ..where(
                  (t) => t.recipeIngredientPk.equals(entry.recipeIngredientPk),
                ))
              .write(
            RecipeIngredientsCompanion(
              ingredientFk: Value(newIngredient.ingredientPk),
            ),
          );
        }
      }

      // 2. update recipesteps instructions
      final oldTag = '[${oldIngredient.name}]';
      final newTag = '[${newIngredient.name}]';

      await customStatement(
        'UPDATE recipe_steps SET instruction = REPLACE(instruction, ?, ?)',
        [oldTag, newTag],
      );

      // 3. delete the old ingredient
      await deleteIngredient(oldIngredient);
    });
  }

  Future<RecipeDetail> getRecipeDetail(String recipePk) async {
    final recipe = await (select(
      recipes,
    )..where((t) => t.recipePk.equals(recipePk))).getSingle();

    final ingredientList = await (select(recipeIngredients).join([
      innerJoin(
        ingredients,
        ingredients.ingredientPk.equalsExp(recipeIngredients.ingredientFk),
      ),
    ])..where(recipeIngredients.recipeFk.equals(recipePk))).get();

    final stepList =
        await (select(recipeSteps)
              ..where((t) => t.recipeFk.equals(recipePk))
              ..orderBy([(t) => OrderingTerm(expression: t.stepNumber)]))
            .get();

    return RecipeDetail(
      recipe: recipe,
      ingredients: ingredientList.map((row) {
        return RecipeIngredientWithData(
          entry: row.readTable(recipeIngredients),
          ingredient: row.readTable(ingredients),
        );
      }).toList(),
      steps: stepList,
    );
  }
}

class RecipeDetail {
  final Recipe recipe;
  final List<RecipeIngredientWithData> ingredients;
  final List<RecipeStep> steps;

  RecipeDetail({
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });

  double get totalIngredientCost {
    return ingredients.fold(0.0, (sum, item) {
      final unitCost = item.ingredient.cost / item.ingredient.quantityForCost;
      return sum + (item.entry.amountNeeded * unitCost);
    });
  }

  double get totalCost => totalIngredientCost + (recipe.fixedOverheadCost);

  double get profitPerRecipe {
    final revenue = (recipe.targetPricePerPortion) * recipe.defaultYield;
    return revenue - totalCost;
  }
}

class RecipeIngredientWithData {
  final RecipeIngredient entry;
  final Ingredient ingredient;

  RecipeIngredientWithData({required this.entry, required this.ingredient});
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase(file);
  });
}
