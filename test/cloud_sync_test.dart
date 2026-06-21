import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipetools/provider/cloud_sync_provider.dart';
import 'package:recipetools/utils/cloud_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CloudSyncNotifier Tests', () {
    setUp(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return '.';
          }
          return null;
        },
      );
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state uses default settings and loads successfully', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Verify initial state is default
      var state = container.read(cloudSyncProvider);
      expect(state.loading, isFalse);
      expect(state.signedIn, isFalse);

      // Trigger status check
      await container.read(cloudSyncProvider.notifier).checkStatus();

      state = container.read(cloudSyncProvider);
      expect(state.loading, isFalse);
      
      final expectedType = container.read(googleDriveSyncServiceProvider).isDefaultSimulation
          ? CloudSyncStorageType.localDirectory
          : CloudSyncStorageType.googleDrive;
      expect(state.storageType, expectedType);
    });

    test('Switching storage type updates state and persists setting', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cloudSyncProvider.notifier);

      // Switch to local directory
      await notifier.setStorageType(CloudSyncStorageType.localDirectory);

      var state = container.read(cloudSyncProvider);
      expect(state.storageType, CloudSyncStorageType.localDirectory);
      expect(state.signedIn, isTrue); // Local backup is always connected
      expect(state.email, 'Local Backup');

      // Switch to Google Drive
      await notifier.setStorageType(CloudSyncStorageType.googleDrive);

      state = container.read(cloudSyncProvider);
      expect(state.storageType, CloudSyncStorageType.googleDrive);
      expect(state.signedIn, isFalse);
      expect(state.email, isNull);
    });

    test('Setting Google Client ID updates state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cloudSyncProvider.notifier);

      await notifier.setClientId('test-client-id.apps.googleusercontent.com');

      final state = container.read(cloudSyncProvider);
      expect(state.clientId, 'test-client-id.apps.googleusercontent.com');
    });
  });
}
