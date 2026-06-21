import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/cloud_sync_service.dart';
import 'database_provider.dart';

class CloudSyncState {
  final bool signedIn;
  final String? email;
  final List<BackupFile> backups;
  final bool loading;
  final String? errorMessage;
  final String? successMessage;
  final CloudSyncStorageType storageType;
  final String? clientId;

  CloudSyncState({
    this.signedIn = false,
    this.email,
    this.backups = const [],
    this.loading = false,
    this.errorMessage,
    this.successMessage,
    this.storageType = CloudSyncStorageType.googleDrive,
    this.clientId,
  });

  CloudSyncState copyWith({
    bool? signedIn,
    String? email,
    List<BackupFile>? backups,
    bool? loading,
    String? errorMessage,
    String? successMessage,
    CloudSyncStorageType? storageType,
    String? clientId,
  }) {
    return CloudSyncState(
      signedIn: signedIn ?? this.signedIn,
      email: email ?? this.email,
      backups: backups ?? this.backups,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      storageType: storageType ?? this.storageType,
      clientId: clientId ?? this.clientId,
    );
  }
}

class CloudSyncNotifier extends Notifier<CloudSyncState> {
  late final GoogleDriveSyncService _syncService;

  @override
  CloudSyncState build() {
    _syncService = ref.watch(googleDriveSyncServiceProvider);
    
    // Check initial connection status asynchronously
    Future.microtask(() => checkStatus());

    return CloudSyncState();
  }

  Future<void> checkStatus() async {
    state = state.copyWith(loading: true);
    try {
      final signedIn = await _syncService.isSignedIn();
      final storageType = await _syncService.getStorageType();
      final clientId = await _syncService.getClientId();
      String? email;
      List<BackupFile> backups = [];
      if (signedIn) {
        email = await _syncService.getUserEmail();
        backups = await _syncService.getBackups();
      } else {
        // If local backups mode, we can still load list of local backups
        if (storageType == CloudSyncStorageType.localDirectory) {
          backups = await _syncService.getBackups();
        }
      }
      state = state.copyWith(
        signedIn: signedIn,
        email: email,
        backups: backups,
        storageType: storageType,
        clientId: clientId,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Failed to verify cloud sync connection status.',
      );
    }
  }

  Future<void> setStorageType(CloudSyncStorageType type) async {
    state = state.copyWith(loading: true);
    await _syncService.signOut(); // Sign out of existing connection
    await _syncService.setStorageType(type);
    
    final backups = await _syncService.getBackups();
    
    state = CloudSyncState(
      storageType: type,
      clientId: state.clientId,
      signedIn: type == CloudSyncStorageType.localDirectory, // Local Sandbox mode is always connected
      email: type == CloudSyncStorageType.localDirectory ? 'Local Sandbox' : null,
      backups: backups,
      loading: false,
    );
  }

  Future<void> setClientId(String? clientId) async {
    await _syncService.setClientId(clientId);
    state = state.copyWith(clientId: clientId);
  }

  Future<void> signIn() async {
    state = state.copyWith(loading: true);
    final error = await _syncService.signIn();
    if (error == null) {
      final email = await _syncService.getUserEmail();
      final backups = await _syncService.getBackups();
      state = state.copyWith(
        signedIn: true,
        email: email,
        backups: backups,
        loading: false,
        successMessage: 'Connected successfully.',
      );
    } else {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Connection failed: $error',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(loading: true);
    await _syncService.signOut();
    // Re-check status to load backups in case of local mode
    final storageType = await _syncService.getStorageType();
    final list = storageType == CloudSyncStorageType.localDirectory
        ? await _syncService.getBackups()
        : const <BackupFile>[];
    state = CloudSyncState(
      storageType: storageType,
      clientId: state.clientId,
      backups: list,
    );
  }

  Future<void> refreshBackups() async {
    state = state.copyWith(loading: true);
    try {
      final list = await _syncService.getBackups();
      state = state.copyWith(backups: list, loading: false);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Failed to retrieve backups: $e',
      );
    }
  }

  Future<bool> createBackup() async {
    state = state.copyWith(loading: true);
    try {
      final success = await _syncService.createBackup();
      if (success) {
        final list = await _syncService.getBackups();
        state = state.copyWith(
          backups: list,
          loading: false,
          successMessage: 'Backup created successfully.',
        );
        return true;
      } else {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Failed to create backup.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Backup operation error: $e',
      );
      return false;
    }
  }

  Future<bool> restoreBackup(String backupId) async {
    state = state.copyWith(loading: true);
    try {
      final success = await _syncService.restoreBackup(backupId);
      if (success) {
        ref.read(databaseProvider.notifier).refreshDatabase();
        state = state.copyWith(
          loading: false,
          successMessage: 'Database restored successfully.',
        );
        return true;
      } else {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Failed to restore database.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Restore operation error: $e',
      );
      return false;
    }
  }

  Future<bool> deleteBackup(String backupId) async {
    state = state.copyWith(loading: true);
    try {
      final success = await _syncService.deleteBackup(backupId);
      if (success) {
        final list = await _syncService.getBackups();
        state = state.copyWith(
          backups: list,
          loading: false,
          successMessage: 'Backup deleted successfully.',
        );
        return true;
      } else {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Failed to delete backup.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Delete operation error: $e',
      );
      return false;
    }
  }
}

final googleDriveSyncServiceProvider = Provider<GoogleDriveSyncService>((ref) {
  return GoogleDriveSyncService();
});

final cloudSyncProvider = NotifierProvider<CloudSyncNotifier, CloudSyncState>(CloudSyncNotifier.new);
