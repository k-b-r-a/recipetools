// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

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
  String get add_button => 'Add';

  @override
  String get delete_button => 'Delete';

  @override
  String get config_button => 'Settings';

  @override
  String get recipe_steps => 'Steps';

  @override
  String get tools_title => 'Tools';

  @override
  String get no_steps => 'No steps added yet.';

  @override
  String get est_revenue => 'Est. Revenue';

  @override
  String get financial_targets => 'Financial Targets';

  @override
  String get financial_margin => 'Total Margin';

  @override
  String get financial_price => 'Price per Portion';

  @override
  String get no_ingredients => 'No ingredients added yet.';

  @override
  String get unit_portions => 'Portions';

  @override
  String get cost_per_portion => 'Cost per Portion';

  @override
  String get profit_per_portion => 'Profit per Portion';

  @override
  String get total_profit => 'Total Profit';

  @override
  String get total_sale => 'Total Sale';

  @override
  String get sale_per_portion => 'Sale per Portion';

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

  @override
  String get add_ingredient_title => 'Add Ingredient';

  @override
  String get edit_ingredient_title => 'Edit Ingredient';

  @override
  String get select_unit => 'Select Unit';

  @override
  String ingredient_price_per_quantity(
    String price,
    String quantity,
    String unit,
  ) {
    return '\$$price per $quantity $unit';
  }

  @override
  String get search_hint => 'Search...';

  @override
  String get search_ingredients_hint => 'Type to search ingredients...';

  @override
  String get no_ingredients_found => 'No ingredients found.';

  @override
  String get no_recipes_found => 'No recipes found.';

  @override
  String get related_ingredients => 'Related';

  @override
  String get no_similar_ingredients => 'No similar ingredients';

  @override
  String get merge_button => 'Merge';

  @override
  String get compare_button => 'Compare';

  @override
  String get merge_confirm_title => 'Merge Ingredients?';

  @override
  String merge_confirm_message(String oldName, String newName) {
    return 'This will replace all references to $oldName with $newName in your recipes. This action cannot be undone.';
  }

  @override
  String get price_comparison => 'Price Comparison';

  @override
  String get error_select_unit => 'Please select a unit';

  @override
  String error_prefix(String error) {
    return 'Error: $error';
  }

  @override
  String get short_cost => 'COST';

  @override
  String get short_profit => 'PROFIT';

  @override
  String get short_price_portion => 'P/PORTION';

  @override
  String get per_unit => 'per';

  @override
  String get error_text => 'Error';

  @override
  String get scale_recipe_tooltip => 'Scale recipe (temporary view)';

  @override
  String get temporary_view_title => 'Temporary View';

  @override
  String temporary_view_banner(String multiplier) {
    return 'This is a temporary view scaled by ${multiplier}x. Changes will not be saved.';
  }

  @override
  String get scale_button => 'Scale';

  @override
  String get rule_of_three_title => 'Rule of Three';

  @override
  String get rule_of_three_desc =>
      'Calculate proportions easily for ingredient quantities and recipe yields.';

  @override
  String get rule_of_three_if => 'If';

  @override
  String get rule_of_three_corresponds => 'corresponds to';

  @override
  String get rule_of_three_then => 'Then';

  @override
  String get rule_of_three_will_be => 'will be';

  @override
  String get rule_of_three_result => 'Result';

  @override
  String get rule_of_three_clear => 'Clear';

  @override
  String get rule_of_three_example =>
      'Example: If 100g of flour makes 10 portions, then to make 25 portions you need 250g of flour.';

  @override
  String get unit_converter_title => 'Unit Converter';

  @override
  String get unit_converter_desc =>
      'Convert cooking units for mass, volume, and quantities easily.';

  @override
  String get unit_converter_category => 'Category';

  @override
  String get unit_converter_from => 'From';

  @override
  String get unit_converter_to => 'To';

  @override
  String get unit_converter_value => 'Value';

  @override
  String get unit_converter_result => 'Result';

  @override
  String get unit_category_mass => 'Weight / Mass';

  @override
  String get unit_category_volume => 'Volume';

  @override
  String get unit_category_count => 'Count / Quantity';

  @override
  String get settings_general => 'General Settings';

  @override
  String get settings_reset_db => 'Reset Database';

  @override
  String get settings_reset_db_desc =>
      'Delete all recipes and ingredients. This cannot be undone.';

  @override
  String get settings_reset_db_confirm => 'Reset Database?';

  @override
  String get settings_reset_db_warning =>
      'Are you sure you want to delete all recipes, ingredients, and steps? This action is permanent.';

  @override
  String get settings_reset_db_success => 'Database reset successfully.';

  @override
  String get settings_theme_title => 'Theme & Style';

  @override
  String get settings_theme_mode => 'Theme Mode';

  @override
  String get settings_theme_color => 'Accent Color';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_locale_title => 'Localization & Formatting';

  @override
  String get settings_locale_lang => 'Language';

  @override
  String get settings_locale_es => 'Spanish';

  @override
  String get settings_locale_en => 'English';

  @override
  String get settings_format_decimals => 'Decimal Places';

  @override
  String get settings_about => 'About';

  @override
  String get settings_version => 'Version';
}
