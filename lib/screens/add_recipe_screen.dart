import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../provider/database_provider.dart';
import '../l10n/app_localizations.dart';
import '../utils/recipe_utils.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

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

  @override
  void initState() {
    super.initState();
    _yieldController.addListener(_calculateSummary);
    _priceController.addListener(_calculateSummary);
    _profitMarginController.addListener(_calculateSummary);

    // Initialize with one empty step
    _addStep();
  }

  void _addStep({int? atIndex}) {
    setState(() {
      final newStep = RecipeStepData();
      if (atIndex != null && atIndex < _steps.length) {
        _steps.insert(atIndex + 1, newStep);
      } else {
        _steps.add(newStep);
      }
      // Wait for next frame to focus
      WidgetsBinding.instance.addPostFrameCallback((_) {
        newStep.focusNode.requestFocus();
      });
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

  void _removeIngredient(int index) {
    final ingredientToRemove = _ingredients[index].ingredient;
    setState(() {
      _ingredients[index].amountController.removeListener(_calculateSummary);
      _ingredients[index].amountController.dispose();
      _ingredients.removeAt(index);

      // Cleanup: remove from all step tags and text
      for (var step in _steps) {
        if (step.taggedIngredients.contains(ingredientToRemove)) {
          step.taggedIngredients.remove(ingredientToRemove);
          // Remove from text via regex: [name]
          final pattern = '\\[${RegExp.escape(ingredientToRemove.name)}\\]';
          step.instructionController.text = step.instructionController.text
              .replaceAll(RegExp(pattern), '');
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
      final db = ref.read(databaseProvider);
      final l10n = AppLocalizations.of(context)!;

      await RecipeUtils.saveRecipe(
        db: db,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Initial value for yield unit if empty
    if (_yieldNameController.text.isEmpty) {
      _yieldNameController.text = l10n.unit_portions.toLowerCase();
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.recipe_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                size: 28,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                // TODO: Settings/Config menu
              },
              tooltip: l10n.config_button,
            ),
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
          left: 22,
          right: 22,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildMiniInfo(l10n.total_cost, _currentTotalCost),
                    const SizedBox(width: 12),
                    _buildMiniInfo(
                      l10n.cost_per_portion,
                      _currentCostPerPortion,
                    ),
                    const SizedBox(width: 12),
                    _buildMiniInfo(
                      l10n.profit_per_portion,
                      _currentProfitPerPortion,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.est_revenue,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '\$ ${_currentRevenue.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _saveRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.check_circle, size: 20),
              label: Text(
                l10n.save_button,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          children: [
            const SizedBox(height: 20),

            // Header fields
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildFloatingTextField(
                    controller: _nameController,
                    label: l10n.recipe_name,
                    icon: Icons.cake_outlined,
                    autofocus: true,
                    validator: (value) => value == null || value.isEmpty
                        ? l10n.validation_required
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _buildFloatingTextField(
                    controller: _yieldController,
                    label: l10n.unit_portions,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description field
            _buildCustomTextField(
              controller: _descriptionController,
              label: l10n.recipe_description,
              hint: l10n.recipe_description_hint,
              icon: Icons.description_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Financial Section
            _buildSectionHeader(l10n.financial_targets),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildValueEntry(
                    controller: _profitMarginController,
                    label: l10n.target_profit_margin,
                    suffix: '%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildValueEntry(
                    controller: _priceController,
                    label: l10n.target_price_portion,
                    prefix: '\$',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

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
              _buildEmptyPlaceholder(l10n.no_ingredients, Icons.restaurant_menu)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildIngredientItem(index),
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
              _buildEmptyPlaceholder(l10n.no_steps, Icons.format_list_numbered)
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

  Widget _buildIngredientItem(int index) {
    final data = _ingredients[index];
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.ingredient.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$ ${data.unitCost.toStringAsFixed(3)} / unit',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: data.amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                border: InputBorder.none,
                hintText: '0.0',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            color: theme.colorScheme.error,
            onPressed: () => _removeIngredient(index),
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
                          (ing) => Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Text(
                              ing.name,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                  Positioned(
                    left: lastOffset.dx,
                    top: lastOffset.dy + 8, // Adjusted for text level alignment
                    child: GestureDetector(
                      onTap: () =>
                          _showIngredientPickerForStep(index, isHeader: false),
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
                    return ListTile(
                      title: Text(ing.name),
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

                      return ListTile(
                        title: Text(ing.name),
                        trailing: isHeader && isTagged
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
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

  Widget _buildMiniInfo(String label, double value) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        Text(
          '\$ ${value.toStringAsFixed(2)}',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
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

  Widget _buildFloatingTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: textAlign,
      validator: validator,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.1,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        labelStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.2,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueEntry({
    required TextEditingController controller,
    required String label,
    String prefix = '',
    String suffix = '',
  }) {
    final theme = Theme.of(context);
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
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (prefix.isNotEmpty)
                Text(
                  prefix,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (suffix.isNotEmpty)
                Text(
                  suffix,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class RoundedRectangleSection {
  static const borderRadius15 = BorderRadius.all(Radius.circular(15));
}
