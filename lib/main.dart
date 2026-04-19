import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'provider/database_provider.dart';

import 'screens/recipe_screen.dart';

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
      home: const RecipeListScreen(),
    );
  }
}

class RecipeListScreen extends ConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recipesAsync = ref.watch(recipesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipes_title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: recipesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
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
                    l10n.recipes_title, // Using title as placeholder for "No recipes"
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(recipe.name),
                subtitle: Text(recipe.description ?? ''),
                leading: CircleAvatar(
                  backgroundColor: recipe.colour != null
                      ? Color(
                          int.parse(recipe.colour!.replaceFirst('#', '0xFF')),
                        )
                      : Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.restaurant, color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecipeScreen(
                        recipeId: recipe.recipePk,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const RecipeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
