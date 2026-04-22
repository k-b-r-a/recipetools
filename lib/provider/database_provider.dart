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

/// Provides a stream of ingredients that match a search query.
final relatedIngredientsProvider =
    StreamProvider.family<List<Ingredient>, String>((ref, query) {
  final db = ref.watch(databaseProvider);
  return db.searchIngredients(query);
});

/// Notifier for the global search query.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

/// State provider for the global search query using Notifier.
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
