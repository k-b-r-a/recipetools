import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../provider/database_provider.dart';
import '../database/database.dart';
import '../utils/recipe_utils.dart';

class UnitConverterScreen extends ConsumerStatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  ConsumerState<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen> {
  final _valueController = TextEditingController(text: '1');
  String _selectedCategory = 'mass';
  Unit? _fromUnit;
  Unit? _toUnit;
  double _result = 0.0;

  @override
  void initState() {
    super.initState();
    _valueController.addListener(_calculateConversion);
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _calculateConversion() {
    if (_fromUnit == null || _toUnit == null) {
      setState(() => _result = 0.0);
      return;
    }

    final valueText = _valueController.text.trim();
    if (valueText.isEmpty) {
      setState(() => _result = 0.0);
      return;
    }

    final inputVal = RecipeUtils.parseFormattedNumber(valueText);
    final valueInBase = inputVal * _fromUnit!.factorToBase;
    final convertedValue = valueInBase / _toUnit!.factorToBase;

    setState(() {
      _result = convertedValue;
    });
  }

  void _onCategoryChanged(String category, List<Unit> allUnits) {
    if (_selectedCategory == category) return;

    final filtered = allUnits.where((u) => u.category == category).toList();
    setState(() {
      _selectedCategory = category;
      _fromUnit = filtered.isNotEmpty ? filtered[0] : null;
      _toUnit = filtered.length > 1 ? filtered[1] : (filtered.isNotEmpty ? filtered[0] : null);
    });
    // Calculate after state is set
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateConversion());
  }

  void _swapUnits() {
    if (_fromUnit == null || _toUnit == null) return;
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateConversion());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: const BackButton(),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n.unit_converter_title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: unitsAsync.when(
        data: (allUnits) {
          // Categories list
          final categories = allUnits
              .map((u) => u.category)
              .whereType<String>()
              .toSet()
              .toList();

          // Ensure categories has at least mass, volume, count
          if (!categories.contains('mass')) categories.add('mass');
          if (!categories.contains('volume')) categories.add('volume');
          if (!categories.contains('count')) categories.add('count');

          final filteredUnits = allUnits
              .where((u) => u.category == _selectedCategory)
              .toList();

          // Initialize units if not set
          if (_fromUnit == null || _fromUnit!.category != _selectedCategory) {
            _fromUnit = filteredUnits.isNotEmpty ? filteredUnits[0] : null;
          }
          if (_toUnit == null || _toUnit!.category != _selectedCategory) {
            _toUnit = filteredUnits.length > 1
                ? filteredUnits[1]
                : (filteredUnits.isNotEmpty ? filteredUnits[0] : null);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.unit_converter_desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Category tabs
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    segments: categories.map((cat) {
                      String label = cat;
                      if (cat == 'mass') label = l10n.unit_category_mass;
                      if (cat == 'volume') label = l10n.unit_category_volume;
                      if (cat == 'count') label = l10n.unit_category_count;

                      return ButtonSegment<String>(
                        value: cat,
                        label: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    selected: {_selectedCategory},
                    onSelectionChanged: (newSelection) {
                      _onCategoryChanged(newSelection.first, allUnits);
                    },
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Source Input Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.unit_converter_from,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextField(
                              controller: _valueController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 4),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Unit>(
                                  value: _fromUnit,
                                  isExpanded: true,
                                  onChanged: (Unit? newUnit) {
                                    if (newUnit != null) {
                                      setState(() => _fromUnit = newUnit);
                                      _calculateConversion();
                                    }
                                  },
                                  items: filteredUnits.map((Unit unit) {
                                    return DropdownMenuItem<Unit>(
                                      value: unit,
                                      child: Text(
                                        '${_getLocalizedUnitName(unit, l10n)} (${unit.symbol})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Swap button
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.swap_vert_rounded),
                      color: theme.colorScheme.onPrimary,
                      onPressed: _swapUnits,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Target Result Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.unit_converter_to,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                RecipeUtils.formatNumber(_result, decimalDigits: 4),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Unit>(
                                  value: _toUnit,
                                  isExpanded: true,
                                  onChanged: (Unit? newUnit) {
                                    if (newUnit != null) {
                                      setState(() => _toUnit = newUnit);
                                      _calculateConversion();
                                    }
                                  },
                                  items: filteredUnits.map((Unit unit) {
                                    return DropdownMenuItem<Unit>(
                                      value: unit,
                                      child: Text(
                                        '${_getLocalizedUnitName(unit, l10n)} (${unit.symbol})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Detailed summary text
                if (_fromUnit != null && _toUnit != null && _result > 0.0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      '${_valueController.text} ${_fromUnit!.symbol} = ${RecipeUtils.formatNumber(_result, decimalDigits: 4)} ${_toUnit!.symbol}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  String _getLocalizedUnitName(Unit unit, AppLocalizations l10n) {
    final name = unit.name.toLowerCase();
    if (name.contains('gram')) return l10n.unit_grams;
    if (name.contains('kilogram')) return l10n.unit_kilograms;
    if (name.contains('ounce')) return l10n.unit_ounces;
    if (name.contains('milliliter')) return l10n.unit_milliliters;
    if (name.contains('liter')) return l10n.unit_liters;
    if (name.contains('cup')) return l10n.unit_cups;
    if (name.contains('tablespoon')) return l10n.unit_tablespoons;
    if (name.contains('teaspoon')) return l10n.unit_teaspoons;
    if (name.contains('spoonful')) return l10n.unit_spoonfuls;
    if (name.contains('piece')) return l10n.unit_pieces;
    return unit.name;
  }
}
