import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipetools/provider/database_provider.dart';
import 'package:recipetools/database/database.dart';

void main() {
  group('IngredientFilter Tests', () {
    test('Initial filter state is IngredientFilterType.all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(ingredientFilterProvider);
      expect(filter, equals(IngredientFilterType.all));
    });

    test('Updating filter state to solids, liquids, and pieces', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(ingredientFilterProvider.notifier);

      notifier.setFilter(IngredientFilterType.solids);
      expect(container.read(ingredientFilterProvider), equals(IngredientFilterType.solids));

      notifier.setFilter(IngredientFilterType.liquids);
      expect(container.read(ingredientFilterProvider), equals(IngredientFilterType.liquids));

      notifier.setFilter(IngredientFilterType.pieces);
      expect(container.read(ingredientFilterProvider), equals(IngredientFilterType.pieces));

      notifier.setFilter(IngredientFilterType.all);
      expect(container.read(ingredientFilterProvider), equals(IngredientFilterType.all));
    });

    test('Filtering logic separates mass (solids), volume (liquids), and count (pieces)', () {
      const solidUnit = Unit(
        unitPk: 'unit_g',
        name: 'Grams',
        symbol: 'g',
        category: 'mass',
        factorToBase: 1.0,
        isMutable: false,
      );

      const liquidUnit = Unit(
        unitPk: 'unit_ml',
        name: 'Milliliters',
        symbol: 'ml',
        category: 'volume',
        factorToBase: 1.0,
        isMutable: false,
      );

      const pieceUnit = Unit(
        unitPk: 'unit_pcs',
        name: 'Pieces',
        symbol: 'pcs',
        category: 'count',
        factorToBase: 1.0,
        isMutable: false,
      );

      final flour = Ingredient(
        ingredientPk: 'ing_1',
        name: 'Flour',
        cost: 2.5,
        quantityForCost: 1000,
        unitFk: 'unit_g',
        dateCreated: DateTime.now(),
      );

      final milk = Ingredient(
        ingredientPk: 'ing_2',
        name: 'Milk',
        cost: 1.2,
        quantityForCost: 1000,
        unitFk: 'unit_ml',
        dateCreated: DateTime.now(),
      );

      final egg = Ingredient(
        ingredientPk: 'ing_3',
        name: 'Egg',
        cost: 0.3,
        quantityForCost: 1,
        unitFk: 'unit_pcs',
        dateCreated: DateTime.now(),
      );

      final unitMap = {
        solidUnit.unitPk: solidUnit,
        liquidUnit.unitPk: liquidUnit,
        pieceUnit.unitPk: pieceUnit,
      };

      final allIngredients = [flour, milk, egg];

      // All
      final allFiltered = allIngredients.where((ing) => true).toList();
      expect(allFiltered.length, equals(3));

      // Solids
      final solidsFiltered = allIngredients.where((ing) {
        final unit = unitMap[ing.unitFk];
        return unit?.category == 'mass';
      }).toList();
      expect(solidsFiltered.length, equals(1));
      expect(solidsFiltered.first.name, equals('Flour'));

      // Liquids
      final liquidsFiltered = allIngredients.where((ing) {
        final unit = unitMap[ing.unitFk];
        return unit?.category == 'volume';
      }).toList();
      expect(liquidsFiltered.length, equals(1));
      expect(liquidsFiltered.first.name, equals('Milk'));

      // Pieces
      final piecesFiltered = allIngredients.where((ing) {
        final unit = unitMap[ing.unitFk];
        return unit?.category == 'count';
      }).toList();
      expect(piecesFiltered.length, equals(1));
      expect(piecesFiltered.first.name, equals('Egg'));
    });
  });
}
