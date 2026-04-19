import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';

const uuid = Uuid();

class RecipeIngredientData {
  final Ingredient ingredient;
  final TextEditingController amountController;

  RecipeIngredientData({
    required this.ingredient,
    String initialAmount = '0',
  }) : amountController = TextEditingController(text: initialAmount);

  double get amount => double.tryParse(amountController.text) ?? 0.0;
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
  })  : instructionController = TextEditingController(text: initialInstruction),
        focusNode = FocusNode(),
        taggedIngredients = taggedIngredients ?? [];

  void dispose() {
    instructionController.dispose();
    focusNode.dispose();
  }
}

class RecipeFinancialSummary {
  final double totalCost;
  final double revenue;
  final double costPerPortion;
  final double profitPerPortion;
  final double profitMargin;

  RecipeFinancialSummary({
    required this.totalCost,
    required this.revenue,
    required this.costPerPortion,
    required this.profitPerPortion,
    required this.profitMargin,
  });
}

class RecipeUtils {
  /// Base logic for financial calculations
  static RecipeFinancialSummary calculateFinancials({
    required double totalIngredientsCost,
    required double yieldVal,
    required double pricePerPortion,
  }) {
    final totalGrossRevenue = pricePerPortion * yieldVal;
    final currentRevenue = totalGrossRevenue - totalIngredientsCost;
    
    final costPortion = yieldVal > 0 ? totalIngredientsCost / yieldVal : 0.0;
    final profitPortion = yieldVal > 0 ? currentRevenue / yieldVal : 0.0;
    final margin = totalGrossRevenue > 0 ? (currentRevenue / totalGrossRevenue) * 100 : 0.0;

    return RecipeFinancialSummary(
      totalCost: totalIngredientsCost,
      revenue: currentRevenue,
      costPerPortion: costPortion,
      profitPerPortion: profitPortion,
      profitMargin: margin,
    );
  }

  /// Calculates financials from UI models (Form)
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
      yieldVal: double.tryParse(yieldText) ?? 0.0,
      pricePerPortion: double.tryParse(priceText) ?? 0.0,
    );
  }

  /// Calculates financials from database objects (View)
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
    final parsedYield = double.tryParse(yieldText) ?? 1.0;
    final parsedPrice = double.tryParse(priceText) ?? 0.0;
    final rawMargin = double.tryParse(profitMarginText) ?? 0.0;
    final decimalMargin = rawMargin / 100.0;

    final actualRecipePk = recipePk ?? uuid.v4();

    final recipeCompanion = RecipesCompanion.insert(
      recipePk: drift.Value(actualRecipePk),
      name: name.trim(),
      description: drift.Value(description.trim()),
      defaultYield: parsedYield,
      yieldName: yieldName.trim().isEmpty ? 'portions' : yieldName.trim(),
      targetProfitMargin: drift.Value(decimalMargin),
      targetPricePerPortion: drift.Value(parsedPrice),
    );

    await db.transaction(() async {
      // 1. Update or Insert main recipe
      if (recipePk != null) {
        await (db.update(db.recipes)
              ..where((t) => t.recipePk.equals(actualRecipePk)))
            .write(recipeCompanion);
      } else {
        await db.insertRecipe(recipeCompanion);
      }

      // 2. Clear and re-insert ingredients
      await (db.delete(db.recipeIngredients)
            ..where((t) => t.recipeFk.equals(actualRecipePk)))
          .go();

      for (var ingData in ingredients) {
        await db.into(db.recipeIngredients).insert(
              RecipeIngredientsCompanion.insert(
                recipeFk: actualRecipePk,
                ingredientFk: ingData.ingredient.ingredientPk,
                amountNeeded: ingData.amount,
              ),
            );
      }

      // 3. Clear and re-insert steps
      await (db.delete(db.recipeSteps)
            ..where((t) => t.recipeFk.equals(actualRecipePk)))
          .go();

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
