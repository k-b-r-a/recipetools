import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'provider/database_provider.dart';
import 'database/database.dart';
import 'widgets/floating_pill_app_bar.dart';
import 'utils/recipe_utils.dart';

import 'screens/recipe_editor_screen.dart';
import 'screens/ingredients_screen.dart';
import 'screens/add_ingredient_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/settings_screen.dart';
import 'provider/settings_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  await NotificationService().initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const RecipetoolsApp(),
    ),
  );
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  final String physicsType;
  const CustomScrollBehavior(this.physicsType);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (physicsType) {
      case 'bounce':
        return const BouncingScrollPhysics();
      case 'default':
      default:
        return super.getScrollPhysics(context);
    }
  }
}

class RecipetoolsApp extends ConsumerWidget {
  const RecipetoolsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    ThemeData buildTheme(Brightness brightness) {
      var colorScheme = ColorScheme.fromSeed(
        seedColor: settings.seedColor,
        brightness: brightness,
      );

      if (settings.highContrastText) {
        final isDark = brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black;
        colorScheme = colorScheme.copyWith(
          onSurface: textColor,
          onSurfaceVariant: textColor,
          primary: isDark ? Colors.white : Colors.black,
          secondary: isDark ? Colors.white : Colors.black,
          onPrimary: isDark ? Colors.black : Colors.white,
          onSecondary: isDark ? Colors.black : Colors.white,
          onError: isDark ? Colors.black : Colors.white,
        );
      }

      final baseTheme = ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        fontFamily: settings.fontFamily == 'sans'
            ? 'Metropolis'
            : settings.fontFamily == 'butler'
                ? 'Butler'
                : null,
        pageTransitionsTheme: settings.animationsEnabled
            ? const PageTransitionsTheme()
            : const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: NoTransitionsBuilder(),
                  TargetPlatform.iOS: NoTransitionsBuilder(),
                  TargetPlatform.macOS: NoTransitionsBuilder(),
                  TargetPlatform.windows: NoTransitionsBuilder(),
                  TargetPlatform.linux: NoTransitionsBuilder(),
                  TargetPlatform.fuchsia: NoTransitionsBuilder(),
                },
              ),
      );

      var textTheme = baseTheme.textTheme;
      if (settings.fontFamily == 'sans') {
        textTheme = textTheme.apply(fontFamily: 'Metropolis');
      } else if (settings.fontFamily == 'butler') {
        textTheme = textTheme.apply(fontFamily: 'Butler');
      } else if (settings.fontFamily == 'serif') {
        textTheme = GoogleFonts.nunitoTextTheme(textTheme);
      } else if (settings.fontFamily == 'mono') {
        textTheme = GoogleFonts.inconsolataTextTheme(textTheme);
      } else if (settings.fontFamily == 'amatic') {
        textTheme = GoogleFonts.amaticScTextTheme(textTheme);
      } else if (settings.fontFamily == 'caveat') {
        textTheme = GoogleFonts.caveatTextTheme(textTheme);
      }

      if (settings.highContrastText) {
        final textColor = brightness == Brightness.dark ? Colors.white : Colors.black;
        textTheme = textTheme.apply(
          bodyColor: textColor,
          displayColor: textColor,
          decorationColor: textColor,
        );
      }

      return baseTheme.copyWith(
        textTheme: textTheme,
      );
    }

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.recipes_title,
      locale: settings.locale,
      themeMode: settings.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      scrollBehavior: CustomScrollBehavior(settings.scrollBehavior),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(settings.fontSizeScale)),
          child: child!,
        );
      },
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isSearching = false;
  bool _showSearchContent = false;
  bool _isSearchHovered = false;
  bool _isAddHovered = false;

  final List<Widget> _screens = [
    const RecipeListScreen(),
    const IngredientsScreen(),
    const ToolsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final double baseHeight = settings.showNavBarLabels ? 70.0 : 56.0;
    final double navBarHeight =
        baseHeight * (settings.fontSizeScale > 1.0 ? settings.fontSizeScale : 1.0);

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _isSearching = false;
            _showSearchContent = false;
            ref.read(searchQueryProvider.notifier).setQuery('');
          });
        },
        children: _screens,
      ),
      floatingActionButtonLocation: settings.leftHandedMode
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFab(context, settings),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    indicatorShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: navBarHeight,
                    labelTextStyle: WidgetStateProperty.all(
                      const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  child: NavigationBar(
                    height: navBarHeight,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    selectedIndex: _currentIndex,
                    labelBehavior: settings.showNavBarLabels
                        ? NavigationDestinationLabelBehavior.alwaysShow
                        : NavigationDestinationLabelBehavior.alwaysHide,
                    onDestinationSelected: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    destinations: [
                      NavigationDestination(
                        icon: Icon(getNavBarIcon(0, false, settings.iconStyle), size: 22),
                        selectedIcon: Icon(getNavBarIcon(0, true, settings.iconStyle), size: 22),
                        label: l10n.recipes_title,
                      ),
                      NavigationDestination(
                        icon: Icon(getNavBarIcon(1, false, settings.iconStyle), size: 22),
                        selectedIcon: Icon(getNavBarIcon(1, true, settings.iconStyle), size: 22),
                        label: l10n.ingredients_title,
                      ),
                      NavigationDestination(
                        icon: Icon(getNavBarIcon(2, false, settings.iconStyle), size: 22),
                        selectedIcon: Icon(getNavBarIcon(2, true, settings.iconStyle), size: 22),
                        label: l10n.tools_title,
                      ),
                      NavigationDestination(
                        icon: Icon(getNavBarIcon(3, false, settings.iconStyle), size: 22),
                        selectedIcon: Icon(getNavBarIcon(3, true, settings.iconStyle), size: 22),
                        label: l10n.config_button,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildFab(BuildContext context, SettingsState settings) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isLeft = settings.leftHandedMode;

    // determine visibility based on current screen
    final bool showFab = _currentIndex == 0 || _currentIndex == 1;

    return Container(
      width: screenWidth,
      height: 120, // enough height for the "jump" animation
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: IgnorePointer(
        ignoring: !showFab,
        child: Stack(
          alignment: isLeft ? Alignment.bottomLeft : Alignment.bottomRight,
          children: [
            // search bar - expands horizontally from the left of add button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              right: isLeft ? null : (_isSearching ? 0 : 56 + 12),
              left: isLeft ? (_isSearching ? 0 : 56 + 12) : null,
              bottom: 0, // aligned at the same floor as the 56px add button
              child: AnimatedScale(
                scale: showFab ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                  width: _isSearching ? screenWidth - 48 : 40,
                  height: _isSearching ? 44 : 40,
                  decoration: BoxDecoration(
                    color: _isSearching
                        ? theme.colorScheme.surface.withValues(alpha: 0.7)
                        : (_isSearchHovered
                              ? Color.alphaBlend(
                                  theme.colorScheme.onSurface.withValues(
                                    alpha: 0.08,
                                  ),
                                  theme.colorScheme.secondaryContainer,
                                )
                              : theme.colorScheme.secondaryContainer),
                    borderRadius: BorderRadius.circular(_isSearching ? 20 : 12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: _isSearching ? 0.4 : 0.1,
                      ),
                    ),
                    boxShadow: const [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_isSearching ? 20 : 12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _isSearching ? 5 : 0,
                        sigmaY: _isSearching ? 5 : 0,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isSearching
                            ? AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: _showSearchContent ? 1.0 : 0.0,
                                child: TextField(
                                  key: const ValueKey('search_field'),
                                  autofocus: true,
                                  onChanged: (value) {
                                    ref
                                        .read(searchQueryProvider.notifier)
                                        .setQuery(value);
                                  },
                                  style: theme.textTheme.bodyLarge,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    hintText: l10n.search_hint,
                                    hintStyle: theme.textTheme.bodyLarge
                                        ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(
                                      left: 16,
                                      right: 8,
                                      bottom: 4,
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 40,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    suffixIconConstraints: const BoxConstraints(
                                      minWidth: 40,
                                    ),
                                    suffixIcon: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _isSearching = false;
                                          _showSearchContent = false;
                                          _isSearchHovered = false;
                                          ref
                                              .read(
                                                searchQueryProvider.notifier,
                                              )
                                              .setQuery('');
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              )
                            : InkWell(
                                key: const ValueKey('search_button'),
                                onTap: () {
                                  setState(() {
                                    _isSearching = true;
                                    _isSearchHovered = false;
                                  });
                                  Future.delayed(
                                    const Duration(milliseconds: 360),
                                    () {
                                      if (mounted && _isSearching) {
                                        setState(
                                          () => _showSearchContent = true,
                                        );
                                      }
                                    },
                                  );
                                },
                                onHover: (hovering) =>
                                    setState(() => _isSearchHovered = hovering),
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: Icon(
                                    Icons.search,
                                    size: 20,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // add button - jumps up when searching, stays at the right/left
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              right: isLeft ? null : 0,
              left: isLeft ? 0 : null,
              bottom: _isSearching ? 44 + 12 : 0, // moves up above search bar
              child: AnimatedScale(
                scale: showFab ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isAddHovered = true),
                  onExit: (_) => setState(() => _isAddHovered = false),
                  child: FloatingActionButton(
                    heroTag: _currentIndex == 0
                        ? 'add_recipe_fab'
                        : 'add_ingredient_fab',
                    elevation: 0,
                    hoverElevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    backgroundColor: _isAddHovered
                        ? Color.alphaBlend(
                            theme.colorScheme.onSurface.withValues(alpha: 0.08),
                            theme.colorScheme.secondaryContainer,
                          )
                        : theme.colorScheme.secondaryContainer,
                    onPressed: () {
                      if (_currentIndex == 0) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RecipeEditorScreen(),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddIngredientScreen(),
                          ),
                        );
                      }
                    },
                    child: Icon(
                      Icons.add,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatefulWidget {
  final String titleKey;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.titleKey,
    required this.icon,
  });

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    String title = "";

    if (widget.titleKey == 'ingredients_title') title = l10n.ingredients_title;
    if (widget.titleKey == 'tools_title') title = l10n.tools_title;
    if (widget.titleKey == 'config_button') title = l10n.config_button;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          buildFloatingPillAppBar(
            context: context,
            title: title,
            controller: _scrollController,
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _expandedRecipeId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipesAsync = ref.watch(recipesWithFinancialsStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          buildFloatingPillAppBar(
            context: context,
            title: l10n.recipes_title,
            controller: _scrollController,
          ),
          recipesAsync.when(
            data: (recipes) {
              final filteredRecipes = recipes.where((item) {
                return item.recipe.name.toLowerCase().contains(searchQuery);
              }).toList();

              if (filteredRecipes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? l10n.recipes_title
                              : l10n.no_recipes_found,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index >= filteredRecipes.length) return null;
                    final item = filteredRecipes[index];
                    final recipe = item.recipe;
                    final financials = item.financials;
                    final isExpanded = _expandedRecipeId == recipe.recipePk;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (isExpanded) {
                            setState(() {
                              _expandedRecipeId = null;
                            });
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeEditorScreen(recipeId: recipe.recipePk),
                              ),
                            );
                          }
                        },
                        onLongPress: () {
                          setState(() {
                            _expandedRecipeId = isExpanded ? null : recipe.recipePk;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: recipe.colour != null
                                        ? Color(
                                            int.parse(
                                              recipe.colour!.replaceFirst(
                                                '#',
                                                '0xFF',
                                              ),
                                            ),
                                          )
                                        : theme.colorScheme.primary,
                                    child: const Icon(
                                      Icons.restaurant,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (recipe.description != null &&
                                            recipe.description!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            recipe.description!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStaticFinancialGridItem(
                                      context,
                                      settings,
                                      l10n.total_cost,
                                      '${settings.currencySymbol}${RecipeUtils.formatNumber(financials.totalCost)}',
                                      theme.colorScheme.errorContainer,
                                      theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStaticFinancialGridItem(
                                      context,
                                      settings,
                                      l10n.total_profit,
                                      '${settings.currencySymbol}${RecipeUtils.formatNumber(financials.totalProfit)}',
                                      theme.colorScheme.primaryContainer,
                                      theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStaticFinancialGridItem(
                                      context,
                                      settings,
                                      l10n.financial_price,
                                      '${settings.currencySymbol}${RecipeUtils.formatNumber(recipe.targetPricePerPortion)}',
                                      theme.colorScheme.secondaryContainer,
                                      theme.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: isExpanded
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 12),
                                          Divider(
                                            height: 1,
                                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildMenuButton(
                                                  context: context,
                                                  icon: Icons.edit_outlined,
                                                  label: l10n.edit_button,
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RecipeEditorScreen(recipeId: recipe.recipePk),
                                                      ),
                                                    ).then((_) {
                                                      setState(() {
                                                        _expandedRecipeId = null;
                                                      });
                                                    });
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildMenuButton(
                                                  context: context,
                                                  icon: Icons.scale_outlined,
                                                  label: l10n.scale_button,
                                                  onTap: () {
                                                    _showScalePickerFromList(context, recipe);
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildMenuButton(
                                                  context: context,
                                                  icon: Icons.copy_rounded,
                                                  label: l10n.duplicate_button,
                                                  onTap: () {
                                                    _duplicateRecipeFromList(context, recipe);
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildMenuButton(
                                                  context: context,
                                                  icon: Icons.delete_outline_rounded,
                                                  label: l10n.delete_button,
                                                  color: theme.colorScheme.error,
                                                  onTap: () {
                                                    _deleteRecipeFromList(context, recipe);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: filteredRecipes.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(child: Text(l10n.error_prefix(error.toString()))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticFinancialGridItem(
    BuildContext context,
    SettingsState settings,
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    String shortLabel = label;

    if (label.toLowerCase().contains('cost')) {
      shortLabel = l10n.short_cost;
    } else if (label.toLowerCase().contains('profit') ||
        label.toLowerCase().contains('ganancia')) {
      shortLabel = l10n.short_profit;
    } else if (label.toLowerCase().contains('price') ||
        label.toLowerCase().contains('precio')) {
      shortLabel = l10n.short_price_portion;
    }

    final effectiveBgColor = settings.numberColorsEnabled
        ? bgColor
        : theme.colorScheme.surfaceContainerHighest;
    final effectiveTextColor = settings.numberColorsEnabled
        ? textColor
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: effectiveBgColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            shortLabel,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: effectiveTextColor.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: effectiveTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // helper methods for context menu in expanded box
  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: buttonColor,
              size: 22,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: buttonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _duplicateRecipeFromList(BuildContext context, Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final textController = TextEditingController(text: "${recipe.name} (${l10n.duplicate_button})");
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.duplicate_button),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: l10n.recipe_name,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.discard_button),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(textController.text.trim()),
            child: Text(l10n.save_button),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      try {
        await db.duplicateRecipe(recipe.recipePk, newName);
        setState(() {
          _expandedRecipeId = null;
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

  void _deleteRecipeFromList(BuildContext context, Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete_recipe_title),
        content: Text(l10n.delete_recipe_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.discard_button),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete_button),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await db.deleteRecipe(recipe);
        setState(() {
          _expandedRecipeId = null;
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

  void _showScalePickerFromList(BuildContext context, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final customController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.scale_button),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [0.5, 2.0, 3.0, 4.0, 5.0].map((multiplier) {
                return OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openTemporaryScaledRecipeFromList(context, recipe, multiplier);
                  },
                  child: Text('x${RecipeUtils.formatNumber(multiplier)}'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: customController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.ingredient_quantity,
                hintText: 'e.g. 1.5',
                border: const OutlineInputBorder(),
                suffixText: 'x',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.discard_button),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(customController.text.replaceAll(',', '.'));
              if (val != null && val > 0) {
                Navigator.of(context).pop();
                _openTemporaryScaledRecipeFromList(context, recipe, val);
              }
            },
            child: Text(l10n.save_button),
          ),
        ],
      ),
    );
  }

  void _openTemporaryScaledRecipeFromList(BuildContext context, Recipe recipe, double multiplier) async {
    final db = ref.read(databaseProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final detail = await db.getRecipeDetail(recipe.recipePk);
      
      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading indicator
      
      final scaledYield = detail.recipe.defaultYield * multiplier;
      
      final initialIngs = detail.ingredients.map((ingData) {
        return InitialIngredientInput(
          ingredient: ingData.ingredient,
          amount: ingData.entry.amountNeeded * multiplier,
        );
      }).toList();

      final initialSteps = detail.steps.map((stepData) {
        return InitialStepInput(
          instruction: stepData.instruction,
        );
      }).toList();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RecipeEditorScreen(
            isTemporary: true,
            multiplier: multiplier,
            initialName: "${recipe.name} (x${RecipeUtils.formatNumber(multiplier)})",
            initialDescription: recipe.description,
            initialYield: RecipeUtils.formatNumber(scaledYield),
            initialYieldName: recipe.yieldName,
            initialProfitMargin: RecipeUtils.formatNumber(recipe.targetProfitMargin * 100),
            initialPrice: RecipeUtils.formatNumber(recipe.targetPricePerPortion),
            initialIngredients: initialIngs,
            initialSteps: initialSteps,
          ),
        ),
      ).then((_) {
        setState(() {
          _expandedRecipeId = null;
        });
      });
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error scaling recipe: $e")),
        );
      }
    }
  }
}

IconData getNavBarIcon(int index, bool isSelected, String iconStyle) {
  if (isSelected) {
    switch (index) {
      case 0: return Icons.home;
      case 1: return Icons.inventory_2;
      case 2: return Icons.handyman;
      case 3: return Icons.settings;
    }
  }
  
  if (iconStyle == 'rounded') {
    switch (index) {
      case 0: return Icons.home_rounded;
      case 1: return Icons.inventory_2_rounded;
      case 2: return Icons.handyman_rounded;
      case 3: return Icons.settings_rounded;
    }
  } else if (iconStyle == 'sharp') {
    switch (index) {
      case 0: return Icons.home_sharp;
      case 1: return Icons.inventory_2_sharp;
      case 2: return Icons.handyman_sharp;
      case 3: return Icons.settings_sharp;
    }
  } else {
    // outlined
    switch (index) {
      case 0: return Icons.home_outlined;
      case 1: return Icons.inventory_2_outlined;
      case 2: return Icons.handyman_outlined;
      case 3: return Icons.settings_outlined;
    }
  }
  return Icons.home_outlined;
}
