import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../provider/database_provider.dart';
import '../database/database.dart';
import '../utils/recipe_utils.dart';
import '../widgets/floating_pill_app_bar.dart';
import 'add_ingredient_screen.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ingredientsAsync = ref.watch(ingredientsStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          buildFloatingPillAppBar(
            context: context,
            title: l10n.ingredients_title,
            controller: _scrollController,
          ),
          ingredientsAsync.when(
            data: (ingredients) {
              final filteredIngredients = ingredients.where((ingredient) {
                return ingredient.name.toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredIngredients.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? l10n.no_ingredients
                              : l10n.no_ingredients_found,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final ingredient = filteredIngredients[index];
                    return FutureBuilder<List<Unit>>(
                      future: ref.read(databaseProvider).getAllUnits(),
                      builder: (context, snapshot) {
                        final unitName = snapshot.hasData
                            ? snapshot.data!
                                  .firstWhere(
                                    (u) => u.unitPk == ingredient.unitFk,
                                    orElse: () => const Unit(
                                      unitPk: '',
                                      name: '?',
                                      symbol: '',
                                      isMutable: false,
                                      factorToBase: 1.0,
                                    ),
                                  )
                                  .symbol
                            : '';

                        return ListTile(
                          title: Text(ingredient.name),
                          subtitle: Text(
                            l10n.ingredient_price_per_quantity(
                              RecipeUtils.formatNumber(ingredient.cost),
                              RecipeUtils.formatNumber(
                                ingredient.quantityForCost,
                              ),
                              unitName,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            child: Icon(
                              Icons.egg_outlined,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddIngredientScreen(ingredient: ingredient),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                _confirmDelete(context, ingredient),
                          ),
                        );
                      },
                    );
                  }, childCount: filteredIngredients.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(child: Text(l10n.error_prefix(error.toString()))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Ingredient ingredient,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete_button),
        content: Text('${l10n.delete_button} ${ingredient.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.done_button),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete_button),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(databaseProvider).deleteIngredient(ingredient);
    }
  }
}
