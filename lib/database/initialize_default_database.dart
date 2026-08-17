import 'package:drift/drift.dart';
import 'database.dart';

/// Initializes the database with default values and updates existing unit equivalences.
/// Called during the launch of the application.
Future<void> initializeDefaultDatabase(AppDatabase db) async {
  final existingUnits = await db.getAllUnits();
  final existingMap = {for (var u in existingUnits) u.name: u};

  // Categories: 'mass', 'volume', 'count'
  // Base Mass: Grams (g) -> 1.0
  // Base Volume: Milliliters (ml) -> 1.0
  // Base Count: Pieces (pcs) -> 1.0
  //
  // Real Culinary Equivalences:
  // 1 Tablespoon (tbsp / cucharada) = 15.0 ml = 15.0 g (water)
  // 1 Teaspoon (tsp / cucharadita) = 5.0 ml = 5.0 g (water)
  // 1 Spoonful (spoonfuls / cuchara) = 15.0 ml = 15.0 g (water)
  // 1 Cup (cup / taza) = 240.0 ml
  // 1 Ounce (oz weight) = 28.3495 g
  // 1 Kilogram (kg) = 1000.0 g
  // 1 Liter (l) = 1000.0 ml

  final defaultUnits = [
    // --- MASS ---
    UnitsCompanion(
      name: const Value('unit_grams'),
      symbol: const Value('g'),
      category: const Value('mass'),
      factorToBase: const Value(1.0),
      isMutable: const Value(false),
    ),
    UnitsCompanion(
      name: const Value('unit_kilograms'),
      symbol: const Value('kg'),
      category: const Value('mass'),
      factorToBase: const Value(1000.0),
      isMutable: const Value(false),
    ),
    UnitsCompanion(
      name: const Value('unit_ounces'),
      symbol: const Value('oz'),
      category: const Value('mass'),
      factorToBase: const Value(28.3495),
      isMutable: const Value(false),
    ),

    // --- VOLUME ---
    UnitsCompanion(
      name: const Value('unit_milliliters'),
      symbol: const Value('ml'),
      category: const Value('volume'),
      factorToBase: const Value(1.0),
      isMutable: const Value(false),
    ),
    UnitsCompanion(
      name: const Value('unit_liters'),
      symbol: const Value('l'),
      category: const Value('volume'),
      factorToBase: const Value(1000.0),
      isMutable: const Value(false),
    ),
    UnitsCompanion(
      name: const Value('unit_cups'),
      symbol: const Value('cup'),
      category: const Value('volume'),
      factorToBase: const Value(240.0), // Standard US Cup
      isMutable: const Value(false),
    ),
    UnitsCompanion(
      name: const Value('unit_tablespoons'),
      symbol: const Value('tbsp'),
      category: const Value('volume'),
      factorToBase: const Value(15.0), // 1 tbsp = 15 ml = 15 g
      isMutable: const Value(false),
    ),
    UnitsCompanion(
      name: const Value('unit_teaspoons'),
      symbol: const Value('tsp'),
      category: const Value('volume'),
      factorToBase: const Value(5.0), // 1 tsp = 5 ml = 5 g
      isMutable: const Value(false),
    ),
    UnitsCompanion(
      name: const Value('unit_spoonfuls'),
      symbol: const Value('cuch'),
      category: const Value('volume'), // 1 spoon = 15.0 ml = 15.0 g
      factorToBase: const Value(15.0),
      isMutable: const Value(false),
    ),

    // --- COUNT ---
    UnitsCompanion(
      name: const Value('unit_pieces'),
      symbol: const Value('pcs'),
      category: const Value('count'),
      factorToBase: const Value(1.0),
      isMutable: const Value(false),
    ),
  ];

  for (final unit in defaultUnits) {
    final existing = existingMap[unit.name.value];
    if (existing == null) {
      await db.insertUnit(unit);
    } else if (existing.category != unit.category.value ||
        existing.factorToBase != unit.factorToBase.value) {
      await db.updateUnit(
        existing.copyWith(
          category: Value(unit.category.value),
          factorToBase: unit.factorToBase.value,
          symbol: unit.symbol.value,
        ),
      );
    }
  }
}
