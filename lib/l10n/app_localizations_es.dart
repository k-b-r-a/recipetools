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
  String get add_button => 'Add';

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
  String get total_profit => 'Ganancia Total';

  @override
  String get total_sale => 'Venta Total';

  @override
  String get sale_per_portion => 'Venta por Porción';

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

  @override
  String get add_ingredient_title => 'Agregar Ingrediente';

  @override
  String get edit_ingredient_title => 'Editar Ingrediente';

  @override
  String get select_unit => 'Seleccionar Unidad';

  @override
  String ingredient_price_per_quantity(
    String price,
    String quantity,
    String unit,
  ) {
    return '\$$price por cada $quantity $unit';
  }

  @override
  String get search_hint => 'Buscar...';

  @override
  String get search_ingredients_hint => 'Escribe para buscar ingredientes...';

  @override
  String get no_ingredients_found => 'No se encontraron ingredientes.';

  @override
  String get no_recipes_found => 'No se encontraron recetas.';

  @override
  String get related_ingredients => 'Relacionados';

  @override
  String get no_similar_ingredients => 'No hay ingredientes similares';

  @override
  String get merge_button => 'Combinar';

  @override
  String get compare_button => 'Comparar';

  @override
  String get merge_confirm_title => '¿Combinar Ingredientes?';

  @override
  String merge_confirm_message(String oldName, String newName) {
    return 'Esto reemplazará todas las referencias a $oldName con $newName in tus recetas. Esta acción no se puede deshacer.';
  }

  @override
  String get price_comparison => 'Comparación de Precios';

  @override
  String get error_select_unit => 'Por favor selecciona una unidad';

  @override
  String error_prefix(String error) {
    return 'Error: $error';
  }

  @override
  String get short_cost => 'COSTO';

  @override
  String get short_profit => 'GANANCIA';

  @override
  String get short_price_portion => 'P/PORCIÓN';

  @override
  String get per_unit => 'por';

  @override
  String get error_text => 'Error';

  @override
  String get scale_recipe_tooltip => 'Escalar receta (vista temporal)';

  @override
  String get temporary_view_title => 'Vista Temporal';

  @override
  String temporary_view_banner(String multiplier) {
    return 'Esta es una vista temporal escalada por ${multiplier}x. Los cambios no se guardarán.';
  }

  @override
  String get scale_button => 'Escalar';

  @override
  String get rule_of_three_title => 'Regla de Tres';

  @override
  String get rule_of_three_desc =>
      'Calcula proporciones fácilmente para cantidades de ingredientes y rendimientos.';

  @override
  String get rule_of_three_if => 'Si';

  @override
  String get rule_of_three_corresponds => 'corresponde a';

  @override
  String get rule_of_three_then => 'Entonces';

  @override
  String get rule_of_three_will_be => 'será';

  @override
  String get rule_of_three_result => 'Resultado';

  @override
  String get rule_of_three_clear => 'Limpiar';

  @override
  String get rule_of_three_example =>
      'Ejemplo: Si 100g de harina rinden 10 porciones, entonces para rendir 25 porciones necesitas 250g de harina.';

  @override
  String get unit_converter_title => 'Conversor de Unidades';

  @override
  String get unit_converter_desc =>
      'Convierte unidades de cocina para masa, volumen y cantidades fácilmente.';

  @override
  String get unit_converter_category => 'Categoría';

  @override
  String get unit_converter_from => 'Desde';

  @override
  String get unit_converter_to => 'Hacia';

  @override
  String get unit_converter_value => 'Valor';

  @override
  String get unit_converter_result => 'Resultado';

  @override
  String get unit_category_mass => 'Peso / Masa';

  @override
  String get unit_category_volume => 'Volumen';

  @override
  String get unit_category_count => 'Cantidad / Unidades';

  @override
  String get settings_general => 'Configuración General';

  @override
  String get settings_reset_db => 'Restablecer Base de Datos';

  @override
  String get settings_reset_db_desc =>
      'Elimina todas las recetas e ingredientes. No se puede deshacer.';

  @override
  String get settings_reset_db_confirm => '¿Restablecer Base de Datos?';

  @override
  String get settings_reset_db_warning =>
      '¿Estás seguro de que quieres eliminar todas las recetas, ingredientes y pasos? Esta acción es permanente.';

  @override
  String get settings_reset_db_success =>
      'Base de datos restablecida correctamente.';

  @override
  String get settings_theme_title => 'Tema y Estilo';

  @override
  String get settings_theme_mode => 'Modo de Tema';

  @override
  String get settings_theme_color => 'Color de Acento';

  @override
  String get settings_theme_system => 'Sistema';

  @override
  String get settings_theme_light => 'Claro';

  @override
  String get settings_theme_dark => 'Oscuro';

  @override
  String get settings_locale_title => 'Localización y Formato';

  @override
  String get settings_locale_lang => 'Idioma';

  @override
  String get settings_locale_es => 'Español';

  @override
  String get settings_locale_en => 'Inglés';

  @override
  String get settings_format_decimals => 'Decimales';

  @override
  String get settings_about => 'Acerca de';

  @override
  String get settings_version => 'Versión';
}
