// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get recipes_title => 'Recetas';

  @override
  String get new_recipe_title => 'Nueva Receta';

  @override
  String get recipe_title => 'Receta';

  @override
  String get ingredients_title => 'Ingredientes';

  @override
  String get units_title => 'Unidades';

  @override
  String get recipe_name => 'Nombre de la Receta';

  @override
  String get recipe_description => 'Descripción';

  @override
  String get recipe_description_hint => 'Breve descripción de la receta...';

  @override
  String get recipe_yield => 'Rendimiento';

  @override
  String get recipe_yield_name => 'Unidad (ej. galletas)';

  @override
  String get target_profit_margin => 'Margen de Ganancia (%)';

  @override
  String get target_price_portion => 'Precio por Porción';

  @override
  String get fixed_overhead => 'Gastos Fijos';

  @override
  String get total_cost => 'Costo Total';

  @override
  String get profit_per_recipe => 'Ganancia por Receta';

  @override
  String get ingredient_name => 'Nombre del Ingrediente';

  @override
  String get ingredient_cost => 'Costo';

  @override
  String get ingredient_quantity => 'Cantidad';

  @override
  String get unit_grams => 'Gramos';

  @override
  String get unit_kilograms => 'Kilogramos';

  @override
  String get unit_milliliters => 'Mililitros';

  @override
  String get unit_liters => 'Litros';

  @override
  String get unit_pieces => 'Piezas';

  @override
  String get unit_spoonfuls => 'Cucharadas';

  @override
  String get unit_tablespoons => 'Cucharadas';

  @override
  String get unit_teaspoons => 'Cucharaditas';

  @override
  String get unit_cups => 'Tazas';

  @override
  String get unit_ounces => 'Onzas';

  @override
  String get step_instruction => 'Instrucción';

  @override
  String get step_instruction_hint => 'Describe el paso...';

  @override
  String get save_button => 'Guardar';

  @override
  String get delete_button => 'Eliminar';

  @override
  String get config_button => 'Configuración';

  @override
  String get recipe_steps => 'Pasos';

  @override
  String get tools_title => 'Herramientas';

  @override
  String get no_steps => 'Aún no hay pasos añadidos.';

  @override
  String get est_revenue => 'Ingresos Est.';

  @override
  String get financial_targets => 'Objetivos Financieros';

  @override
  String get financial_margin => 'Margen Total';

  @override
  String get financial_price => 'Precio por Porción';

  @override
  String get no_ingredients => 'Aún no hay ingredientes.';

  @override
  String get unit_portions => 'Porciones';

  @override
  String get cost_per_portion => 'Costo por Porción';

  @override
  String get profit_per_portion => 'Ganancia por Porción';

  @override
  String get validation_required => 'Requerido';

  @override
  String get profit_margin_helper =>
      'Ingrese números enteros (ej. 35 para 35%)';

  @override
  String get assign_ingredients_tooltip => 'Asignar ingredientes a este paso';

  @override
  String get select_ingredient_recipe_title =>
      'Seleccionar Ingrediente para la Receta';

  @override
  String assign_to_step_title(int number) {
    return 'Asignar al Paso $number';
  }

  @override
  String get mention_ingredient_title => 'Mencionar Ingrediente';

  @override
  String get add_ingredients_first_error =>
      'Agrega ingredientes a la receta primero';

  @override
  String get assign_step_ingredients_first_error =>
      'Asigna ingredientes al paso en la cabecera (+)';

  @override
  String get done_button => 'Hecho';
}
