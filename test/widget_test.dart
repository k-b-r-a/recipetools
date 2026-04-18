import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipetools/main.dart';
import 'package:recipetools/provider/database_provider.dart';

void main() {
  testWidgets('Recipe list smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the stream provider to return an empty list immediately
          recipesStreamProvider.overrideWith((ref) => Stream.value([])),
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
