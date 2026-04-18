// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get recipes_title => 'Recipes';

  @override
  String get ingredients_title => 'Ingredients';

  @override
  String get units_title => 'Units';

  @override
  String get recipe_name => 'Recipe Name';

  @override
  String get recipe_description => 'Description';

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
  String get unit_spoonfuls => 'Spoonfuls';

  @override
  String get step_instruction => 'Instruction';

  @override
  String get save_button => 'Save';

  @override
  String get delete_button => 'Delete';
}
