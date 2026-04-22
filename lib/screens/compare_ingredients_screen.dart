import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../provider/database_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/recipe_utils.dart';

class CompareIngredientsScreen extends ConsumerStatefulWidget {
  final Ingredient ingredient1;
  final Ingredient ingredient2;

  const CompareIngredientsScreen({
    super.key,
    required this.ingredient1,
    required this.ingredient2,
  });

  @override
  ConsumerState<CompareIngredientsScreen> createState() => _CompareIngredientsScreenState();
}

class _CompareIngredientsScreenState extends ConsumerState<CompareIngredientsScreen> {
  String? _selectedIngredientPk;
  bool _isMerging = false;

  /// performs the merge logic
  Future<void> _handleMerge() async {
    if (_selectedIngredientPk == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    final survivor = _selectedIngredientPk == widget.ingredient1.ingredientPk 
        ? widget.ingredient1 
        : widget.ingredient2;
    final other = _selectedIngredientPk == widget.ingredient1.ingredientPk 
        ? widget.ingredient2 
        : widget.ingredient1;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.merge_confirm_title),
        content: Text(l10n.merge_confirm_message(other.name, survivor.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.done_button),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.merge_button),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isMerging = true);
      try {
        await ref.read(databaseProvider).mergeIngredients(other, survivor);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Merged successfully')),
          );
          Navigator.pop(context); // go back to add screen
          Navigator.pop(context); // go back to list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.error_prefix(e.toString()))),
          );
        }
      } finally {
        if (mounted) setState(() => _isMerging = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.compare_button),
      ),
      body: unitsAsync.when(
        data: (units) {
          final unit1 = units.firstWhere((u) => u.unitPk == widget.ingredient1.unitFk);
          final unit2 = units.firstWhere((u) => u.unitPk == widget.ingredient2.unitFk);

          // normalize costs to compare correctly
          final costPerUnit2 = widget.ingredient2.cost / (widget.ingredient2.quantityForCost * unit2.factorToBase);

          // calculate how much more/less based on ingredient 1's quantity as baseline
          final comparisonQuantity = widget.ingredient1.quantityForCost * unit1.factorToBase;
          final price1 = widget.ingredient1.cost;
          final price2AtSameQuantity = costPerUnit2 * comparisonQuantity;
          
          final diff = (price1 - price2AtSameQuantity).abs();
          final formattedDiff = RecipeUtils.formatNumber(diff);

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _IngredientSimpleCard(
                          ingredient: widget.ingredient1,
                          unit: unit1,
                          diffText: price1 > price2AtSameQuantity ? '+\$$formattedDiff MORE' : '-\$$formattedDiff LESS',
                          diffColor: price1 > price2AtSameQuantity ? Colors.red : Colors.green,
                          diffIcon: price1 > price2AtSameQuantity ? Icons.trending_up : Icons.savings,
                          isSelected: _selectedIngredientPk == widget.ingredient1.ingredientPk,
                          isAnySelected: _selectedIngredientPk != null,
                          onSelect: () => setState(() => _selectedIngredientPk = widget.ingredient1.ingredientPk),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _IngredientSimpleCard(
                          ingredient: widget.ingredient2,
                          unit: unit2,
                          // inverse comparison for the second card
                          diffText: price2AtSameQuantity > price1 ? '+\$$formattedDiff MORE' : '-\$$formattedDiff LESS',
                          diffColor: price2AtSameQuantity > price1 ? Colors.red : Colors.green,
                          diffIcon: price2AtSameQuantity > price1 ? Icons.trending_up : Icons.savings,
                          isSelected: _selectedIngredientPk == widget.ingredient2.ingredientPk,
                          isAnySelected: _selectedIngredientPk != null,
                          onSelect: () => setState(() => _selectedIngredientPk = widget.ingredient2.ingredientPk),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_selectedIngredientPk != null)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isMerging ? null : _handleMerge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isMerging 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.merge_type),
                      label: Text(
                        l10n.merge_button.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.error_prefix(e.toString()))),
      ),
    );
  }
}

class _IngredientSimpleCard extends StatelessWidget {
  final Ingredient ingredient;
  final Unit unit;
  final String diffText;
  final Color diffColor;
  final IconData diffIcon;
  final bool isSelected;
  final bool isAnySelected;
  final VoidCallback onSelect;

  const _IngredientSimpleCard({
    required this.ingredient,
    required this.unit,
    required this.diffText,
    required this.diffColor,
    required this.diffIcon,
    required this.isSelected,
    required this.isAnySelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // logic for individual scale from center
    double targetScale = 1.0;
    if (isAnySelected) {
      targetScale = isSelected ? 1.05 : 0.95;
    }

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(isSelected ? -2.0 : 0.0) // tiny lateral adjustment to keep it centered
          ..scale(targetScale),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5) 
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ingredient.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '\$${RecipeUtils.formatNumber(ingredient.cost)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'per ${RecipeUtils.formatNumber(ingredient.quantityForCost)} ${unit.symbol}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: diffColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(diffIcon, size: 14, color: diffColor),
                        const SizedBox(width: 4),
                        Text(
                          diffText,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: diffColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
