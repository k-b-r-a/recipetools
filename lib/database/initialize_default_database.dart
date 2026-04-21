import 'package:drift/drift.dart';
import 'database.dart';

/// Initializes the database with default values.
/// Called during the first launch of the application.
Future<void> initializeDefaultDatabase(AppDatabase db) async {
  final existingUnits = await db.getAllUnits();
  final existingNames = existingUnits.map((u) => u.name).toSet();
  
  // Categories: 'mass', 'volume', 'count'
  // Factors are relative to the base unit of each category:
  // Base Mass: Grams (g)
  // Base Volume: Milliliters (ml)
  // Base Count: Pieces (pcs)
  
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
      factorToBase: const Value(15.0),
      isMutable: const Value(false),
    ),
    UnitsCompanion(
      name: const Value('unit_teaspoons'),
      symbol: const Value('tsp'),
      category: const Value('volume'),
      factorToBase: const Value(5.0),
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
    UnitsCompanion(
      name: const Value('unit_spoonfuls'),
      symbol: const Value('spoonfuls'),
      category: const Value('count'), // Or volume, depending on use
      factorToBase: const Value(1.0),
      isMutable: const Value(false),
    ),
  ];

  for (final unit in defaultUnits) {
    if (!existingNames.contains(unit.name.value)) {
      await db.insertUnit(unit);
    }
  }
}
