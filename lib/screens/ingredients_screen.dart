import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../provider/database_provider.dart';
import '../database/database.dart';
import '../utils/recipe_utils.dart';
import '../widgets/floating_pill_app_bar.dart';
import 'add_ingredient_screen.dart';
import '../provider/settings_provider.dart';

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
    final unitsAsync = ref.watch(unitsStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    final currentFilter = ref.watch(ingredientFilterProvider);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          buildFloatingPillAppBar(
            context: context,
            title: l10n.ingredients_title,
            controller: _scrollController,
            underTitle: _buildUnderTitleFilterRow(context, currentFilter, l10n),
          ),
          ingredientsAsync.when(
            data: (ingredients) {
              return unitsAsync.when(
                data: (units) {
                  final unitMap = {for (var u in units) u.unitPk: u};

                  final filteredIngredients = ingredients.where((ingredient) {
                    final matchesSearch =
                        ingredient.name.toLowerCase().contains(searchQuery);
                    if (!matchesSearch) return false;

                    if (currentFilter == IngredientFilterType.all) return true;

                    final unit = unitMap[ingredient.unitFk];
                    if (unit == null) return false;

                    if (currentFilter == IngredientFilterType.solids) {
                      return unit.category == 'mass';
                    } else if (currentFilter == IngredientFilterType.liquids) {
                      return unit.category == 'volume';
                    } else if (currentFilter == IngredientFilterType.pieces) {
                      return unit.category == 'count';
                    }
                    return true;
                  }).toList();

                  if (filteredIngredients.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentFilter == IngredientFilterType.liquids
                                  ? Icons.water_drop_outlined
                                  : currentFilter == IngredientFilterType.solids
                                      ? Icons.grain_rounded
                                      : currentFilter == IngredientFilterType.pieces
                                          ? Icons.widgets_outlined
                                          : Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty &&
                                      currentFilter == IngredientFilterType.all
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
                    padding: const EdgeInsets.only(bottom: 100, top: 4),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final ingredient = filteredIngredients[index];
                        final unit = unitMap[ingredient.unitFk];
                        final unitSymbol = unit?.symbol ?? '';
                        final isLiquid = unit?.category == 'volume';
                        final isSolid = unit?.category == 'mass';
                        final isPiece = unit?.category == 'count';

                        return ListTile(
                          title: Text(
                            ingredient.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            l10n.ingredient_price_per_quantity(
                              '${settings.currencySymbol}${RecipeUtils.formatNumber(ingredient.cost)}',
                              RecipeUtils.formatNumber(
                                ingredient.quantityForCost,
                              ),
                              unitSymbol,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isLiquid
                                ? theme.colorScheme.primaryContainer
                                : isSolid
                                    ? theme.colorScheme.secondaryContainer
                                    : isPiece
                                        ? theme.colorScheme.tertiaryContainer
                                        : theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              isLiquid
                                  ? Icons.water_drop_outlined
                                  : isSolid
                                      ? Icons.grain_rounded
                                      : isPiece
                                          ? Icons.widgets_outlined
                                          : Icons.egg_outlined,
                              color: isLiquid
                                  ? theme.colorScheme.onPrimaryContainer
                                  : isSolid
                                      ? theme.colorScheme.onSecondaryContainer
                                      : isPiece
                                          ? theme.colorScheme.onTertiaryContainer
                                          : theme.colorScheme.onSurfaceVariant,
                              size: 20,
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

  Widget _buildUnderTitleFilterRow(
    BuildContext context,
    IngredientFilterType currentFilter,
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUnderTitleFilterChip(
          context: context,
          label: l10n.filter_all,
          icon: Icons.all_inclusive_rounded,
          isSelected: currentFilter == IngredientFilterType.all,
          onTap: () {
            ref
                .read(ingredientFilterProvider.notifier)
                .setFilter(IngredientFilterType.all);
          },
        ),
        const SizedBox(width: 6),
        _buildUnderTitleFilterChip(
          context: context,
          label: l10n.filter_solids,
          icon: Icons.grain_rounded,
          isSelected: currentFilter == IngredientFilterType.solids,
          onTap: () {
            ref
                .read(ingredientFilterProvider.notifier)
                .setFilter(IngredientFilterType.solids);
          },
        ),
        const SizedBox(width: 6),
        _buildUnderTitleFilterChip(
          context: context,
          label: l10n.filter_liquids,
          icon: Icons.water_drop_outlined,
          isSelected: currentFilter == IngredientFilterType.liquids,
          onTap: () {
            ref
                .read(ingredientFilterProvider.notifier)
                .setFilter(IngredientFilterType.liquids);
          },
        ),
        const SizedBox(width: 6),
        _buildUnderTitleFilterChip(
          context: context,
          label: l10n.filter_pieces,
          icon: Icons.widgets_outlined,
          isSelected: currentFilter == IngredientFilterType.pieces,
          onTap: () {
            ref
                .read(ingredientFilterProvider.notifier)
                .setFilter(IngredientFilterType.pieces);
          },
        ),
      ],
    );
  }

  Widget _buildUnderTitleFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.6)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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
