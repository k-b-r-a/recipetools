import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as p;
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

  CloudSyncState({
    this.signedIn = false,
    this.email,
    this.backups = const [],
    this.loading = false,
    this.errorMessage,
    this.successMessage,
    this.storageType = CloudSyncStorageType.googleDrive,
  });

  CloudSyncState copyWith({
    bool? signedIn,
    String? email,
    List<BackupFile>? backups,
    bool? loading,
    String? errorMessage,
    String? successMessage,
    CloudSyncStorageType? storageType,
  }) {
    return CloudSyncState(
      signedIn: signedIn ?? this.signedIn,
      email: email ?? this.email,
      backups: backups ?? this.backups,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      storageType: storageType ?? this.storageType,
    );
  }
}

class CloudSyncNotifier extends Notifier<CloudSyncState> {
  GoogleDriveSyncService get _syncService => ref.read(googleDriveSyncServiceProvider);

  @override
  CloudSyncState build() {
    // Check initial connection status asynchronously
    Future.microtask(() => checkStatus());

    return CloudSyncState();
  }

  Future<void> checkStatus() async {
    state = state.copyWith(loading: true);
    try {
      final storageType = await _syncService.getStorageType();
      
      GoogleSignInAccount? account;
      if (storageType == CloudSyncStorageType.googleDrive) {
        await GoogleSignIn.instance.initialize(
          clientId: GoogleDriveSyncService.defaultClientId,
          serverClientId: GoogleDriveSyncService.defaultServerClientId,
        );
        account = await GoogleSignIn.instance.attemptLightweightAuthentication();
        ref.read(googleUserProvider.notifier).setUser(account);
      }
      
      final signedIn = storageType == CloudSyncStorageType.localDirectory || account != null;
      String? email;
      if (signedIn) {
        email = storageType == CloudSyncStorageType.localDirectory ? 'Local Backup' : account?.email;
      }
      
      final backups = await _syncService.getBackups();
      
      state = state.copyWith(
        signedIn: signedIn,
        email: email,
        backups: backups,
        storageType: storageType,
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
      signedIn: type == CloudSyncStorageType.localDirectory, // Local Backup mode is always connected
      email: type == CloudSyncStorageType.localDirectory ? 'Local Backup' : null,
      backups: backups,
      loading: false,
    );
  }

  Future<void> signIn() async {
    state = state.copyWith(loading: true);
    try {
      final account = await _syncService.signIn();
      final storageType = await _syncService.getStorageType();
      if (storageType == CloudSyncStorageType.localDirectory) {
        final backups = await _syncService.getBackups();
        state = state.copyWith(
          signedIn: true,
          email: 'Local Backup',
          backups: backups,
          loading: false,
          successMessage: 'Connected successfully.',
        );
      } else if (account != null) {
        ref.read(googleUserProvider.notifier).setUser(account);
        final backups = await _syncService.getBackups();
        state = state.copyWith(
          signedIn: true,
          email: account.email,
          backups: backups,
          loading: false,
          successMessage: 'Connected successfully.',
        );
      } else {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Sign-in cancelled by user.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Connection failed: $e',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(loading: true);
    await _syncService.signOut();
    ref.read(googleUserProvider.notifier).setUser(null);
    
    final storageType = await _syncService.getStorageType();
    final list = storageType == CloudSyncStorageType.localDirectory
        ? await _syncService.getBackups()
        : const <BackupFile>[];
    state = CloudSyncState(
      storageType: storageType,
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

  Future<bool> downloadBackup(String backupId, String fileName, String targetDirPath) async {
    state = state.copyWith(loading: true);
    try {
      final file = await _syncService.downloadBackupToLocal(backupId, fileName, targetDirPath);
      if (file != null) {
        state = state.copyWith(
          loading: false,
          successMessage: 'Backup saved: ${p.basename(file.path)}',
        );
        return true;
      } else {
        state = state.copyWith(
          loading: false,
          errorMessage: 'Failed to save backup.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Save operation error: $e',
      );
      return false;
    }
  }
}

class GoogleUserNotifier extends Notifier<GoogleSignInAccount?> {
  @override
  GoogleSignInAccount? build() {
    return null;
  }

  void setUser(GoogleSignInAccount? user) {
    state = user;
  }
}

final googleUserProvider = NotifierProvider<GoogleUserNotifier, GoogleSignInAccount?>(GoogleUserNotifier.new);

final googleDriveSyncServiceProvider = Provider<GoogleDriveSyncService>((ref) {
  final user = ref.watch(googleUserProvider);
  return GoogleDriveSyncService(user);
});

final cloudSyncProvider = NotifierProvider<CloudSyncNotifier, CloudSyncState>(CloudSyncNotifier.new);
