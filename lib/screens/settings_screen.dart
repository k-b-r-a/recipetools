import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../widgets/floating_pill_app_bar.dart';
import '../provider/settings_provider.dart';
import '../provider/database_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Color> _accentColors = const [
    Colors.deepPurple,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.amber,
    Colors.orange,
    Colors.red,
    Colors.pink,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showResetConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_reset_db_confirm),
        content: Text(l10n.settings_reset_db_warning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.localeName == 'es' ? 'Cancelar' : 'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final successText = l10n.settings_reset_db_success;
              Navigator.pop(context);
              try {
                final db = ref.read(databaseProvider);
                await db.resetDatabase();
                // Invalidate providers to force UI refresh
                ref.invalidate(recipesStreamProvider);
                ref.invalidate(recipesWithFinancialsStreamProvider);
                ref.invalidate(ingredientsStreamProvider);
                ref.invalidate(unitsProvider);

                messenger.showSnackBar(
                  SnackBar(content: Text(successText)),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: Text(l10n.settings_reset_db),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          buildFloatingPillAppBar(
            context: context,
            title: l10n.config_button,
            controller: _scrollController,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Theme & Style Section
                _buildSectionHeader(context, l10n.settings_theme_title),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settings_theme_mode,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment(
                                value: ThemeMode.system,
                                icon: const Icon(Icons.brightness_auto),
                                label: Text(l10n.settings_theme_system),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                icon: const Icon(Icons.light_mode),
                                label: Text(l10n.settings_theme_light),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                icon: const Icon(Icons.dark_mode),
                                label: Text(l10n.settings_theme_dark),
                              ),
                            ],
                            selected: {settings.themeMode},
                            onSelectionChanged: (selection) {
                              settingsNotifier.setThemeMode(selection.first);
                            },
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.settings_theme_color,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _accentColors.map((color) {
                              final isSelected = settings.seedColor == color;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: InkWell(
                                  onTap: () => settingsNotifier.setSeedColor(color),
                                  customBorder: const CircleBorder(),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: color,
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Localization & Formatting Section
                _buildSectionHeader(context, l10n.settings_locale_title),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settings_locale_lang,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: [
                              ButtonSegment(
                                value: 'es',
                                label: Text(l10n.settings_locale_es),
                              ),
                              ButtonSegment(
                                value: 'en',
                                label: Text(l10n.settings_locale_en),
                              ),
                            ],
                            selected: {settings.locale.languageCode},
                            onSelectionChanged: (selection) {
                              settingsNotifier.setLocale(Locale(selection.first));
                            },
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.settings_format_decimals,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(
                                value: 2,
                                label: Text('2 Places'),
                              ),
                              ButtonSegment(
                                value: 3,
                                label: Text('3 Places'),
                              ),
                              ButtonSegment(
                                value: 4,
                                label: Text('4 Places'),
                              ),
                            ],
                            selected: {settings.decimalDigits},
                            onSelectionChanged: (selection) {
                              settingsNotifier.setDecimalDigits(selection.first);
                            },
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. General & About Section
                _buildSectionHeader(context, l10n.settings_general),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                          child: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                        ),
                        title: Text(
                          l10n.settings_reset_db,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          l10n.settings_reset_db_desc,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () => _showResetConfirmation(context),
                      ),
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                          child: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        ),
                        title: Text(
                          l10n.settings_about,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '${l10n.settings_version} 1.0.0+1',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
