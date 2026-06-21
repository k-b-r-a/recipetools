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

  CloudSyncState({
    this.signedIn = false,
    this.email,
    this.backups = const [],
    this.loading = false,
    this.errorMessage,
    this.successMessage,
  });

  CloudSyncState copyWith({
    bool? signedIn,
    String? email,
    List<BackupFile>? backups,
    bool? loading,
    String? errorMessage,
    String? successMessage,
  }) {
    return CloudSyncState(
      signedIn: signedIn ?? this.signedIn,
      email: email ?? this.email,
      backups: backups ?? this.backups,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
      successMessage: successMessage,
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
      String? email;
      List<BackupFile> backups = [];
      if (signedIn) {
        email = await _syncService.getUserEmail();
        backups = await _syncService.getBackups();
      }
      state = state.copyWith(
        signedIn: signedIn,
        email: email,
        backups: backups,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Failed to verify cloud sync connection status.',
      );
    }
  }

  Future<void> signIn() async {
    state = state.copyWith(loading: true);
    final success = await _syncService.signIn();
    if (success) {
      final email = await _syncService.getUserEmail();
      final backups = await _syncService.getBackups();
      state = state.copyWith(
        signedIn: true,
        email: email,
        backups: backups,
        loading: false,
        successMessage: 'Connected to Google Drive successfully.',
      );
    } else {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Connection to Google Drive failed.',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(loading: true);
    await _syncService.signOut();
    state = CloudSyncState();
  }

  Future<void> refreshBackups() async {
    if (!state.signedIn) return;
    state = state.copyWith(loading: true);
    try {
      final list = await _syncService.getBackups();
      state = state.copyWith(backups: list, loading: false);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'Failed to retrieve backups from Google Drive.',
      );
    }
  }

  Future<bool> createBackup() async {
    if (!state.signedIn) return false;
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
    if (!state.signedIn) return false;
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
    if (!state.signedIn) return false;
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
