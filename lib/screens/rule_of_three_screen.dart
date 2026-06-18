import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/recipe_utils.dart';

class RuleOfThreeScreen extends StatefulWidget {
  const RuleOfThreeScreen({super.key});

  @override
  State<RuleOfThreeScreen> createState() => _RuleOfThreeScreenState();
}

class _RuleOfThreeScreenState extends State<RuleOfThreeScreen> {
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  final _cController = TextEditingController();

  double _result = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _aController.addListener(_calculate);
    _bController.addListener(_calculate);
    _cController.addListener(_calculate);
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    super.dispose();
  }

  void _calculate() {
    final aText = _aController.text.trim();
    final bText = _bController.text.trim();
    final cText = _cController.text.trim();

    if (aText.isEmpty || bText.isEmpty || cText.isEmpty) {
      setState(() {
        _result = 0.0;
        _hasError = false;
      });
      return;
    }

    final a = RecipeUtils.parseFormattedNumber(aText);
    final b = RecipeUtils.parseFormattedNumber(bText);
    final c = RecipeUtils.parseFormattedNumber(cText);

    if (a == 0.0) {
      setState(() {
        _result = 0.0;
        _hasError = true;
      });
      return;
    }

    setState(() {
      _result = (b * c) / a;
      _hasError = false;
    });
  }

  void _clearAll() {
    _aController.clear();
    _bController.clear();
    _cController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final displayError = _hasError
        ? (l10n.localeName == 'es' ? 'El valor inicial no puede ser cero' : 'Initial value cannot be zero')
        : '';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: const BackButton(),
        title: Text(
          l10n.rule_of_three_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _clearAll,
            child: Text(
              l10n.rule_of_three_clear,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.rule_of_three_desc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildValueInput(
                          controller: _aController,
                          label: l10n.rule_of_three_if,
                          hint: '10',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      Expanded(
                        child: _buildValueInput(
                          controller: _bController,
                          label: l10n.rule_of_three_corresponds,
                          hint: '100g',
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(
                      Icons.unfold_more_rounded,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      size: 28,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildValueInput(
                          controller: _cController,
                          label: l10n.rule_of_three_then,
                          hint: '25',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _hasError
                                ? theme.colorScheme.errorContainer.withValues(alpha: 0.2)
                                : theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _hasError
                                  ? theme.colorScheme.error.withValues(alpha: 0.4)
                                  : theme.colorScheme.primary.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.rule_of_three_will_be,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _hasError
                                      ? 'Error'
                                      : RecipeUtils.formatNumber(_result),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: _hasError
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_hasError)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayError,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!_hasError && _result > 0.0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rule_of_three_result,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.localeName == 'es'
                          ? 'Si ${_aController.text} equivale a ${_bController.text}, entonces ${_cController.text} equivale a ${RecipeUtils.formatNumber(_result)}.'
                          : 'If ${_aController.text} corresponds to ${_bController.text}, then ${_cController.text} will correspond to ${RecipeUtils.formatNumber(_result)}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.rule_of_three_example,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueInput({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
