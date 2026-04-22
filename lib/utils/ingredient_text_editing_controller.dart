import 'package:flutter/material.dart';
import '../database/database.dart';
import 'recipe_utils.dart';

class IngredientTextEditingController extends TextEditingController {
  List<Ingredient> ingredients;
  final ColorScheme colorScheme;

  IngredientTextEditingController({
    super.text,
    List<Ingredient>? ingredients,
    required this.colorScheme,
  }) : ingredients = ingredients ?? [];

  /// updates the internal list of available ingredients for tagging
  void updateIngredients(List<Ingredient> newIngredients) {
    ingredients = newIngredients;
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (ingredients.isEmpty || text.isEmpty) {
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }

    final List<InlineSpan> children = [];
    
    // sort ingredients by length descending to match longer phrases first
    final sortedIngredients = List<Ingredient>.from(ingredients)
      ..sort((a, b) => b.name.length.compareTo(a.name.length));

    // build regex pattern
    final pattern = RegExp(
      sortedIngredients.map((ing) => RegExp.escape(ing.name)).join('|'),
      caseSensitive: false,
    );
    
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        final matchedText = match[0]!;
        // get exact color using centralized utility
        final color = RecipeUtils.getIngredientColor(matchedText, colorScheme);

        children.add(
          TextSpan(
            text: matchedText,
            style: style?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatched) {
        children.add(TextSpan(text: nonMatched, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }
}
