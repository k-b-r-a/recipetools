import 'package:drift/drift.dart';
import 'database.dart';

/// Initializes the database with default values.
/// Called during the first launch of the application.
Future<void> initializeDefaultDatabase(AppDatabase db) async {
  final existingUnits = await db.getAllUnits();
  
  if (existingUnits.isEmpty) {
    // Use the KEYS defined in the Google Sheet
    // This allows the UI to translate them dynamically
    final defaultUnits = [
      UnitsCompanion(
        name: const Value('unit_grams'),
        symbol: const Value('g'),
        isMutable: const Value(false),
      ),
      UnitsCompanion(
        name: const Value('unit_kilograms'),
        symbol: const Value('kg'),
        isMutable: const Value(false),
      ),
      UnitsCompanion(
        name: const Value('unit_milliliters'),
        symbol: const Value('ml'),
        isMutable: const Value(false),
      ),
      UnitsCompanion(
        name: const Value('unit_liters'),
        symbol: const Value('l'),
        isMutable: const Value(false),
      ),
      UnitsCompanion(
        name: const Value('unit_pieces'),
        symbol: const Value('pcs'),
        isMutable: const Value(false),
      ),
      UnitsCompanion(
        name: const Value('unit_spoonfuls'),
        symbol: const Value('spoonfuls'),
        isMutable: const Value(false),
      ),
      UnitsCompanion(
        name: const Value('unit_tablespoons'),
        symbol: const Value('tbsp'),
        isMutable: const Value(false),
      ),
      UnitsCompanion(
        name: const Value('unit_teaspoons'),
        symbol: const Value('tsp'),
        isMutable: const Value(false),
      ),
      UnitsCompanion(
        name: const Value('unit_cups'),
        symbol: const Value('cup'),
        isMutable: const Value(false),
      ),
      UnitsCompanion(
        name: const Value('unit_ounces'),
        symbol: const Value('oz'),
        isMutable: const Value(false),
      ),
    ];

    for (final unit in defaultUnits) {
      await db.insertUnit(unit);
    }
  }
}
