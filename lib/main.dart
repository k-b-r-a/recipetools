import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'provider/database_provider.dart';

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

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

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
          });
        },
        children: _screens,
      ),
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
    if (_currentIndex == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          heroTag: 'add_recipe_fab',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      );
    } else if (_currentIndex == 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          heroTag: 'add_ingredient_fab',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddIngredientScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      );
    }
    return null;
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
              if (recipes.isEmpty) {
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
                          l10n.recipes_title,
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
                    final recipe = recipes[index];
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
                  }, childCount: recipes.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $error')),
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
