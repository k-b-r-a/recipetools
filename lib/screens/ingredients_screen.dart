import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../provider/database_provider.dart';
import '../database/database.dart';
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
          _buildFloatingPillAppBar(context, l10n.ingredients_title, _scrollController),
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
                          searchQuery.isEmpty ? l10n.no_ingredients : l10n.no_ingredients_found,
                          style: theme.textTheme.headlineMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ingredient = filteredIngredients[index];
                      return FutureBuilder<List<Unit>>(
                        future: ref.read(databaseProvider).getAllUnits(),
                        builder: (context, snapshot) {
                          final unitName = snapshot.hasData
                              ? snapshot.data!
                                  .firstWhere((u) => u.unitPk == ingredient.unitFk,
                                      orElse: () => const Unit(
                                          unitPk: '',
                                          name: '?',
                                          symbol: '',
                                          isMutable: false,
                                          factorToBase: 1.0))
                                  .symbol
                              : '';

                          return ListTile(
                            title: Text(ingredient.name),
                            subtitle: Text(
                              l10n.ingredient_price_per_quantity(
                                ingredient.cost.toInt().toString(),
                                ingredient.quantityForCost.toInt().toString(),
                                unitName,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.secondaryContainer,
                              child: Icon(Icons.egg_outlined, color: theme.colorScheme.onSecondaryContainer),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddIngredientScreen(
                                    ingredient: ingredient,
                                  ),
                                ),
                              );
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(context, ingredient),
                            ),
                          );
                        },
                      );
                    },
                    childCount: filteredIngredients.length,
                  ),
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

  Future<void> _confirmDelete(BuildContext context, Ingredient ingredient) async {
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
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
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

// Re-using the same AppBar style from main.dart
Widget _buildFloatingPillAppBar(BuildContext context, String title, ScrollController controller) {
  final theme = Theme.of(context);
  return SliverAppBar(
    pinned: true,
    expandedHeight: 120,
    collapsedHeight: 70,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: LayoutBuilder(
      builder: (context, constraints) {
        final double percentage = (constraints.maxHeight - kToolbarHeight) / (120 - kToolbarHeight);
        final bool isCollapsed = constraints.maxHeight <= kToolbarHeight + 20;

        return GestureDetector(
          onTap: () {
            controller.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          child: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.zero,
            title: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                bottom: isCollapsed ? 12 : 16,
                left: isCollapsed ? 60 : 0,
                right: isCollapsed ? 60 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: isCollapsed ? 0.3 : 0.0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: isCollapsed ? 0.2 : 0.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: isCollapsed ? 5 : 0,
                    sigmaY: isCollapsed ? 5 : 0,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w900,
                      fontSize: 16 + (4 * percentage.clamp(0, 1)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}