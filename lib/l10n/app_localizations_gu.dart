// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get recipes_title => 'Recipes';

  @override
  String get new_recipe_title => 'New Recipe';

  @override
  String get recipe_title => 'Recipe';

  @override
  String get ingredients_title => 'Ingredients';

  @override
  String get units_title => 'Units';

  @override
  String get recipe_name => 'Recipe Name';

  @override
  String get recipe_description => 'Description';

  @override
  String get recipe_description_hint => 'Short description of the recipe...';

  @override
  String get recipe_yield => 'Default Yield';

  @override
  String get recipe_yield_name => 'Yield Unit (e.g. cookies)';

  @override
  String get target_profit_margin => 'Target Profit Margin';

  @override
  String get target_price_portion => 'Target Price per Portion';

  @override
  String get fixed_overhead => 'Fixed Overhead Cost';

  @override
  String get total_cost => 'Total Cost';

  @override
  String get profit_per_recipe => 'Profit per Recipe';

  @override
  String get ingredient_name => 'Ingredient Name';

  @override
  String get ingredient_cost => 'Cost';

  @override
  String get ingredient_quantity => 'Quantity';

  @override
  String get unit_grams => 'Grams';

  @override
  String get unit_kilograms => 'Kilograms';

  @override
  String get unit_milliliters => 'Milliliters';

  @override
  String get unit_liters => 'Liters';

  @override
  String get unit_pieces => 'Pieces';

  @override
  String get unit_spoonfuls => 'Spoonfuls';

  @override
  String get unit_tablespoons => 'Tablespoons';

  @override
  String get unit_teaspoons => 'Teaspoons';

  @override
  String get unit_cups => 'Cups';

  @override
  String get unit_ounces => 'Ounces';

  @override
  String get step_instruction => 'Instruction';

  @override
  String get step_instruction_hint => 'Describe the step...';

  @override
  String get save_button => 'Save';

  @override
  String get delete_button => 'Delete';

  @override
  String get config_button => 'Settings';

  @override
  String get recipe_steps => 'Steps';

  @override
  String get no_steps => 'No steps added yet.';

  @override
  String get est_revenue => 'Est. Revenue';

  @override
  String get financial_targets => 'Financial Targets';

  @override
  String get no_ingredients => 'No ingredients added yet.';

  @override
  String get unit_portions => 'Portions';

  @override
  String get cost_per_portion => 'Cost per Portion';

  @override
  String get profit_per_portion => 'Profit per Portion';

  @override
  String get validation_required => 'Required';

  @override
  String get profit_margin_helper => 'Enter whole numbers (e.g., 35 for 35%)';

  @override
  String get assign_ingredients_tooltip => 'Assign ingredients to this step';

  @override
  String get select_ingredient_recipe_title => 'Select Ingredient for Recipe';

  @override
  String assign_to_step_title(int number) {
    return 'Assign to Step $number';
  }

  @override
  String get mention_ingredient_title => 'Mention Ingredient';

  @override
  String get add_ingredients_first_error =>
      'Add ingredients to the recipe first';

  @override
  String get assign_step_ingredients_first_error =>
      'Assign ingredients to the step header (+)';

  @override
  String get done_button => 'Done';
}
