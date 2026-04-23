import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../provider/database_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/recipe_utils.dart';
import '../utils/ingredient_text_editing_controller.dart';

class RecipeEditorScreen extends ConsumerStatefulWidget {
  final String? recipeId;
  const RecipeEditorScreen({super.key, this.recipeId});

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isCalculating = false;
  bool _isDescriptionExpanded = true;

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
    _isDescriptionExpanded = widget.recipeId == null;
    _yieldController.addListener(_calculateSummary);
    _priceController.addListener(_calculateSummary);
    _profitMarginController.addListener(_calculateSummary);
    _totalSaleController.addListener(_calculateSummary);

    if (widget.recipeId != null) {
      _loadRecipeData();
    } else {
      // Initial empty step for new recipes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _addStep(shouldFocus: false);
      });
    }
  }

  Future<void> _loadRecipeData() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final detail = await db.getRecipeDetail(widget.recipeId!);
      if (!mounted) return;
      final theme = Theme.of(context);

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
        final data = RecipeIngredientData(
          ingredient: ingWithData.ingredient,
          initialAmount: RecipeUtils.formatNumber(
            ingWithData.entry.amountNeeded,
            decimalDigits: 2,
          ),
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

      _calculateSummary();
    } catch (e) {
      // error handling
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final ingredientToRemove = _ingredients[index].ingredient;
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

          if (step.taggedIngredients.contains(ingredientToRemove)) {
            step.taggedIngredients.remove(ingredientToRemove);
            final pattern = RegExp.escape(ingredientToRemove.name);
            controller.text = controller.text.replaceAll(RegExp(pattern), '');
          }
        }
      }
      _calculateSummary();
    });
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

    final appBarTitle = widget.recipeId == null
        ? l10n.new_recipe_title
        : (_nameController.text.isEmpty
              ? l10n.recipe_title
              : _nameController.text);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: const BackButton(),
        title: Text(
          appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveRecipe,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomFinancials(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 22.0),
                children: [
                  const SizedBox(height: 16),
                  if (widget.recipeId == null) ...[
                    _buildCustomTextField(
                      controller: _nameController,
                      label: l10n.recipe_name,
                      hint: l10n.recipe_name,
                      validator: (value) => (value == null || value.isEmpty)
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
                          _isDescriptionExpanded = !_isDescriptionExpanded;
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
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildIngredientItem(
                          index,
                          theme.colorScheme,
                          units,
                        ),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(e.toString())),
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
    );
  }

  Widget _buildBottomFinancials(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
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
            // Left Column: Values
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow(l10n.total_cost, _currentTotalCost),
                  const SizedBox(height: 2),
                  _buildInfoRow(l10n.total_sale, _currentTotalRevenue),
                  const SizedBox(height: 2),
                  _buildInfoRow(l10n.cost_per_portion, _currentCostPerPortion),
                  const SizedBox(height: 2),
                  _buildInfoRow(
                    l10n.profit_per_portion,
                    _currentProfitPerPortion,
                  ),
                  const SizedBox(height: 2),
                  _buildInfoRow(
                    l10n.financial_price,
                    RecipeUtils.parseFormattedNumber(_priceController.text),
                  ),
                  const Divider(height: 10, thickness: 0.5),
                  Text(
                    l10n.total_profit,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 8,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$ ${RecipeUtils.formatNumber(_currentRevenue, decimalDigits: 2)}',
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
            // Right Column: User Inputs
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLabelInputRow(
                    l10n.financial_margin,
                    _profitMarginController,
                    "%",
                    _profitMarginFocusNode,
                  ),
                  const SizedBox(height: 6),
                  _buildLabelInputRow(
                    l10n.financial_price,
                    _priceController,
                    "\$",
                    _priceFocusNode,
                  ),
                  const SizedBox(height: 6),
                  _buildLabelInputRow(
                    l10n.unit_portions,
                    _yieldController,
                    null,
                    _yieldFocusNode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelInputRow(
    String label,
    TextEditingController controller,
    String? suffix,
    FocusNode? focusNode,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 5,
          child: _buildLabeledSmallEntry(
            controller: controller,
            label: "",
            suffix: suffix,
            focusNode: focusNode,
            height: 32,
          ),
        ),
      ],
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
          '\$ ${RecipeUtils.formatNumber(value, decimalDigits: 2)}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: 10,
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

  Widget _buildLabeledSmallEntry({
    required TextEditingController controller,
    required String label,
    String? suffix,
    double? width,
    double? height,
    FocusNode? focusNode,
    double fontSize = 10,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: height ?? 31,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        onTap: () {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: label,
          hintStyle: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            fontSize: fontSize * 0.8,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 2,
          ),
          suffixText: suffix,
          suffixStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: fontSize * 0.8,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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

  Widget _buildIngredientItem(
    int index,
    ColorScheme colorScheme,
    List<Unit> units,
  ) {
    final data = _ingredients[index];
    final theme = Theme.of(context);
    final itemColor = RecipeUtils.getIngredientColor(
      data.ingredient.name,
      colorScheme,
    );

    final unitSymbol = units
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                const SizedBox(height: 8),
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
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
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
                Text(
                  '\$${RecipeUtils.formatNumber(data.ingredient.cost)} per ${RecipeUtils.formatNumber(data.ingredient.quantityForCost)} $unitSymbol',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.end,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$ ${RecipeUtils.formatNumber(data.totalCost, decimalDigits: 2)}',
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
            onPressed: () => _removeIngredient(index),
            visualDensity: VisualDensity.compact,
          ),
        ],
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
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: step.taggedIngredients.map((ing) {
                        final color = RecipeUtils.getIngredientColor(
                          ing.name,
                          colorScheme,
                        );
                        return Container(
                          margin: const EdgeInsets.only(right: 6.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            ing.name,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
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
            LayoutBuilder(
              builder: (context, constraints) {
                final textStyle =
                    theme.textTheme.bodyLarge ?? const TextStyle();
                final cursorOffset =
                    step.instructionController.selection.extentOffset;

                final fullSpan = step.instructionController.buildTextSpan(
                  context: context,
                  style: textStyle,
                  withComposing: false,
                );

                final textPainter = TextPainter(
                  text: fullSpan,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth);

                final lastOffset = textPainter.getOffsetForCaret(
                  TextPosition(
                    offset: (cursorOffset >= 0
                        ? cursorOffset
                        : step.instructionController.text.length),
                  ),
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
                        contentPadding: const EdgeInsets.only(
                          bottom: 24,
                          top: 4,
                        ),
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
                            child: const Icon(Icons.add, size: 14),
                          ),
                        ),
                      ),
                  ],
                );
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.select_ingredient_recipe_title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (selectedInModal.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedInModal.forEach((_, value) {
                            final ing = value.$1;
                            final controller = value.$2;

                            if (!_ingredients.any(
                              (i) =>
                                  i.ingredient.ingredientPk == ing.ingredientPk,
                            )) {
                              final data = RecipeIngredientData(
                                ingredient: ing,
                                initialAmount: controller.text,
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
                        "${l10n.add_button} (${selectedInModal.length})",
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  final query = ref.watch(searchQueryProvider);
                  return TextField(
                    onChanged: (val) =>
                        ref.read(searchQueryProvider.notifier).setQuery(val),
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
                                        '\$${RecipeUtils.formatNumber(ing.cost)} / ${RecipeUtils.formatNumber(ing.quantityForCost)} $unit',
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
                                            textAlign: TextAlign.end,
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              suffixText: unitsAsync.maybeWhen(
                                                data: (units) => units
                                                    .firstWhere(
                                                      (u) =>
                                                          u.unitPk ==
                                                          ing.unitFk,
                                                    )
                                                    .symbol,
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
            ],
          ),
        ),
      ),
    );
  }

  void _showIngredientPickerForStep(int stepIndex, {required bool isHeader}) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
      builder: (context) => StatefulBuilder(
        builder: (context, setInternalState) => Column(
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
                  final isTagged = _steps[stepIndex].taggedIngredients.contains(
                    ing,
                  );
                  final itemColor = RecipeUtils.getIngredientColor(
                    ing.name,
                    theme.colorScheme,
                  );
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: itemColor.withValues(alpha: 0.2),
                      child: Icon(Icons.circle, size: 12, color: itemColor),
                    ),
                    title: Text(ing.name),
                    trailing: isHeader && isTagged
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
                        : null,
                    onTap: () {
                      if (isHeader) {
                        setState(() {
                          if (!isTagged) {
                            _steps[stepIndex].taggedIngredients.add(ing);
                          } else {
                            _steps[stepIndex].taggedIngredients.remove(ing);
                            final pattern = RegExp.escape(ing.name);
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
                          String newText = selection.start >= 0
                              ? text.replaceRange(
                                  selection.start,
                                  selection.end,
                                  '${ing.name} ',
                                )
                              : '$text${ing.name} ';
                          controller.text = newText;
                          controller.selection = TextSelection.collapsed(
                            offset:
                                (selection.start >= 0
                                    ? selection.start
                                    : text.length) +
                                ing.name.length +
                                1,
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
        ),
      ),
    );
  }
}
