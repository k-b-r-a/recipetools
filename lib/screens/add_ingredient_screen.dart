import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../provider/database_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/recipe_utils.dart';
import 'compare_ingredients_screen.dart';

class AddIngredientScreen extends ConsumerStatefulWidget {
  final Ingredient? ingredient;
  const AddIngredientScreen({super.key, this.ingredient});

  @override
  ConsumerState<AddIngredientScreen> createState() =>
      _AddIngredientScreenState();
}

class _AddIngredientScreenState extends ConsumerState<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;
  String? _selectedUnitPk;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.ingredient?.name ?? '',
    );
    // automatic load: trigger search if opening existing ingredient
    _searchQuery = _nameController.text.trim();
    
    _nameController.addListener(() {
      setState(() {
        _searchQuery = _nameController.text.trim();
      });
    });
    _costController = TextEditingController(
      text: widget.ingredient?.cost.toInt().toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.ingredient?.quantityForCost.toInt().toString() ?? '',
    );
    _selectedUnitPk = widget.ingredient?.unitFk;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  /// saves the ingredient to the database
  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate() && _selectedUnitPk != null) {
      setState(() => _isLoading = true);
      try {
        final db = ref.read(databaseProvider);
        final name = _nameController.text.trim();
        final cost = double.tryParse(_costController.text) ?? 0.0;
        final quantity = double.tryParse(_quantityController.text) ?? 1.0;

        if (widget.ingredient == null) {
          await db.insertIngredient(
            IngredientsCompanion.insert(
              name: name,
              cost: cost,
              quantityForCost: quantity,
              unitFk: _selectedUnitPk!,
            ),
          );
        } else {
          await db.updateIngredient(
            widget.ingredient!.copyWith(
              name: name,
              cost: cost,
              quantityForCost: quantity,
              unitFk: _selectedUnitPk!,
              dateTimeModified: drift.Value(DateTime.now()),
            ),
          );
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.error_prefix(e.toString()))),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (_selectedUnitPk == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error_select_unit)),
        );
      }
    }
  }

  /// navigates to comparison screen for merging
  void _compareAndMerge(Ingredient other) {
    if (widget.ingredient == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompareIngredientsScreen(
          ingredient1: widget.ingredient!,
          ingredient2: other,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unitsAsync = ref.watch(unitsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ingredient == null
              ? l10n.add_ingredient_title
              : l10n.edit_ingredient_title,
        ),
        actions: [
          if (!_isLoading)
            IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.ingredient_name,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? l10n.validation_required
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _costController,
                            decoration: InputDecoration(
                              labelText: l10n.ingredient_cost,
                              prefixText: '\$',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) => value == null || value.isEmpty
                                ? l10n.validation_required
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: l10n.ingredient_quantity,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) => value == null || value.isEmpty
                                ? l10n.validation_required
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    unitsAsync.when(
                      data: (units) {
                        if (_selectedUnitPk == null && units.isNotEmpty) {
                          _selectedUnitPk = units.first.unitPk;
                        }
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedUnitPk,
                          decoration: InputDecoration(
                            labelText: l10n.units_title,
                            border: const OutlineInputBorder(),
                          ),
                          items: units.map((unit) {
                            return DropdownMenuItem(
                              value: unit.unitPk,
                              child: Text(
                                '${RecipeUtils.translateUnitName(context, unit.name)} (${unit.symbol})',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUnitPk = value;
                            });
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, s) => Text(l10n.error_prefix(e.toString())),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: Text(l10n.save_button.toUpperCase()),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_searchQuery.isNotEmpty) ...[
                      Text(
                        l10n.related_ingredients,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ref.watch(relatedIngredientsProvider(_searchQuery)).when(
                            data: (ingredients) {
                              final filtered = ingredients
                                  .where((i) =>
                                      i.ingredientPk !=
                                      widget.ingredient?.ingredientPk)
                                  .toList();
                              if (filtered.isEmpty) {
                                return Text(l10n.no_similar_ingredients);
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  return ListTile(
                                    title: Text(item.name),
                                    subtitle: Text(
                                      l10n.ingredient_price_per_quantity(
                                        RecipeUtils.formatNumber(item.cost),
                                        RecipeUtils.formatNumber(item.quantityForCost),
                                        '', // symbol empty for related list now
                                      ),
                                    ),
                                    trailing: widget.ingredient != null ? OutlinedButton.icon(
                                      onPressed: () => _compareAndMerge(item),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                        minimumSize: const Size(0, 36),
                                      ),
                                      icon: const Icon(Icons.compare_arrows, size: 18),
                                      label: Text(
                                        l10n.compare_button,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ) : null,
                                    onTap: () {
                                      // detail view could be here
                                    },
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, s) => Text(l10n.error_prefix(e.toString())),
                          ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}