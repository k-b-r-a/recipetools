import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

/// Provider that exposes the AppDatabase instance to the entire app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  ref.onDispose(() => db.close());

  return db;
});

/// Any change in the 'recipes' table will trigger an automatic UI update.
final recipesStreamProvider = StreamProvider<List<Recipe>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllRecipes();
});

/// Any change in the 'ingredients' table will trigger an automatic UI update.
final ingredientsStreamProvider = StreamProvider<List<Ingredient>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllIngredients();
});

/// Fetches the full details of a single recipe, including its ingredients and steps.
final recipeDetailProvider =
    FutureProvider.family<RecipeDetail, String>((ref, recipePk) {
  final db = ref.watch(databaseProvider);
  return db.getRecipeDetail(recipePk);
});

/// Provides a list of all available units.
final unitsProvider = FutureProvider<List<Unit>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllUnits();
});
