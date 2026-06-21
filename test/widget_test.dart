import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipetools/main.dart';
import 'package:recipetools/provider/database_provider.dart';
import 'package:recipetools/provider/settings_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Recipe list smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          // Override the stream provider to return an empty list immediately
          recipesWithFinancialsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const RecipetoolsApp(),
      ),
    );

    // Wait for the stream to emit
    await tester.pump();
    await tester.pump();

    // After loading, it should show the empty state icon
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
  });
}
