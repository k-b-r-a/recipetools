import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../provider/database_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/recipe_utils.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  final String recipeId;
  const RecipeScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showDescription = true;
  bool _isUpdating = false;

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yieldController = TextEditingController(text: '1');
  final _yieldNameController = TextEditingController();
  final _profitMarginController = TextEditingController(text: '30');
  final _priceController = TextEditingController(text: '0');

  // Ingredients and Steps state using RecipeUtils models
  final List<RecipeIngredientData> _ingredients = [];
  final List<RecipeStepData> _steps = [];

  // UI state for calculations
  double _currentRevenue = 0.0;
  double _currentTotalCost = 0.0;
  double _currentCostPerPortion = 0.0;
  double _currentProfitPerPortion = 0.0;

  // Coloring system
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.deepOrange,
    Colors.cyan,
    Colors.brown,
  ];

  Color _getIngredientColor(String name) {
    final hash = name.hashCode.abs();
    return _availableColors[hash % _availableColors.length];
  }

  @override
  void initState() {
    super.initState();
    _yieldController.addListener(_calculateSummary);
    _profitMarginController.addListener(_onMarginChanged);
    _priceController.addListener(_onPriceChanged);

    _loadRecipeData();
  }

  Future<void> _loadRecipeData() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final detail = await db.getRecipeDetail(widget.recipeId);

      _nameController.text = detail.recipe.name;
      _descriptionController.text = detail.recipe.description ?? '';
      
      _isUpdating = true;
      _yieldController.text = _formatAmount(detail.recipe.defaultYield);
      _yieldNameController.text = detail.recipe.yieldName;
      _profitMarginController.text = (detail.recipe.targetProfitMargin * 100)
          .toStringAsFixed(0);
      _priceController.text = detail.recipe.targetPricePerPortion.toString();
      _isUpdating = false;

      for (var ingWithData in detail.ingredients) {
        final data = RecipeIngredientData(
          ingredient: ingWithData.ingredient,
          initialAmount: _formatAmount(ingWithData.entry.amountNeeded),
        );
        data.amountController.addListener(_calculateSummary);
        _ingredients.add(data);
      }

      for (var step in detail.steps) {
        _addStep(initialInstruction: step.instruction, shouldFocus: false);
      }

      if (_steps.isEmpty) _addStep(shouldFocus: false);

      _calculateSummary();
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onMarginChanged() {
    if (_isUpdating) return;
    _isUpdating = true;
    
    final margin = double.tryParse(_profitMarginController.text) ?? 0.0;
    if (_currentCostPerPortion > 0) {
      final newPrice = _currentCostPerPortion * (1 + (margin / 100.0));
      setState(() {
        _priceController.text = newPrice.toStringAsFixed(2);
      });
    }
    
    _isUpdating = false;
    _calculateSummary();
  }

  void _onPriceChanged() {
    if (_isUpdating) return;
    _isUpdating = true;
    
    final price = double.tryParse(_priceController.text) ?? 0.0;
    if (_currentCostPerPortion > 0) {
      final newMargin = ((price / _currentCostPerPortion) - 1) * 100.0;
      setState(() {
        _profitMarginController.text = newMargin.toStringAsFixed(0);
      });
    }
    
    _isUpdating = false;
    _calculateSummary();
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  void _addStep({String initialInstruction = '', int? atIndex, bool shouldFocus = true}) {
    setState(() {
      final controller = IngredientTextEditingController(
        text: initialInstruction,
        getIngredientColor: _getIngredientColor,
      );

      final newStep = RecipeStepData(
        initialInstruction: initialInstruction,
        customController: controller,
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

  void _addIngredient(Ingredient ingredient) {
    if (_ingredients.any(
      (i) => i.ingredient.ingredientPk == ingredient.ingredientPk,
    )) {
      return;
    }
    setState(() {
      final data = RecipeIngredientData(ingredient: ingredient);
      data.amountController.addListener(_calculateSummary);
      _ingredients.add(data);
      _calculateSummary();
    });
  }

  Future<void> _removeIngredient(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final ingredientToRemove = _ingredients[index].ingredient;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete_button),
        content: Text('${l10n.delete_button} ${ingredientToRemove.name}?'),
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
      setState(() {
        _ingredients[index].amountController.removeListener(_calculateSummary);
        _ingredients[index].amountController.dispose();
        _ingredients.removeAt(index);

        for (var step in _steps) {
          if (step.taggedIngredients.contains(ingredientToRemove)) {
            step.taggedIngredients.remove(ingredientToRemove);
            final pattern = '\\[${RegExp.escape(ingredientToRemove.name)}\\]';
            step.instructionController.text = step.instructionController.text
                .replaceAll(RegExp(pattern), '');
          }
        }

        _calculateSummary();
      });
    }
  }

  @override
  void dispose() {
    _yieldController.removeListener(_calculateSummary);
    _profitMarginController.removeListener(_onMarginChanged);
    _priceController.removeListener(_onPriceChanged);

    _nameController.dispose();
    _descriptionController.dispose();
    _yieldController.dispose();
    _yieldNameController.dispose();
    _profitMarginController.dispose();
    _priceController.dispose();

    for (var ingredient in _ingredients) {
      ingredient.amountController.dispose();
    }
    for (var step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  void _calculateSummary() {
    final summary = RecipeUtils.calculateSummaryFromIngredients(
      ingredients: _ingredients,
      yieldText: _yieldController.text,
      priceText: _priceController.text,
    );

    setState(() {
      _currentTotalCost = summary.totalCost;
      _currentRevenue = summary.revenue;
      _currentCostPerPortion = summary.costPerPortion;
      _currentProfitPerPortion = summary.profitPerPortion;
    });
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final db = ref.read(databaseProvider);
        final l10n = AppLocalizations.of(context)!;

        await RecipeUtils.saveRecipe(
          db: db,
          recipePk: widget.recipeId,
          name: _nameController.text,
          description: _descriptionController.text,
          yieldText: _yieldController.text,
          yieldName: _yieldNameController.text.isEmpty
              ? l10n.unit_portions.toLowerCase()
              : _yieldNameController.text,
          profitMarginText: _profitMarginController.text,
          priceText: _priceController.text,
          ingredients: _ingredients,
          steps: _steps,
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Handle error
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _nameController.text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {},
            tooltip: l10n.config_button,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Column 1: Financial Info List
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoRow(l10n.total_cost, _currentTotalCost),
                    const SizedBox(height: 2),
                    _buildInfoRow(
                      l10n.cost_per_portion,
                      _currentCostPerPortion,
                    ),
                    const SizedBox(height: 2),
                    _buildInfoRow(
                      l10n.profit_per_portion,
                      _currentProfitPerPortion,
                    ),
                    const Divider(height: 12, thickness: 0.5),
                    Text(
                      l10n.est_revenue,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 8,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '\$ ${_currentRevenue.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 20, thickness: 0.5),
              // Column 2: 2x2 Grid with Inputs and Save
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildLabeledSmallEntry(
                            controller: _profitMarginController,
                            label: l10n.financial_margin,
                            suffix: "%",
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildLabeledSmallEntry(
                            controller: _priceController,
                            label: l10n.financial_price,
                            suffix: "\$",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _buildLabeledSmallEntry(
                            height: 31,
                            controller: _yieldController,
                            label: l10n.unit_portions,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            height: 31, // Matches the small TextField height
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveRecipe,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      l10n.save_button.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                children: [
                  const SizedBox(height: 16),

                  // Description
                  if (_descriptionController.text.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(
                            () => _showDescription = !_showDescription,
                          ),
                          icon: Icon(
                            _showDescription
                                ? Icons.expand_less
                                : Icons.description_outlined,
                          ),
                          label: Text(l10n.recipe_description),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        if (_showDescription)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4.0,
                              right: 4.0,
                              bottom: 16.0,
                            ),
                            child: Text(
                              _descriptionController.text,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Ingredients Section
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
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _buildIngredientItem(index, units),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Error: $e'),
                    ),

                  const SizedBox(height: 32),

                  // Steps Section
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
                      itemBuilder: (context, index) => _buildStepItem(index),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
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

  Widget _buildInfoRow(String label, double value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 8.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '\$ ${value.toStringAsFixed(2)}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledSmallEntry({
    required TextEditingController controller,
    required String label,
    String? suffix,
    double? width,
    double? height,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 10.5,
        ),
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          labelStyle: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
          floatingLabelStyle: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 4,
          ),
          suffixText: suffix,
          suffixStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 8.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
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

  Widget _buildIngredientItem(int index, List<Unit> allUnits) {
    final data = _ingredients[index];
    final theme = Theme.of(context);

    final unit = allUnits.firstWhere(
      (u) => u.unitPk == data.ingredient.unitFk,
      orElse: () => const Unit(
        unitPk: '',
        name: '?',
        symbol: '?',
        isMutable: false,
        factorToBase: 1.0,
      ),
    );

    final translatedUnitName = RecipeUtils.translateUnitName(context, unit.name);
    final color = _getIngredientColor(data.ingredient.name);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.ingredient.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$ ${data.unitCost.toStringAsFixed(2)} / ${unit.symbol}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: \$ ${data.totalCost.toStringAsFixed(2)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Focus(
              onFocusChange: (hasFocus) {
                if (hasFocus) {
                  data.amountController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: data.amountController.text.length,
                  );
                }
              },
              child: TextField(
                controller: data.amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  hintText: '0',
                  suffixText: ' ${unit.symbol}',
                  suffixStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _calculateSummary();
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            color: theme.colorScheme.error,
            onPressed: () => _removeIngredient(index),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index) {
    final step = _steps[index];
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () =>
                    _showIngredientPickerForStep(index, isHeader: true),
                visualDensity: VisualDensity.compact,
                color: theme.colorScheme.primary,
                tooltip: l10n.assign_ingredients_tooltip,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: step.taggedIngredients
                        .map(
                          (ing) {
                            final color = _getIngredientColor(ing.name);
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: color.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  ing.name,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        )
                        .toList(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _removeStep(index),
                visualDensity: VisualDensity.compact,
                tooltip: l10n.delete_button,
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.5),
          LayoutBuilder(
            builder: (context, constraints) {
              final textStyle = theme.textTheme.bodyLarge ?? const TextStyle();

              final cursorOffset =
                  step.instructionController.selection.extentOffset;
              final textToMeasure = cursorOffset >= 0
                  ? step.instructionController.text.substring(0, cursorOffset)
                  : step.instructionController.text;

              final textPainter = TextPainter(
                text: TextSpan(text: textToMeasure, style: textStyle),
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);

              final lastOffset = textPainter.getOffsetForCaret(
                TextPosition(offset: textToMeasure.length),
                Rect.zero,
              );

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  TextField(
                    controller: step.instructionController,
                    focusNode: step.focusNode,
                    maxLines: null,
                    style: textStyle,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _addStep(atIndex: index),
                    decoration: InputDecoration(
                      hintText: l10n.step_instruction_hint,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 24, top: 4),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      if (value.endsWith('+')) {
                        step.instructionController.text = value.substring(
                          0,
                          value.length - 1,
                        );
                        _showIngredientPickerForStep(index, isHeader: false);
                      }
                    },
                  ),
                  if (step.instructionController.text.isNotEmpty)
                    Positioned(
                      left: lastOffset.dx,
                      top: lastOffset.dy + 5.5,
                      child: GestureDetector(
                        onTap: () => _showIngredientPickerForStep(
                          index,
                          isHeader: false,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 14,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showGlobalIngredientPicker() async {
    final db = ref.read(databaseProvider);
    final ingredients = await db.getAllIngredients();

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                l10n.select_ingredient_recipe_title,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ing = ingredients[index];
                    final color = _getIngredientColor(ing.name);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(alpha: 0.2),
                        child: Icon(Icons.egg_outlined, color: color, size: 20),
                      ),
                      title: Text(
                        ing.name,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        _addIngredient(ing);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showIngredientPickerForStep(int stepIndex, {required bool isHeader}) {
    final l10n = AppLocalizations.of(context)!;
    List<Ingredient> options;
    String title;

    if (isHeader) {
      options = _ingredients.map((e) => e.ingredient).toList();
      title = l10n.assign_to_step_title(stepIndex + 1);
    } else {
      options = _steps[stepIndex].taggedIngredients;
      title = l10n.mention_ingredient_title;
    }

    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isHeader
                ? l10n.add_ingredients_first_error
                : l10n.assign_step_ingredients_first_error,
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInternalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final ing = options[index];
                      final isTagged = _steps[stepIndex].taggedIngredients
                          .contains(ing);
                      final color = _getIngredientColor(ing.name);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.1),
                          radius: 14,
                          child: Icon(Icons.egg_outlined, color: color, size: 16),
                        ),
                        title: Text(
                          ing.name,
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                        trailing: isHeader && isTagged
                            ? Icon(
                                Icons.check_circle,
                                color: color,
                              )
                            : null,
                        onTap: () {
                          if (isHeader) {
                            setState(() {
                              if (!isTagged) {
                                _steps[stepIndex].taggedIngredients.add(ing);
                              } else {
                                _steps[stepIndex].taggedIngredients.remove(ing);
                                final pattern =
                                    '\\[${RegExp.escape(ing.name)}\\]';
                                _steps[stepIndex].instructionController.text =
                                    _steps[stepIndex].instructionController.text
                                        .replaceAll(RegExp(pattern), '');
                              }
                            });
                            setInternalState(() {});
                          } else {
                            setState(() {
                              final controller =
                                  _steps[stepIndex].instructionController;
                              final text = controller.text;
                              final selection = controller.selection;

                              String newText;
                              if (selection.start >= 0) {
                                newText = text.replaceRange(
                                  selection.start,
                                  selection.end,
                                  '[${ing.name}] ',
                                );
                              } else {
                                newText = '$text[${ing.name}] ';
                              }

                              controller.text = newText;
                              controller.selection = TextSelection.collapsed(
                                offset:
                                    (selection.start >= 0
                                        ? selection.start
                                        : text.length) +
                                    ing.name.length +
                                    3,
                              );
                            });
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
                ),
                if (isHeader)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.done_button),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class IngredientTextEditingController extends TextEditingController {
  final Color Function(String) getIngredientColor;

  IngredientTextEditingController({super.text, required this.getIngredientColor});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final List<InlineSpan> children = [];
    final regex = RegExp(r'(\[)([^\]]+)(\])');
    
    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final openBracket = match[1]!;
        final name = match[2]!;
        final closeBracket = match[3]!;
        final color = getIngredientColor(name);
        
        // Hide brackets using 0 font size or transparent color
        children.add(TextSpan(
          text: openBracket,
          style: style?.copyWith(fontSize: 0, color: Colors.transparent),
        ));
        
        children.add(TextSpan(
          text: name,
          style: style?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            backgroundColor: color.withValues(alpha: 0.1),
          ),
        ));

        children.add(TextSpan(
          text: closeBracket,
          style: style?.copyWith(fontSize: 0, color: Colors.transparent),
        ));
        
        return '';
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }
}
