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
  String get edit_button => 'Editar';

  @override
  String get delete_button => 'Eliminar';

  @override
  String get duplicate_button => 'Duplicar';

  @override
  String get delete_recipe_title => 'Eliminar Receta';

  @override
  String get delete_recipe_message =>
      '¿Estás seguro de que deseas eliminar esta receta? Esta acción no se puede deshacer.';

  @override
  String get discard_button => 'Descartar';

  @override
  String get unsaved_changes_title => 'Cambios sin guardar';

  @override
  String get unsaved_changes_body =>
      '¿Quieres guardar o descartar esta receta?';

  @override
  String get new_ingredient_button => 'Nuevo Ingrediente';

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
  String get select_ingredient_recipe_title => 'Seleccionar Ingrediente';

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
    return '$price por cada $quantity $unit';
  }

  @override
  String get search_hint => 'Buscar...';

  @override
  String get search_ingredients_hint => 'Escribe para buscar ingredientes...';

  @override
  String get no_ingredients_found => 'Ingredientes no encontrados';

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

  @override
  String get settings_font_size => 'Tamaño de Fuente';

  @override
  String get settings_font_size_small => 'Pequeño';

  @override
  String get settings_font_size_medium => 'Mediano';

  @override
  String get settings_font_size_large => 'Grande';

  @override
  String get settings_font_size_xlarge => 'Muy Grande';

  @override
  String get settings_styles_title => 'Estilos';

  @override
  String get settings_about_app_title => 'Acerca de la Aplicación';

  @override
  String get settings_haptic_feedback => 'Respuesta Háptica';

  @override
  String get settings_haptic_feedback_desc =>
      'Activa vibraciones del sistema al interactuar con botones';

  @override
  String get settings_styles_m3 => 'Usar Material 3';

  @override
  String get settings_styles_m3_desc =>
      'Activa el diseño y componentes modernos de Material 3';

  @override
  String get settings_styles_icon_style => 'Estilo de Iconos';

  @override
  String get settings_styles_icon_style_outlined => 'Contorno';

  @override
  String get settings_styles_icon_style_rounded => 'Redondeado';

  @override
  String get settings_styles_icon_style_sharp => 'Afilado';

  @override
  String get settings_styles_number_colors => 'Colorear Números';

  @override
  String get settings_styles_number_colors_desc =>
      'Usa colores semánticos para métricas financieras';

  @override
  String get settings_styles_animations => 'Animaciones';

  @override
  String get settings_styles_animations_desc =>
      'Activa transiciones de pantalla y microanimaciones';

  @override
  String get settings_styles_scroll => 'Física de Desplazamiento';

  @override
  String get settings_styles_scroll_default => 'Por Defecto';

  @override
  String get settings_styles_scroll_simple => 'Simple (Limitado)';

  @override
  String get settings_styles_scroll_stretch => 'Estirar';

  @override
  String get settings_styles_scroll_bounce => 'Rebotar';

  @override
  String get settings_styles_left_hand => 'Modo Zurdo';

  @override
  String get settings_styles_left_hand_desc =>
      'Refleja controles para un uso más fácil con la mano izquierda';

  @override
  String get settings_styles_high_contrast => 'Texto de Alto Contraste';

  @override
  String get settings_styles_high_contrast_desc =>
      'Fuerza texto negro/blanco puro para legibilidad';

  @override
  String get settings_styles_font => 'Familia de Fuente';

  @override
  String get settings_styles_font_system => 'Predeterminada';

  @override
  String get settings_styles_font_sans => 'Metropolis';

  @override
  String get settings_styles_font_serif => 'Nunito';

  @override
  String get settings_styles_font_mono => 'Inconsolata Monospace';

  @override
  String get settings_styles_font_amatic => 'Amatic SC';

  @override
  String get settings_styles_font_butler => 'Butler';

  @override
  String get settings_styles_font_caveat => 'Caveat';

  @override
  String get settings_styles_show_nav_labels =>
      'Mostrar Etiquetas de Navegación';

  @override
  String get settings_styles_show_nav_labels_desc =>
      'Muestra las etiquetas de texto debajo de los iconos de navegación';

  @override
  String get settings_format_mass_unit => 'Unidad de Masa Predeterminada';

  @override
  String get settings_format_volume_unit => 'Unidad de Volumen Predeterminada';

  @override
  String get settings_format_decimals_1 => '1 decimal';

  @override
  String get settings_format_decimals_2 => '2 decimales';

  @override
  String get settings_format_decimals_3 => '3 decimales';

  @override
  String get settings_format_decimals_4 => '4 decimales';

  @override
  String get settings_format_mass_g => 'Gramos (g)';

  @override
  String get settings_format_mass_kg => 'Kilogramos (kg)';

  @override
  String get settings_format_volume_ml => 'Mililitros (ml)';

  @override
  String get settings_format_volume_l => 'Litros (l)';

  @override
  String get settings_format_currency => 'Símbolo de Moneda';

  @override
  String get cloud_sync_title => 'Sincronización en la Nube';

  @override
  String get cloud_sync_desc =>
      'Realiza copias de seguridad y restaura tus recetas e ingredientes de forma segura usando tu cuenta de Google Drive.';

  @override
  String get cloud_sync_connected => 'Conectado a Google Drive';

  @override
  String get cloud_sync_disconnected => 'Desconectado';

  @override
  String get cloud_sync_connect_btn => 'Iniciar sesión con Google';

  @override
  String get cloud_sync_disconnect_btn => 'Cerrar sesión';

  @override
  String get cloud_sync_backup_btn => 'Respaldar ahora';

  @override
  String get cloud_sync_backups_header => 'Historial de Copias';

  @override
  String get cloud_sync_no_backups => 'No hay copias de seguridad.';

  @override
  String get cloud_sync_backup_confirm_title => 'Crear Copia de Seguridad';

  @override
  String get cloud_sync_backup_confirm_desc =>
      'Se subirá una copia de seguridad de tu base de datos actual a Google Drive.';

  @override
  String get cloud_sync_restore_confirm_title => 'Restaurar Copia de Seguridad';

  @override
  String get cloud_sync_restore_confirm_desc =>
      'Se sobrescribirán todas las recetas, pasos e ingredientes con la copia de seguridad seleccionada. Esta acción no se puede deshacer.';

  @override
  String get cloud_sync_delete_confirm_title => 'Eliminar Copia de Seguridad';

  @override
  String get cloud_sync_delete_confirm_desc =>
      '¿Estás seguro de que deseas eliminar permanentemente esta copia de seguridad de Google Drive?';

  @override
  String get cloud_sync_sandbox_badge => 'Copia Local';

  @override
  String get cloud_sync_sandbox_desc =>
      'Las copias se guardan en un directorio local del dispositivo.';

  @override
  String get timers_title => 'Temporizadores de Cocina';

  @override
  String get timers_desc =>
      'Ejecuta múltiples temporizadores de cocina y horneado simultáneamente en segundo plano.';

  @override
  String get timers_add_title => 'Nuevo Temporizador';

  @override
  String get timers_timer_name => 'Nombre del Temporizador';

  @override
  String get timers_duration => 'Duración';

  @override
  String get timers_no_timers => 'Sin temporizadores activos.';

  @override
  String get timers_no_timers_desc =>
      '¡Crea un nuevo temporizador para comenzar a cocinar!';

  @override
  String get timers_finished => '¡Temporizador Finalizado!';
}
