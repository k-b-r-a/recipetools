import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../l10n/app_localizations.dart';

const uuid = Uuid();

class RecipeIngredientData {
  final Ingredient ingredient;
  final TextEditingController amountController;

  RecipeIngredientData({
    required this.ingredient,
    String initialAmount = '0',
  }) : amountController = TextEditingController(text: initialAmount);

  double get amount => RecipeUtils.parseFormattedNumber(amountController.text);
  double get unitCost => ingredient.cost / ingredient.quantityForCost;
  double get totalCost => unitCost * amount;
}

class RecipeStepData {
  final TextEditingController instructionController;
  final FocusNode focusNode;
  final List<Ingredient> taggedIngredients;

  RecipeStepData({
    String initialInstruction = '',
    List<Ingredient>? taggedIngredients,
    TextEditingController? customController,
  })  : instructionController = customController ?? TextEditingController(text: initialInstruction),
        focusNode = FocusNode(),
        taggedIngredients = taggedIngredients ?? [];

  void dispose() {
    instructionController.dispose();
    focusNode.dispose();
  }
}

class RecipeFinancialSummary {
  final double totalCost;
  final double totalRevenue; // Gross: Price * Yield
  final double totalProfit; // Net: Revenue - Cost
  final double costPerPortion;
  final double profitPerPortion;
  final double profitMargin; // Markup %: (Profit / Cost) * 100

  RecipeFinancialSummary({
    required this.totalCost,
    required this.totalRevenue,
    required this.totalProfit,
    required this.costPerPortion,
    required this.profitPerPortion,
    required this.profitMargin,
  });
}

class RecipeUtils {
  /// formats numbers with dots as thousands separator (e.g. 1.000)
  static String formatNumber(num value, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern('es_ES'); // uses dot for thousands
    if (decimalDigits > 0) {
      formatter.minimumFractionDigits = decimalDigits;
      formatter.maximumFractionDigits = decimalDigits;
    }
    return formatter.format(value);
  }

  /// Parses a number string that might contain thousands separators (dots) and decimal commas
  static double parseFormattedNumber(String text) {
    if (text.isEmpty) return 0.0;
    // Remove dots (thousands) and replace comma with dot (decimal)
    String clean = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }

  /// generates a theme-compliant color based on a string (ingredient name)
  /// ensures dark colors in light mode and pastel colors in dark mode for contrast
  static Color getIngredientColor(String name, ColorScheme colorScheme) {
    final int hash = name.hashCode;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    final List<Color> palette = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    
    Color baseColor = palette[hash.abs() % palette.length];
    
    if (isDark) {
      // make it lighter/pastel for dark mode
      return HSLColor.fromColor(baseColor)
          .withLightness(0.7)
          .withSaturation(0.6)
          .toColor();
    } else {
      // make it darker for light mode
      return HSLColor.fromColor(baseColor)
          .withLightness(0.3)
          .withSaturation(0.8)
          .toColor();
    }
  }

  /// base logic for financial calculations
  static RecipeFinancialSummary calculateFinancials({
    required double totalIngredientsCost,
    required double yieldVal,
    required double pricePerPortion,
  }) {
    final totalRevenue = pricePerPortion * yieldVal;
    final totalProfit = totalRevenue - totalIngredientsCost;
    
    final costPortion = yieldVal > 0 ? totalIngredientsCost / yieldVal : 0.0;
    final profitPortion = yieldVal > 0 ? totalProfit / yieldVal : 0.0;
    
    // Markup logic: (Profit / Cost) * 100
    final markup = totalIngredientsCost > 0 
        ? (totalProfit / totalIngredientsCost) * 100 
        : 0.0;

    return RecipeFinancialSummary(
      totalCost: totalIngredientsCost,
      totalRevenue: totalRevenue,
      totalProfit: totalProfit,
      costPerPortion: costPortion,
      profitPerPortion: profitPortion,
      profitMargin: markup,
    );
  }

  /// Calculates the required price per portion to achieve a specific markup margin
  static double calculatePriceFromMarkup({
    required double totalIngredientsCost,
    required double yieldVal,
    required double targetMarkupPercent,
  }) {
    if (yieldVal <= 0) return 0.0;
    final targetRevenue = totalIngredientsCost * (1 + (targetMarkupPercent / 100));
    return targetRevenue / yieldVal;
  }

  /// converts a value from one unit to another within the same category.
  static double convert({
    required double value,
    required Unit from,
    required Unit to,
  }) {
    if (from.category != to.category || from.category == null) {
      return value;
    }
    final valueInBase = value * from.factorToBase;
    return valueInBase / to.factorToBase;
  }

  /// translates unit names from their database keys (e.g., 'unit_grams' -> 'grams')
  static String translateUnitName(BuildContext context, String unitKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (unitKey) {
      case 'unit_grams':
        return l10n.unit_grams;
      case 'unit_kilograms':
        return l10n.unit_kilograms;
      case 'unit_milliliters':
        return l10n.unit_milliliters;
      case 'unit_liters':
        return l10n.unit_liters;
      case 'unit_pieces':
        return l10n.unit_pieces;
      case 'unit_spoonfuls':
        return l10n.unit_spoonfuls;
      case 'unit_tablespoons':
        return l10n.unit_tablespoons;
      case 'unit_teaspoons':
        return l10n.unit_teaspoons;
      case 'unit_cups':
        return l10n.unit_cups;
      case 'unit_ounces':
        return l10n.unit_ounces;
      default:
        return unitKey;
    }
  }

  /// calculates financials from ui models (form)
  static RecipeFinancialSummary calculateSummaryFromIngredients({
    required List<RecipeIngredientData> ingredients,
    required String yieldText,
    required String priceText,
  }) {
    double totalCost = 0.0;
    for (var ing in ingredients) {
      totalCost += ing.totalCost;
    }
    return calculateFinancials(
      totalIngredientsCost: totalCost,
      yieldVal: parseFormattedNumber(yieldText),
      pricePerPortion: parseFormattedNumber(priceText),
    );
  }

  /// calculates financials from database objects (view)
  static RecipeFinancialSummary calculateSummaryFromDetail(RecipeDetail detail) {
    double totalCost = 0.0;
    for (var ingWithData in detail.ingredients) {
      final unitCost = ingWithData.ingredient.cost / ingWithData.ingredient.quantityForCost;
      totalCost += unitCost * ingWithData.entry.amountNeeded;
    }
    return calculateFinancials(
      totalIngredientsCost: totalCost,
      yieldVal: detail.recipe.defaultYield,
      pricePerPortion: detail.recipe.targetPricePerPortion,
    );
  }

  static Future<void> saveRecipe({
    required AppDatabase db,
    String? recipePk,
    required String name,
    required String description,
    required String yieldText,
    required String yieldName,
    required String profitMarginText,
    required String priceText,
    required List<RecipeIngredientData> ingredients,
    required List<RecipeStepData> steps,
  }) async {
    final parsedYield = parseFormattedNumber(yieldText);
    final parsedPrice = parseFormattedNumber(priceText);
    final rawMargin = parseFormattedNumber(profitMarginText);
    final decimalMargin = rawMargin / 100.0;

    final actualRecipePk = recipePk ?? uuid.v4();

    final recipeCompanion = RecipesCompanion(
      recipePk: drift.Value(actualRecipePk),
      name: drift.Value(name.trim()),
      description: drift.Value(description.trim()),
      defaultYield: drift.Value(parsedYield <= 0 ? 1.0 : parsedYield),
      yieldName: drift.Value(yieldName.trim().isEmpty ? 'portions' : yieldName.trim()),
      targetProfitMargin: drift.Value(decimalMargin),
      targetPricePerPortion: drift.Value(parsedPrice),
      dateTimeModified: drift.Value(DateTime.now()),
    );

    await db.transaction(() async {
      if (recipePk != null) {
        await (db.update(db.recipes)..where((t) => t.recipePk.equals(actualRecipePk))).write(recipeCompanion);
      } else {
        await db.insertRecipe(recipeCompanion);
      }

      await (db.delete(db.recipeIngredients)..where((t) => t.recipeFk.equals(actualRecipePk))).go();

      for (var ingData in ingredients) {
        await db.into(db.recipeIngredients).insert(
              RecipeIngredientsCompanion.insert(
                recipeFk: actualRecipePk,
                ingredientFk: ingData.ingredient.ingredientPk,
                amountNeeded: ingData.amount,
              ),
            );
      }

      await (db.delete(db.recipeSteps)..where((t) => t.recipeFk.equals(actualRecipePk))).go();

      for (int i = 0; i < steps.length; i++) {
        final step = _mapToCompanion(actualRecipePk, i, steps[i]);
        await db.into(db.recipeSteps).insert(step);
      }
    });
  }

  static RecipeStepsCompanion _mapToCompanion(String recipePk, int index, RecipeStepData step) {
    return RecipeStepsCompanion.insert(
      recipeFk: recipePk,
      stepNumber: index + 1,
      instruction: step.instructionController.text.trim(),
    );
  }
}
