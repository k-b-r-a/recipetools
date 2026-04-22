import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'provider/database_provider.dart';
import 'database/database.dart';

import 'screens/recipe_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/ingredients_screen.dart';
import 'screens/add_ingredient_screen.dart';

void main() {
  runApp(const ProviderScope(child: RecipetoolsApp()));
}

class RecipetoolsApp extends StatelessWidget {
  const RecipetoolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.recipes_title,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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
    const PlaceholderScreen(
      titleKey: 'tools_title',
      icon: Icons.handyman_outlined,
    ),
    const PlaceholderScreen(
      titleKey: 'config_button',
      icon: Icons.settings_outlined,
    ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFab(context),
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
                    height: 50,
                  ),
                  child: NavigationBar(
                    height: 50,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    selectedIndex: _currentIndex,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysHide,
                    onDestinationSelected: (index) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.home_outlined, size: 22),
                        selectedIcon: const Icon(Icons.home, size: 22),
                        label: l10n.recipes_title,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.inventory_2_outlined, size: 22),
                        selectedIcon: const Icon(Icons.inventory_2, size: 22),
                        label: l10n.ingredients_title,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.handyman_outlined, size: 22),
                        selectedIcon: const Icon(Icons.handyman, size: 22),
                        label: l10n.tools_title,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.settings_outlined, size: 22),
                        selectedIcon: const Icon(Icons.settings, size: 22),
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

  Widget? _buildFab(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    // determine visibility based on current screen
    final bool showFab = _currentIndex == 0 || _currentIndex == 1;

    return Container(
      width: screenWidth,
      height: 120, // enough height for the "jump" animation
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: IgnorePointer(
        ignoring: !showFab,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            // search bar - expands horizontally from the left of add button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              right: _isSearching ? 0 : 56 + 12,
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
                          ? Color.alphaBlend(theme.colorScheme.onSurface.withValues(alpha: 0.08), theme.colorScheme.secondaryContainer)
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
                        sigmaY: _isSearching ? 5 : 0
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
                                  ref.read(searchQueryProvider.notifier).setQuery(value);
                                },
                                style: theme.textTheme.bodyLarge,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  hintText: l10n.search_hint,
                                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5)
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(left: 16, right: 8, bottom: 4),
                                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                                  prefixIcon: Icon(Icons.search, size: 18, color: theme.colorScheme.primary),
                                  suffixIconConstraints: const BoxConstraints(minWidth: 40),
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _isSearching = false;
                                        _showSearchContent = false;
                                        _isSearchHovered = false;
                                        ref.read(searchQueryProvider.notifier).setQuery('');
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
                                Future.delayed(const Duration(milliseconds: 360), () {
                                  if (mounted && _isSearching) {
                                    setState(() => _showSearchContent = true);
                                  }
                                });
                              },
                              onHover: (hovering) => setState(() => _isSearchHovered = hovering),
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: Icon(
                                  Icons.search, 
                                  size: 20, 
                                  color: theme.colorScheme.onSecondaryContainer
                                )
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // add button - jumps up when searching, stays at the right
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              right: 0,
              bottom: _isSearching ? 44 + 12 : 0, // moves up above search bar
              child: AnimatedScale(
                scale: showFab ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isAddHovered = true),
                  onExit: (_) => setState(() => _isAddHovered = false),
                  child: FloatingActionButton(
                    heroTag: _currentIndex == 0 ? 'add_recipe_fab' : 'add_ingredient_fab',
                    elevation: 0,
                    hoverElevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    backgroundColor: _isAddHovered 
                      ? Color.alphaBlend(theme.colorScheme.onSurface.withValues(alpha: 0.08), theme.colorScheme.secondaryContainer)
                      : theme.colorScheme.secondaryContainer,
                    onPressed: () {
                      if (_currentIndex == 0) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddRecipeScreen(),
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
                    child: Icon(Icons.add, color: theme.colorScheme.onSecondaryContainer),
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

class IngredientSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  IngredientSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (query.isEmpty) {
      return Center(child: Text(l10n.search_ingredients_hint));
    }

    return Consumer(
      builder: (context, ref, child) {
        final results = ref.watch(relatedIngredientsProvider(query));

        return results.when(
          data: (ingredients) {
            if (ingredients.isEmpty) {
              return Center(child: Text(l10n.no_ingredients_found));
            }
            return ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                if (index >= ingredients.length) return const SizedBox.shrink();
                final ingredient = ingredients[index];
                return ListTile(
                  title: Text(ingredient.name),
                  subtitle: FutureBuilder<List<Unit>>(
                    future: ref.read(databaseProvider).getAllUnits(),
                    builder: (context, snapshot) {
                      final unitSymbol = snapshot.hasData
                          ? snapshot.data!
                              .firstWhere((u) => u.unitPk == ingredient.unitFk,
                                  orElse: () => const Unit(
                                      unitPk: '',
                                      name: '?',
                                      symbol: '',
                                      isMutable: false,
                                      factorToBase: 1.0))
                              .symbol
                          : '';
                      return Text(
                        l10n.ingredient_price_per_quantity(
                          ingredient.cost.toInt().toString(),
                          ingredient.quantityForCost.toInt().toString(),
                          unitSymbol,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    close(context, null);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddIngredientScreen(
                          ingredient: ingredient,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text(l10n.error_prefix(e.toString()))),
        );
      },
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
          _buildFloatingPillAppBar(context, title, _scrollController),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipesAsync = ref.watch(recipesStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildFloatingPillAppBar(
            context,
            l10n.recipes_title,
            _scrollController,
          ),
          recipesAsync.when(
            data: (recipes) {
              final filteredRecipes = recipes.where((recipe) {
                return recipe.name.toLowerCase().contains(searchQuery);
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
                    final recipe = filteredRecipes[index];
                    return ListTile(
                      title: Text(recipe.name),
                      subtitle: Text(recipe.description ?? ''),
                      leading: CircleAvatar(
                        backgroundColor: recipe.colour != null
                            ? Color(
                                int.parse(
                                  recipe.colour!.replaceFirst('#', '0xFF'),
                                ),
                              )
                            : theme.colorScheme.primary,
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeScreen(recipeId: recipe.recipePk),
                          ),
                        );
                      },
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
}

Widget _buildFloatingPillAppBar(
  BuildContext context,
  String title,
  ScrollController controller,
) {
  final theme = Theme.of(context);
  return SliverAppBar(
    pinned: true,
    expandedHeight: 120,
    collapsedHeight: 70,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: LayoutBuilder(
      builder: (context, constraints) {
        final double percentage =
            (constraints.maxHeight - kToolbarHeight) / (120 - kToolbarHeight);
        final bool isCollapsed = constraints.maxHeight <= kToolbarHeight + 20;

        return GestureDetector(
          onTap: () {
            controller.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          child: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.zero,
            title: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                bottom: isCollapsed ? 12 : 16,
                left: isCollapsed ? 60 : 0,
                right: isCollapsed ? 60 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(
                  alpha: isCollapsed ? 0.3 : 0.0,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: isCollapsed ? 0.2 : 0.0,
                  ),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: isCollapsed ? 5 : 0,
                    sigmaY: isCollapsed ? 5 : 0,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w900,
                      fontSize: 16 + (4 * percentage.clamp(0, 1)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
