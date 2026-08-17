import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../provider/database_provider.dart';
import '../provider/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/recipe_utils.dart';
import '../utils/ingredient_text_editing_controller.dart';
import 'add_ingredient_screen.dart';
import 'compare_ingredients_screen.dart';

class InitialIngredientInput {
  final Ingredient ingredient;
  final double amount;
  const InitialIngredientInput({
    required this.ingredient,
    required this.amount,
  });
}

class InitialStepInput {
  final String instruction;
  const InitialStepInput({
    required this.instruction,
  });
}

class RecipeEditorScreen extends ConsumerStatefulWidget {
  final String? recipeId;
  final double multiplier;
  final bool isTemporary;
  final String? initialName;
  final String? initialDescription;
  final String? initialYield;
  final String? initialYieldName;
  final String? initialProfitMargin;
  final String? initialPrice;
  final List<InitialIngredientInput>? initialIngredients;
  final List<InitialStepInput>? initialSteps;

  const RecipeEditorScreen({
    super.key,
    this.recipeId,
    this.multiplier = 1.0,
    this.isTemporary = false,
    this.initialName,
    this.initialDescription,
    this.initialYield,
    this.initialYieldName,
    this.initialProfitMargin,
    this.initialPrice,
    this.initialIngredients,
    this.initialSteps,
  });

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  String get currency => ref.watch(settingsProvider).currencySymbol;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isCalculating = false;
  bool _isDescriptionExpanded = true;
  bool _showBottomFinancials = true;
  bool _isEditingName = false;

  // controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yieldController = TextEditingController(text: '1');
  final _yieldNameController = TextEditingController();
  final _profitMarginController = TextEditingController(text: '30');
  final _priceController = TextEditingController(text: '0');
  final _totalSaleController = TextEditingController(text: '0');

  final _profitMarginFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _totalSaleFocusNode = FocusNode();
  final _yieldFocusNode = FocusNode();

  // ingredients and steps state
  final List<RecipeIngredientData> _ingredients = [];
  final List<RecipeStepData> _steps = [];

  // ui state for calculations
  double _currentRevenue = 0.0;
  double _currentTotalRevenue = 0.0;
  double _currentTotalCost = 0.0;
  double _currentCostPerPortion = 0.0;
  double _currentProfitPerPortion = 0.0;

  @override
  void initState() {
    super.initState();
    _isEditingName = widget.recipeId == null;
    _isDescriptionExpanded = widget.recipeId == null && !widget.isTemporary;
    _yieldController.addListener(_calculateSummary);
    _priceController.addListener(_calculateSummary);
    _profitMarginController.addListener(_calculateSummary);
    _totalSaleController.addListener(_calculateSummary);

    if (widget.isTemporary) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadTemporaryRecipeData();
          setState(() {
            _isLoading = false;
          });
          _calculateSummary();
        }
      });
    } else if (widget.recipeId != null) {
      _loadRecipeData();
    } else {
      // Initial empty step for new recipes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _addStep(shouldFocus: false);
      });
    }
  }

  void _loadTemporaryRecipeData() {
    final theme = Theme.of(context);
    _nameController.text = widget.initialName ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _yieldController.text = widget.initialYield ?? '1';
    _yieldNameController.text = widget.initialYieldName ?? '';
    _profitMarginController.text = widget.initialProfitMargin ?? '30';
    _priceController.text = widget.initialPrice ?? '0';

    if (widget.initialIngredients != null) {
      for (var initIng in widget.initialIngredients!) {
        final data = RecipeIngredientData(
          ingredient: initIng.ingredient,
          initialAmount: RecipeUtils.formatNumber(
            initIng.amount,
            decimalDigits: 2,
          ),
        );
        data.amountController.addListener(_calculateSummary);
        _ingredients.add(data);
      }
    }

    if (widget.initialSteps != null) {
      for (var initStep in widget.initialSteps!) {
        _steps.add(
          RecipeStepData(
            initialInstruction: initStep.instruction,
            customController: IngredientTextEditingController(
              text: initStep.instruction,
              ingredients: _ingredients.map((e) => e.ingredient).toList(),
              colorScheme: theme.colorScheme,
            ),
          ),
        );
      }
    }

    if (_steps.isEmpty) _addStep(shouldFocus: false);
  }

  void _openTemporaryScaledRecipe(double multiplier) {
    final currentYield = RecipeUtils.parseFormattedNumber(
      _yieldController.text,
    );
    final scaledYield = currentYield * multiplier;

    final initialIngs = _ingredients.map((ingData) {
      return InitialIngredientInput(
        ingredient: ingData.ingredient,
        amount: ingData.amount * multiplier,
      );
    }).toList();

    final initialSteps = _steps.map((stepData) {
      return InitialStepInput(
        instruction: stepData.instructionController.text,
      );
    }).toList();

    final originalName = _nameController.text.isEmpty
        ? AppLocalizations.of(context)!.recipe_title
        : _nameController.text;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeEditorScreen(
          isTemporary: true,
          multiplier: multiplier,
          initialName:
              "$originalName (x${RecipeUtils.formatNumber(multiplier)})",
          initialDescription: _descriptionController.text,
          initialYield: RecipeUtils.formatNumber(scaledYield),
          initialYieldName: _yieldNameController.text,
          initialProfitMargin: _profitMarginController.text,
          initialPrice: _priceController.text,
          initialIngredients: initialIngs,
          initialSteps: initialSteps,
        ),
      ),
    );
  }

  Future<void> _duplicateCurrentRecipe() async {
    if (widget.recipeId == null) return;
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final currentName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : l10n.recipe_name;
    final textController = TextEditingController(
      text: "$currentName (${l10n.duplicate_button})",
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.duplicate_button),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: l10n.recipe_name,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.discard_button),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(textController.text.trim()),
            child: Text(l10n.save_button),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      try {
        await db.duplicateRecipe(widget.recipeId!, newName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.localeName == 'es'
                    ? 'Receta duplicada con éxito'
                    : 'Recipe duplicated successfully',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.error_prefix(e.toString()))),
          );
        }
      }
    }
  }

  PopupMenuItem<double> _buildPopupMenuItem(
    BuildContext context,
    double value,
    String label,
  ) {
    final theme = Theme.of(context);
    return PopupMenuItem<double>(
      value: value,
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Future<void> _loadRecipeData() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final units = await db.getAllUnits();
      final detail = await db.getRecipeDetail(widget.recipeId!);
      if (!mounted) return;
      final theme = Theme.of(context);
      final settings = ref.read(settingsProvider);

      _nameController.text = detail.recipe.name;
      _descriptionController.text = detail.recipe.description ?? '';
      _yieldController.text = RecipeUtils.formatNumber(
        detail.recipe.defaultYield,
        decimalDigits: 2,
      );
      _yieldNameController.text = detail.recipe.yieldName;
      _profitMarginController.text = RecipeUtils.formatNumber(
        detail.recipe.targetProfitMargin * 100,
        decimalDigits: 2,
      );
      _priceController.text = RecipeUtils.formatNumber(
        detail.recipe.targetPricePerPortion,
        decimalDigits: 2,
      );

      for (var ingWithData in detail.ingredients) {
        final sourceUnit = units
            .where((u) => u.unitPk == ingWithData.ingredient.unitFk)
            .firstOrNull;
        final targetUnit = sourceUnit != null
            ? _getTargetUnit(sourceUnit, units, settings)
            : null;
        final data = RecipeIngredientData(
          ingredient: ingWithData.ingredient,
          initialAmount: RecipeUtils.formatNumber(
            ingWithData.entry.amountNeeded,
            decimalDigits: 2,
          ),
          sourceUnit: sourceUnit,
          targetUnit: targetUnit,
        );
        data.amountController.addListener(_calculateSummary);
        _ingredients.add(data);
      }

      for (var step in detail.steps) {
        _steps.add(
          RecipeStepData(
            initialInstruction: step.instruction,
            customController: IngredientTextEditingController(
              text: step.instruction,
              ingredients: _ingredients.map((e) => e.ingredient).toList(),
              colorScheme: theme.colorScheme,
            ),
          ),
        );
      }

      if (_steps.isEmpty) _addStep(shouldFocus: false);
    } catch (e) {
      // error handling
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _calculateSummary();
      }
    }
  }

  void _addStep({int? atIndex, bool shouldFocus = true}) {
    setState(() {
      final theme = Theme.of(context);
      final newStep = RecipeStepData(
        customController: IngredientTextEditingController(
          ingredients: _ingredients.map((e) => e.ingredient).toList(),
          colorScheme: theme.colorScheme,
        ),
      );
      if (atIndex != null && atIndex < _steps.length) {
        _steps.insert(atIndex + 1, newStep);
      } else {
        _steps.add(newStep);
      }

      if (shouldFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          newStep.focusNode.requestFocus();
        });
      }
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps[index].dispose();
      _steps.removeAt(index);
      if (_steps.isEmpty) {
        _addStep();
      }
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].amountController.removeListener(_calculateSummary);
      _ingredients[index].amountController.dispose();
      _ingredients.removeAt(index);

      final allIngs = _ingredients.map((e) => e.ingredient).toList();
      for (var step in _steps) {
        if (step.instructionController is IngredientTextEditingController) {
          final controller =
              step.instructionController as IngredientTextEditingController;
          controller.updateIngredients(allIngs);
        }
      }
      _calculateSummary();
    });
  }

  void _confirmDeleteIngredient(int index) async {
    final ingName = _ingredients[index].ingredient.name;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.localeName == 'es' ? '¿Eliminar ingrediente?' : 'Delete Ingredient?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.localeName == 'es'
              ? '¿Estás seguro de que deseas eliminar "$ingName" de esta receta?'
              : 'Are you sure you want to remove "$ingName" from this recipe?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.localeName == 'es' ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.localeName == 'es' ? 'Eliminar' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _removeIngredient(index);
    }
  }

  void _showMergeIngredientDialog(int sourceIndex, List<Unit> units) async {
    final sourceData = _ingredients[sourceIndex];
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final otherIngredients = <int, RecipeIngredientData>{};
    for (int i = 0; i < _ingredients.length; i++) {
      if (i != sourceIndex) {
        otherIngredients[i] = _ingredients[i];
      }
    }

    if (otherIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.localeName == 'es'
                ? 'No hay otros ingredientes en esta receta para combinar.'
                : 'No other ingredients in this recipe to merge into.',
          ),
        ),
      );
      return;
    }

    int? selectedTargetIndex;

    final targetIndex = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.merge_type_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.localeName == 'es' ? 'Combinar Ingrediente' : 'Merge Ingredient',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.localeName == 'es'
                        ? 'Combinar "${sourceData.ingredient.name}" en:'
                        : 'Merge "${sourceData.ingredient.name}" into:',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: otherIngredients.entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final isSelected = selectedTargetIndex == index;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            title: Text(
                              data.ingredient.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${data.amountController.text} ${data.targetUnit?.symbol ?? ""}',
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                                : null,
                            onTap: () {
                              setDialogState(() {
                                selectedTargetIndex = index;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(l10n.localeName == 'es' ? 'Cancelar' : 'Cancel'),
                ),
                FilledButton(
                  onPressed: selectedTargetIndex != null
                      ? () => Navigator.of(ctx).pop(selectedTargetIndex)
                      : null,
                  child: Text(l10n.localeName == 'es' ? 'Combinar' : 'Merge'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted) return;

    if (targetIndex != null && targetIndex < _ingredients.length) {
      final targetData = _ingredients[targetIndex];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompareIngredientsScreen(
            ingredient1: sourceData.ingredient,
            ingredient2: targetData.ingredient,
          ),
        ),
      );
    }
  }

  void _showIngredientOptionsModal(int index, List<Unit> units) {
    final data = _ingredients[index];
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  data.ingredient.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.merge_type_rounded, color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    l10n.localeName == 'es' ? 'Combinar / Fusionar ingrediente' : 'Merge ingredient',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    l10n.localeName == 'es'
                        ? 'Sumar cantidad a otro ingrediente de esta receta'
                        : 'Add amount into another ingredient in this recipe',
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showMergeIngredientDialog(index, units);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.errorContainer,
                    child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                  ),
                  title: Text(
                    l10n.localeName == 'es' ? 'Eliminar ingrediente' : 'Delete ingredient',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  subtitle: Text(
                    l10n.localeName == 'es'
                        ? 'Quitar ingrediente de esta receta'
                        : 'Remove ingredient from this recipe',
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmDeleteIngredient(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _yieldController.removeListener(_calculateSummary);
    _priceController.removeListener(_calculateSummary);
    _profitMarginController.removeListener(_calculateSummary);
    _totalSaleController.removeListener(_calculateSummary);
    _nameController.dispose();
    _descriptionController.dispose();
    _yieldController.dispose();
    _yieldNameController.dispose();
    _profitMarginController.dispose();
    _priceController.dispose();
    _totalSaleController.dispose();
    _profitMarginFocusNode.dispose();
    _priceFocusNode.dispose();
    _totalSaleFocusNode.dispose();
    _yieldFocusNode.dispose();
    for (var ingredient in _ingredients) {
      ingredient.amountController.dispose();
    }
    for (var step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  void _calculateSummary() {
    if (_isCalculating || _isLoading || _isSaving) return;
    _isCalculating = true;

    try {
      double yieldVal = RecipeUtils.parseFormattedNumber(_yieldController.text);
      if (yieldVal <= 0) yieldVal = 1.0;

      double totalCost = 0.0;
      for (var ing in _ingredients) {
        totalCost += ing.totalCost;
      }

      // 1. Determine which value to update based on user focus
      if (_totalSaleFocusNode.hasFocus) {
        double totalSaleVal = RecipeUtils.parseFormattedNumber(
          _totalSaleController.text,
        );
        double pricePerPortion = totalSaleVal / yieldVal;
        _priceController.text = RecipeUtils.formatNumber(
          pricePerPortion,
          decimalDigits: 2,
        );
      } else if (_profitMarginFocusNode.hasFocus) {
        double targetMarkup = RecipeUtils.parseFormattedNumber(
          _profitMarginController.text,
        );
        double recommendedPrice = RecipeUtils.calculatePriceFromMarkup(
          totalIngredientsCost: totalCost,
          yieldVal: yieldVal,
          targetMarkupPercent: targetMarkup,
        );
        _priceController.text = RecipeUtils.formatNumber(
          recommendedPrice,
          decimalDigits: 2,
        );
      } else if (_priceFocusNode.hasFocus) {
        // manual price edit, margin will follow
      } else if (_yieldFocusNode.hasFocus) {
        // If yield changes, we maintain the same margin and update price
        double targetMarkup = RecipeUtils.parseFormattedNumber(
          _profitMarginController.text,
        );
        double recommendedPrice = RecipeUtils.calculatePriceFromMarkup(
          totalIngredientsCost: totalCost,
          yieldVal: yieldVal,
          targetMarkupPercent: targetMarkup,
        );
        _priceController.text = RecipeUtils.formatNumber(
          recommendedPrice,
          decimalDigits: 2,
        );
      } else {
        // Default fallback (e.g., initial load or ingredient change)
        // If NO field has focus, we DON'T overwrite controllers to avoid reverting user input on focus loss
      }

      // 2. Perform general calculation
      final summary = RecipeUtils.calculateSummaryFromIngredients(
        ingredients: _ingredients,
        yieldText: _yieldController.text,
        priceText: _priceController.text,
      );

      // 3. Update state
      setState(() {
        _currentTotalCost = summary.totalCost;
        _currentTotalRevenue = summary.totalRevenue;
        _currentRevenue = summary.totalProfit;
        _currentCostPerPortion = summary.costPerPortion;
        _currentProfitPerPortion = summary.profitPerPortion;

        if (!_totalSaleFocusNode.hasFocus && !_isSaving) {
          _totalSaleController.text = RecipeUtils.formatNumber(
            summary.totalRevenue,
            decimalDigits: 2,
          );
        }

        if (!_profitMarginFocusNode.hasFocus && !_isSaving) {
          _profitMarginController.text = RecipeUtils.formatNumber(
            summary.profitMargin,
            decimalDigits: 2,
          );
        }
      });
    } finally {
      _isCalculating = false;
    }
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      _isSaving = true;
      // Capture values IMMEDIATELY
      final name = _nameController.text;
      final description = _descriptionController.text;
      final yieldVal = _yieldController.text;
      final yieldName = _yieldNameController.text.isEmpty
          ? 'portions'
          : _yieldNameController.text;
      final margin = _profitMarginController.text;
      final price = _priceController.text;

      setState(() => _isLoading = true);
      try {
        final db = ref.read(databaseProvider);
        await RecipeUtils.saveRecipe(
          db: db,
          recipePk: widget.recipeId,
          name: name,
          description: description,
          yieldText: yieldVal,
          yieldName: yieldName,
          profitMarginText: margin,
          priceText: price,
          ingredients: _ingredients,
          steps: _steps,
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        // error handling
        if (mounted) setState(() => _isSaving = false);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unitsAsync = ref.watch(unitsProvider);

    if (_yieldNameController.text.isEmpty) {
      _yieldNameController.text = l10n.unit_portions.toLowerCase();
    }

    final appBarTitle = widget.isTemporary
        ? (_nameController.text.isEmpty
              ? l10n.recipe_title
              : _nameController.text)
        : (widget.recipeId == null
              ? l10n.new_recipe_title
              : (_nameController.text.isEmpty
                    ? l10n.recipe_title
                    : _nameController.text));

    // Only intercept back nav for brand-new, non-temporary recipes
    final isNewUnsaved = widget.recipeId == null && !widget.isTemporary;

    Future<bool> onPopRequested() async {
      if (!isNewUnsaved) return true;
      final hasContent =
          _nameController.text.isNotEmpty ||
          _ingredients.isNotEmpty ||
          _steps.any((s) => s.instructionController.text.isNotEmpty);
      if (!hasContent) return true;

      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.unsaved_changes_title),
          content: Text(l10n.unsaved_changes_body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('discard'),
              child: Text(
                l10n.discard_button,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop('save'),
              child: Text(l10n.save_button),
            ),
          ],
        ),
      );

      if (result == 'save') {
        await _saveRecipe();
        return false; // _saveRecipe pops itself
      }
      return result == 'discard';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await onPopRequested();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: const BackButton(),
          centerTitle: true,
          title: InkWell(
            onTap: () {
              if (widget.recipeId != null && !widget.isTemporary) {
                setState(() {
                  _isEditingName = !_isEditingName;
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appBarTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.recipeId != null && !widget.isTemporary && !_isEditingName) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                    if (widget.isTemporary)
                      Text(
                        l10n.temporary_view_title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            if (widget.recipeId != null && !widget.isTemporary) ...[
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _isLoading ? null : _saveRecipe,
              ),
            ],
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (widget.isTemporary)
                      Container(
                        width: double.infinity,
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.temporary_view_banner(
                                  RecipeUtils.formatNumber(widget.multiplier),
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        children: [
                          const SizedBox(height: 16),
                          if (!widget.isTemporary && (widget.recipeId == null || _isEditingName)) ...[
                            _buildCustomTextField(
                              controller: _nameController,
                              label: l10n.recipe_name,
                              hint: l10n.recipe_name,
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? l10n.recipe_name
                                  : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader(l10n.recipe_description),
                              IconButton(
                                icon: Icon(
                                  _isDescriptionExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () => setState(() {
                                  _isDescriptionExpanded =
                                      !_isDescriptionExpanded;
                                }),
                              ),
                            ],
                          ),
                          if (_isDescriptionExpanded) ...[
                            _buildCustomTextField(
                              controller: _descriptionController,
                              label: '',
                              hint: l10n.recipe_description_hint,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (widget.recipeId != null &&
                              !widget.isTemporary) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: _duplicateCurrentRecipe,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondaryContainer
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: theme.colorScheme.secondary
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.copy_rounded,
                                            size: 18,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.duplicate_button,
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  color: theme.colorScheme.secondary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<double>(
                                    tooltip: l10n.scale_recipe_tooltip,
                                    onSelected: _openTemporaryScaledRecipe,
                                    itemBuilder: (context) => [
                                      _buildPopupMenuItem(context, 2.0, 'x2'),
                                      _buildPopupMenuItem(context, 3.0, 'x3'),
                                      _buildPopupMenuItem(context, 4.0, 'x4'),
                                      _buildPopupMenuItem(context, 5.0, 'x5'),
                                    ],
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.scale,
                                            size: 18,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.scale_button,
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  color: theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            size: 18,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader(l10n.ingredients_title),
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: _showGlobalIngredientPicker,
                              ),
                            ],
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          if (_ingredients.isEmpty)
                            _buildEmptyPlaceholder(
                              l10n.no_ingredients,
                              Icons.restaurant_menu,
                            )
                          else
                            unitsAsync.when(
                              data: (units) => ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _ingredients.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) =>
                                    _buildIngredientItem(
                                      index,
                                      theme.colorScheme,
                                      units,
                                    ),
                              ),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (e, _) =>
                                  Center(child: Text(e.toString())),
                            ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader(l10n.recipe_steps),
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                onPressed: () => _addStep(),
                              ),
                            ],
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          if (_steps.isEmpty)
                            _buildEmptyPlaceholder(
                              l10n.no_steps,
                              Icons.format_list_numbered,
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _steps.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) =>
                                  _buildStepItem(index, theme.colorScheme),
                            ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.fastOutSlowIn,
                      alignment: Alignment.bottomCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        reverseDuration: const Duration(milliseconds: 250),
                        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          final isIncoming = (child.key == const ValueKey('expanded_financials') && _showBottomFinancials) ||
                                             (child.key == const ValueKey('collapsed_financials') && !_showBottomFinancials);
                          
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: isIncoming ? Curves.easeOutCubic : Curves.easeInCubic,
                          );

                          return FadeTransition(
                            opacity: curvedAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.3),
                                end: Offset.zero,
                              ).animate(curvedAnimation),
                              child: child,
                            ),
                          );
                        },
                        child: _showBottomFinancials
                            ? _buildBottomFinancials(context)
                            : _buildCollapsedBottomFinancials(context),
                      ),
                    ),
                  ],
                ),
              ),
      ), // close Scaffold (child of PopScope)
    ); // close PopScope
  }

  Widget _buildBottomFinancials(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      key: const ValueKey('expanded_financials'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _showBottomFinancials = false),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.localeName == 'es' ? 'Ocultar Resumen Financiero' : 'Hide Financial Summary',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // --- ROW 1 (3 COLUMNS): Total Margin %, Price per Portion, Portions ---
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildFinancialInputCard(
                    theme: theme,
                    label: l10n.financial_margin,
                    controller: _profitMarginController,
                    suffix: '%',
                    focusNode: _profitMarginFocusNode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFinancialInputCard(
                    theme: theme,
                    label: l10n.financial_price,
                    controller: _priceController,
                    prefix: currency,
                    focusNode: _priceFocusNode,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFinancialInputCard(
                    theme: theme,
                    label: l10n.unit_portions,
                    controller: _yieldController,
                    focusNode: _yieldFocusNode,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- ROW 2: Fixed Total Profit on Left, Scrollable Metrics on Right ---
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // FIXED ON LEFT: Total Profit
                _buildMetricCard(
                  theme: theme,
                  label: l10n.total_profit,
                  value: '$currency${RecipeUtils.formatNumber(_currentRevenue)}',
                  color: theme.colorScheme.primary,
                  isHighlighted: true,
                  minWidth: 110,
                ),
                const SizedBox(width: 6),
                VerticalDivider(
                  width: 10,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 2),
                // SCROLLABLE ON RIGHT: Other metric figures
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildMetricCard(
                          theme: theme,
                          label: l10n.total_cost,
                          value: '$currency${RecipeUtils.formatNumber(_currentTotalCost)}',
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        _buildMetricCard(
                          theme: theme,
                          label: l10n.total_sale,
                          value: '$currency${RecipeUtils.formatNumber(_currentTotalRevenue)}',
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        _buildMetricCard(
                          theme: theme,
                          label: l10n.cost_per_portion,
                          value: '$currency${RecipeUtils.formatNumber(_currentCostPerPortion)}',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        _buildMetricCard(
                          theme: theme,
                          label: l10n.profit_per_portion,
                          value: '$currency${RecipeUtils.formatNumber(_currentProfitPerPortion)}',
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        _buildMetricCard(
                          theme: theme,
                          label: l10n.sale_per_portion,
                          value: '$currency${RecipeUtils.formatNumber(RecipeUtils.parseFormattedNumber(_priceController.text))}',
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialInputCard({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    required FocusNode focusNode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 9.5,
                  height: 1.1,
                ),
                softWrap: true,
                maxLines: 2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (prefix != null)
                Text(
                  '$prefix ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => FocusScope.of(context).unfocus(),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (suffix != null)
                Text(
                  suffix,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required String label,
    required String value,
    required Color color,
    bool isHighlighted = false,
    double? minWidth,
  }) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth ?? 115),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted ? color.withValues(alpha: 0.4) : Colors.transparent,
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedBottomFinancials(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final totalCostStr = '$currency${RecipeUtils.formatNumber(_currentTotalCost)}';
    final pricePerPortionStr = '$currency${RecipeUtils.formatNumber(RecipeUtils.parseFormattedNumber(_priceController.text))}';
    final profitPerPortionStr = '$currency${RecipeUtils.formatNumber(_currentProfitPerPortion)}';

    return InkWell(
      key: const ValueKey('collapsed_financials'),
      onTap: () => setState(() => _showBottomFinancials = true),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 6,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.localeName == 'es' ? 'Mostrar Resumen Financiero' : 'Show Financial Summary',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_up,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCollapsedMetric(
                  context,
                  l10n.localeName == 'es' ? 'Costo Total' : 'Total Cost',
                  totalCostStr,
                ),
                _buildCollapsedMetric(
                  context,
                  l10n.localeName == 'es' ? 'Precio/Porción' : 'Price/Portion',
                  pricePerPortionStr,
                ),
                _buildCollapsedMetric(
                  context,
                  l10n.localeName == 'es' ? 'Ganancia/Porción' : 'Gain/Portion',
                  profitPerPortionStr,
                  valueColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedMetric(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: valueColor ?? theme.colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            filled: !readOnly,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.2,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: readOnly ? 4 : 16,
              vertical: readOnly ? 4 : 12,
            ),
            border: readOnly
                ? InputBorder.none
                : const OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: readOnly
                ? InputBorder.none
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
            focusedBorder: readOnly
                ? InputBorder.none
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
          ),
          style: readOnly
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : null,
        ),
      ],
    );
  }



  Widget _buildEmptyPlaceholder(String message, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(40.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(
    int index,
    ColorScheme colorScheme,
    List<Unit> units,
  ) {
    final data = _ingredients[index];
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final itemColor = RecipeUtils.getIngredientColor(
      data.ingredient.name,
      colorScheme,
    );

    final unitSymbol =
        data.targetUnit?.symbol ??
        units
            .firstWhere(
              (u) => u.unitPk == data.ingredient.unitFk,
              orElse: () => const Unit(
                unitPk: '',
                symbol: '',
                name: '',
                category: null,
                factorToBase: 1,
                isMutable: false,
              ),
            )
            .symbol;

    return GestureDetector(
      onLongPress: () => _showIngredientOptionsModal(index, units),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: itemColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.ingredient.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: data.amountController,
                          onTap: () {
                            data.amountController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: data.amountController.text.length,
                            );
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                          },
                          onSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                          textAlign: TextAlign.start,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 0,
                            ),
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        unitSymbol,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Builder(
                    builder: (context) {
                      final originalUnitSymbol = units
                          .firstWhere(
                            (u) => u.unitPk == data.ingredient.unitFk,
                            orElse: () => const Unit(
                              unitPk: '',
                              symbol: '',
                              name: '',
                              category: null,
                              factorToBase: 1,
                              isMutable: false,
                            ),
                          )
                          .symbol;
                      return Text(
                        l10n.ingredient_price_per_quantity(
                          '$currency${RecipeUtils.formatNumber(data.ingredient.cost)}',
                          RecipeUtils.formatNumber(data.ingredient.quantityForCost),
                          originalUnitSymbol,
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.end,
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$currency ${RecipeUtils.formatNumber(data.totalCost)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 22),
              color: theme.colorScheme.error.withValues(alpha: 0.6),
              onPressed: () => _confirmDeleteIngredient(index),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int index, ColorScheme colorScheme) {
    final step = _steps[index];
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _removeStep(index),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 16, thickness: 0.5),
            TextField(
              controller: step.instructionController,
              focusNode: step.focusNode,
              maxLines: null,
              style: theme.textTheme.bodyLarge,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _addStep(atIndex: index),
              decoration: InputDecoration(
                hintText: l10n.step_instruction_hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  bottom: 24,
                  top: 4,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGlobalIngredientPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final Map<String, (Ingredient, TextEditingController)> selectedInModal = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.select_ingredient_recipe_title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final query = ref.watch(searchQueryProvider);
                        return TextField(
                          onChanged: (val) => ref
                              .read(searchQueryProvider.notifier)
                              .setQuery(val),
                          decoration: InputDecoration(
                            hintText: l10n.search_hint,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => ref
                                        .read(searchQueryProvider.notifier)
                                        .setQuery(''),
                                  )
                                : null,
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddIngredientScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    tooltip: l10n.new_ingredient_button,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final query = ref.watch(searchQueryProvider);
                    final ingredientsAsync = query.isEmpty
                        ? ref.watch(ingredientsStreamProvider)
                        : ref.watch(relatedIngredientsProvider(query));
                    final unitsAsync = ref.watch(unitsProvider);

                    return ingredientsAsync.when(
                      data: (ingredients) {
                        if (ingredients.isEmpty) {
                          return Center(child: Text(l10n.no_ingredients));
                        }
                        return ListView.builder(
                          itemCount: ingredients.length,
                          itemBuilder: (context, index) {
                            final ing = ingredients[index];
                            final isAlreadyInRecipe = _ingredients.any(
                              (i) =>
                                  i.ingredient.ingredientPk == ing.ingredientPk,
                            );
                            final isSelected = selectedInModal.containsKey(
                              ing.ingredientPk,
                            );
                            final itemColor = RecipeUtils.getIngredientColor(
                              ing.name,
                              theme.colorScheme,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primaryContainer
                                            .withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  enabled: !isAlreadyInRecipe,
                                  onLongPress: () {
                                    _showPickerIngredientOptionsModal(
                                      context,
                                      ref,
                                      ing,
                                      ingredients,
                                      theme,
                                      l10n,
                                      setModalState,
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: itemColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            color: theme.colorScheme.primary,
                                          )
                                        : Icon(
                                            Icons.egg_outlined,
                                            size: 20,
                                            color: itemColor,
                                          ),
                                  ),
                                  title: Text(
                                    ing.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: isAlreadyInRecipe
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: unitsAsync.when(
                                    data: (units) {
                                      final unit = units
                                          .firstWhere(
                                            (u) => u.unitPk == ing.unitFk,
                                          )
                                          .symbol;
                                      return Text(
                                        l10n.ingredient_price_per_quantity(
                                          '$currency${RecipeUtils.formatNumber(ing.cost)}',
                                          RecipeUtils.formatNumber(ing.quantityForCost),
                                          unit,
                                        ),
                                      );
                                    },
                                    loading: () => const Text('...'),
                                    error: (_, _) => const Text('Error'),
                                  ),
                                  trailing: isAlreadyInRecipe
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.grey,
                                        )
                                      : isSelected
                                      ? SizedBox(
                                          width: 80,
                                          child: TextField(
                                            controller:
                                                selectedInModal[ing
                                                        .ingredientPk]!
                                                    .$2,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            textInputAction: TextInputAction.done,
                                            onEditingComplete: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                            onSubmitted: (_) {
                                              FocusScope.of(context).unfocus();
                                            },
                                            textAlign: TextAlign.end,
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              suffixText: unitsAsync.maybeWhen(
                                                data: (units) {
                                                  final settings = ref.read(
                                                    settingsProvider,
                                                  );
                                                  final sourceUnit = units
                                                      .where(
                                                        (u) =>
                                                            u.unitPk ==
                                                            ing.unitFk,
                                                      )
                                                      .firstOrNull;
                                                  final targetUnit =
                                                      sourceUnit != null
                                                      ? _getTargetUnit(
                                                          sourceUnit,
                                                          units,
                                                          settings,
                                                        )
                                                      : null;
                                                  return targetUnit?.symbol ??
                                                      sourceUnit?.symbol ??
                                                      '';
                                                },
                                                orElse: () => '',
                                              ),
                                              suffixStyle: const TextStyle(
                                                fontSize: 10,
                                              ),
                                              isDense: true,
                                              border:
                                                  const UnderlineInputBorder(),
                                            ),
                                            onChanged: (val) =>
                                                setModalState(() {}),
                                          ),
                                        )
                                      : null,
                                  onTap: () {
                                    if (isAlreadyInRecipe) return;
                                    setModalState(() {
                                      if (isSelected) {
                                        selectedInModal.remove(
                                          ing.ingredientPk,
                                        );
                                      } else {
                                        selectedInModal[ing.ingredientPk] = (
                                          ing,
                                          TextEditingController(),
                                        );
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(e.toString())),
                    );
                  },
                ),
              ),
              if (selectedInModal.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          final settings = ref.read(settingsProvider);
                          final units = ref.read(unitsProvider).value ?? [];
                          selectedInModal.forEach((_, value) {
                            final ing = value.$1;
                            final controller = value.$2;

                            if (!_ingredients.any(
                              (i) =>
                                  i.ingredient.ingredientPk == ing.ingredientPk,
                            )) {
                              final sourceUnit = units
                                  .where((u) => u.unitPk == ing.unitFk)
                                  .firstOrNull;
                              final targetUnit = sourceUnit != null
                                  ? _getTargetUnit(sourceUnit, units, settings)
                                  : null;

                              double amountInSource =
                                  RecipeUtils.parseFormattedNumber(
                                    controller.text,
                                  );
                              if (sourceUnit != null &&
                                  targetUnit != null &&
                                  sourceUnit.category == targetUnit.category &&
                                  sourceUnit.category != null) {
                                // convert from target to source
                                final base =
                                    amountInSource * targetUnit.factorToBase;
                                amountInSource = base / sourceUnit.factorToBase;
                              }

                              final data = RecipeIngredientData(
                                ingredient: ing,
                                initialAmount: RecipeUtils.formatNumber(
                                  amountInSource,
                                ),
                                sourceUnit: sourceUnit,
                                targetUnit: targetUnit,
                              );
                              data.amountController.addListener(
                                _calculateSummary,
                              );
                              _ingredients.add(data);
                            }
                          });

                          final allIngs = _ingredients
                              .map((e) => e.ingredient)
                              .toList();
                          for (var step in _steps) {
                            if (step.instructionController
                                is IngredientTextEditingController) {
                              (step.instructionController
                                      as IngredientTextEditingController)
                                  .updateIngredients(allIngs);
                            }
                          }

                          _calculateSummary();
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.add_task),
                      label: Text(
                        "${l10n.add_button} (${selectedInModal.length})"
                            .toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }



  void _showPickerIngredientOptionsModal(
    BuildContext context,
    WidgetRef ref,
    Ingredient ing,
    List<Ingredient> allIngredients,
    ThemeData theme,
    AppLocalizations l10n,
    StateSetter setModalState,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ing.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.merge_type_rounded, color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    l10n.localeName == 'es' ? 'Combinar / Fusionar ingrediente' : 'Merge ingredient',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    l10n.localeName == 'es'
                        ? 'Fusionar con otro ingrediente en la base de datos'
                        : 'Merge into another ingredient in the database',
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showGlobalMergeDialog(context, ref, ing, allIngredients, theme, l10n);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.errorContainer,
                    child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                  ),
                  title: Text(
                    l10n.localeName == 'es' ? 'Eliminar ingrediente' : 'Delete ingredient',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  subtitle: Text(
                    l10n.localeName == 'es'
                        ? 'Eliminar permanentemente de la base de datos'
                        : 'Permanently delete from database',
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmGlobalDeleteIngredient(context, ref, ing, theme, l10n);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmGlobalDeleteIngredient(
    BuildContext context,
    WidgetRef ref,
    Ingredient ing,
    ThemeData theme,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.localeName == 'es' ? '¿Eliminar ingrediente?' : 'Delete Ingredient?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.localeName == 'es'
              ? '¿Estás seguro de que deseas eliminar "${ing.name}" de la base de datos?'
              : 'Are you sure you want to delete "${ing.name}" from the database?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.localeName == 'es' ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.localeName == 'es' ? 'Eliminar' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await db.deleteIngredient(ing);
      ref.invalidate(ingredientsStreamProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.localeName == 'es'
                  ? 'Ingrediente "${ing.name}" eliminado.'
                  : 'Ingredient "${ing.name}" deleted.',
            ),
          ),
        );
      }
    }
  }

  void _showGlobalMergeDialog(
    BuildContext context,
    WidgetRef ref,
    Ingredient sourceIng,
    List<Ingredient> allIngredients,
    ThemeData theme,
    AppLocalizations l10n,
  ) async {
    final otherIngredients = allIngredients
        .where((i) => i.ingredientPk != sourceIng.ingredientPk)
        .toList();

    if (otherIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.localeName == 'es'
                ? 'No hay otros ingredientes en la base de datos para combinar.'
                : 'No other ingredients in the database to merge into.',
          ),
        ),
      );
      return;
    }

    Ingredient? selectedTarget;

    final target = await showDialog<Ingredient>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.merge_type_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.localeName == 'es' ? 'Combinar Ingrediente' : 'Merge Ingredient',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.localeName == 'es'
                          ? 'Combinar "${sourceIng.name}" en:'
                          : 'Merge "${sourceIng.name}" into:',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...otherIngredients.map((targetIng) {
                      final isSelected = selectedTarget?.ingredientPk == targetIng.ingredientPk;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          title: Text(
                            targetIng.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                              : null,
                          onTap: () {
                            setDialogState(() {
                              selectedTarget = targetIng;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(l10n.localeName == 'es' ? 'Cancelar' : 'Cancel'),
                ),
                FilledButton(
                  onPressed: selectedTarget != null
                      ? () => Navigator.of(ctx).pop(selectedTarget)
                      : null,
                  child: Text(l10n.localeName == 'es' ? 'Combinar' : 'Merge'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted) return;

    if (target != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompareIngredientsScreen(
            ingredient1: sourceIng,
            ingredient2: target,
          ),
        ),
      );
    }
  }

  Unit? _getTargetUnit(Unit source, List<Unit> units, SettingsState settings) {
    if (source.category == null) return source;
    final targetSymbol = source.category == 'mass'
        ? settings.defaultMassUnit
        : source.category == 'volume'
        ? settings.defaultVolumeUnit
        : null;
    if (targetSymbol == null) return source;
    return units
            .where(
              (u) => u.symbol == targetSymbol && u.category == source.category,
            )
            .firstOrNull ??
        source;
  }
}
