import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

const int nameLimit = 250;
const int noteLimit = 500;
const int colourLimit = 50;

@DataClassName('Recipe')
class Recipes extends Table {
  TextColumn get recipePk => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().withLength(max: nameLimit)();
  TextColumn get description => text().withLength(max: noteLimit).nullable()();

  RealColumn get defaultYield => real()();
  TextColumn get yieldName => text().withLength(max: colourLimit)();

  RealColumn get targetProfitMargin =>
      real().withDefault(const Constant(0.0))();
  RealColumn get targetPricePerPortion =>
      real().withDefault(const Constant(0.0))();
  RealColumn get fixedOverheadCost => real().withDefault(const Constant(0.0))();

  TextColumn get colour => text().withLength(max: colourLimit).nullable()();

  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();

  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {recipePk};
}

@DataClassName('Unit')
class Units extends Table {
  TextColumn get unitPk => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().withLength(max: nameLimit)();
  TextColumn get symbol => text().withLength(max: colourLimit)();
  BoolColumn get isMutable => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {unitPk};
}

@DataClassName('Ingredient')
class Ingredients extends Table {
  TextColumn get ingredientPk => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().withLength(max: nameLimit)();

  RealColumn get cost => real()();
  RealColumn get quantityForCost => real()();
  TextColumn get unitFk => text().references(Units, #unitPk)();

  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();

  @override
  Set<Column> get primaryKey => {ingredientPk};
}

@DataClassName('RecipeIngredient')
class RecipeIngredients extends Table {
  TextColumn get recipeIngredientPk => text().clientDefault(() => uuid.v4())();

  TextColumn get recipeFk => text().references(Recipes, #recipePk)();
  TextColumn get ingredientFk =>
      text().references(Ingredients, #ingredientPk)();

  RealColumn get amountNeeded => real()();

  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();

  @override
  Set<Column> get primaryKey => {recipeIngredientPk};
}

@DataClassName('RecipeStep')
class RecipeSteps extends Table {
  TextColumn get stepPk => text().clientDefault(() => uuid.v4())();
  TextColumn get recipeFk => text().references(Recipes, #recipePk)();

  IntColumn get stepNumber => integer()();
  TextColumn get instruction => text().withLength(max: noteLimit)();

  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();

  @override
  Set<Column> get primaryKey => {stepPk};
}
