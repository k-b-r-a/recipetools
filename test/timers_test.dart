import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipetools/provider/timers_provider.dart';

void main() {
  group('KitchenTimersNotifier Tests', () {
    test('Initial state is empty list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final timers = container.read(kitchenTimersProvider);
      expect(timers, isEmpty);
    });

    test('Adding a timer creates item and starts countdown', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(kitchenTimersProvider.notifier);
      notifier.addTimer('Boil Eggs', 300, colorIndex: 2);

      var timers = container.read(kitchenTimersProvider);
      expect(timers.length, equals(1));
      expect(timers.first.name, equals('Boil Eggs'));
      expect(timers.first.totalSeconds, equals(300));
      expect(timers.first.remainingSeconds, equals(300));
      expect(timers.first.isRunning, isTrue);
      expect(timers.first.isFinished, isFalse);
    });

    test('Toggling, resetting, adding minutes and deleting timers work', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(kitchenTimersProvider.notifier);
      notifier.addTimer('Bake Cake', 600);

      var timers = container.read(kitchenTimersProvider);
      final id = timers.first.id;

      // Pause
      notifier.toggleTimer(id);
      timers = container.read(kitchenTimersProvider);
      expect(timers.first.isRunning, isFalse);

      // Add minutes
      notifier.addMinutes(id, 5);
      timers = container.read(kitchenTimersProvider);
      expect(timers.first.totalSeconds, equals(900));
      expect(timers.first.remainingSeconds, equals(900));

      // Delete
      notifier.deleteTimer(id);
      timers = container.read(kitchenTimersProvider);
      expect(timers, isEmpty);
    });
  });
}
