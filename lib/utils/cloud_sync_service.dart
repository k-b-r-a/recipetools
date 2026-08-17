import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum CloudSyncStorageType { googleDrive, localDirectory }

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class BackupFile {
  final String id;
  final String name;
  final int sizeBytes;
  final DateTime dateCreated;

  BackupFile({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.dateCreated,
  });
}

class GoogleDriveSyncService {
  static const defaultClientId = '942605231744-g6uaakf2kns45evmlgm3s467rkkii7ms.apps.googleusercontent.com';
  static const defaultServerClientId = '942605231744-c77i5tmm6767i2k0rktbavaklv60foka.apps.googleusercontent.com';
  static const _storageTypeKey = 'google_drive_storage_type';
  static const _simSignInKey = 'google_drive_sim_signed_in';
  static const _simEmailKey = 'google_drive_sim_email';

  // Check if the current platform defaults to simulation mode
  bool get isDefaultSimulation =>
      kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  final GoogleSignInAccount? _currentUser;

  GoogleDriveSyncService(this._currentUser);

  /// Gets the current storage type from settings.
  Future<CloudSyncStorageType> getStorageType() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_storageTypeKey) ?? (isDefaultSimulation ? 1 : 0);
    return CloudSyncStorageType.values[index];
  }

  /// Sets the storage type.
  Future<void> setStorageType(CloudSyncStorageType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageTypeKey, type.index);
  }

  /// Checks if the user is currently signed in/connected.
  Future<bool> isSignedIn() async {
    final isSim = (await getStorageType()) == CloudSyncStorageType.localDirectory;
    if (isSim) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_simSignInKey) ?? false;
    }
    return _currentUser != null;
  }

  /// Gets the signed-in user's email address or sandbox identifier.
  Future<String?> getUserEmail() async {
    final isSim = (await getStorageType()) == CloudSyncStorageType.localDirectory;
    if (isSim) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_simEmailKey) ?? 'sandbox.user@gmail.com';
    }
    return _currentUser?.email;
  }

  /// Connects / signs in. Returns the authenticated account on success.
  Future<GoogleSignInAccount?> signIn() async {
    final isSim = (await getStorageType()) == CloudSyncStorageType.localDirectory;
    if (isSim) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_simSignInKey, true);
      await prefs.setString(_simEmailKey, 'sandbox.user@gmail.com');
      return null;
    }

    // Ensure previous session is cleared so Google shows the Account Picker dialog
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    await GoogleSignIn.instance.initialize(
      clientId: defaultClientId,
      serverClientId: defaultServerClientId,
    );
    
    return await GoogleSignIn.instance.authenticate();
  }

  /// Signs the user out / disconnects.
  Future<void> signOut() async {
    final isSim = (await getStorageType()) == CloudSyncStorageType.localDirectory;
    if (isSim) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_simSignInKey, false);
      return;
    }
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('GoogleSignIn.signOut failed or unimplemented: $e');
    }
  }

  /// Gets the local SQLite file directory.
  Future<File> _getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'db.sqlite'));
  }

  /// Gets the local sandbox backup folder directory.
  Future<Directory> _getMockDriveDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final mockDir = Directory(p.join(docDir.path, 'recipetools_backups'));
    if (!await mockDir.exists()) {
      await mockDir.create(recursive: true);
    }
    return mockDir;
  }

  /// Lists all backups.
  Future<List<BackupFile>> getBackups() async {
    final isSim = (await getStorageType()) == CloudSyncStorageType.localDirectory;
    if (isSim) {
      await Future.delayed(const Duration(milliseconds: 600));

      final mockDir = await _getMockDriveDirectory();
      final List<BackupFile> list = [];
      if (!await mockDir.exists()) return list;
      
      final files = mockDir.listSync();
      for (var file in files) {
        if (file is File && p.basename(file.path).startsWith('backup_') && file.path.endsWith('.sqlite')) {
          final stats = file.statSync();
          final name = p.basename(file.path);
          list.add(
            BackupFile(
              id: file.path,
              name: name,
              sizeBytes: stats.size,
              dateCreated: stats.changed,
            ),
          );
        }
      }
      list.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      return list;
    }

    try {
      final client = await _getGoogleClient();
      if (client == null) return [];
      
      final driveApi = drive.DriveApi(client);
      
      final fileList = await driveApi.files.list(
        q: "mimeType = 'application/x-sqlite3' or name contains 'backup_'",
        spaces: 'appDataFolder',
        $fields: 'files(id, name, size, createdTime)',
      );

      final List<BackupFile> backups = [];
      if (fileList.files != null) {
        for (var file in fileList.files!) {
          backups.add(
            BackupFile(
              id: file.id ?? '',
              name: file.name ?? 'recipe_backup.sqlite',
              sizeBytes: int.tryParse(file.size ?? '0') ?? 0,
              dateCreated: file.createdTime ?? DateTime.now(),
            ),
          );
        }
      }
      backups.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      return backups;
    } catch (e) {
      debugPrint('Error getting Google Drive backups: $e');
      final errorStr = e.toString();
      if (errorStr.contains('403') || errorStr.contains('disabled') || errorStr.contains('drive.googleapis.com')) {
        throw Exception(
          'Google Drive API is disabled for project 942605231744. Enable it at: https://console.developers.google.com/apis/api/drive.googleapis.com/overview?project=942605231744',
        );
      }
      throw Exception('Google Drive error: $e');
    }
  }

  /// Creates a backup of the current database.
  Future<bool> createBackup() async {
    final dbFile = await _getDatabaseFile();
    if (!await dbFile.exists()) return false;

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final backupFileName = 'backup_$timestamp.sqlite';

    final isSim = (await getStorageType()) == CloudSyncStorageType.localDirectory;
    if (isSim) {
      await Future.delayed(const Duration(milliseconds: 1000));
      final mockDir = await _getMockDriveDirectory();
      final backupDest = File(p.join(mockDir.path, backupFileName));
      await dbFile.copy(backupDest.path);
      return true;
    }

    try {
      final client = await _getGoogleClient();
      if (client == null) return false;

      final driveApi = drive.DriveApi(client);
      final bytes = await dbFile.readAsBytes();

      final driveFile = drive.File()
        ..name = backupFileName
        ..parents = ['appDataFolder'];

      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: 'application/x-sqlite3',
      );

      final result = await driveApi.files.create(driveFile, uploadMedia: media);
      return result.id != null;
    } catch (e) {
      debugPrint('Error creating Google Drive backup: $e');
      return false;
    }
  }

  /// Restores the database from a backup.
  Future<bool> restoreBackup(String backupId) async {
    final dbFile = await _getDatabaseFile();

    final isSim = (await getStorageType()) == CloudSyncStorageType.localDirectory;
    if (isSim) {
      await Future.delayed(const Duration(milliseconds: 1200));
      final sourceFile = File(backupId);
      if (!await sourceFile.exists()) return false;

      await sourceFile.copy(dbFile.path);
      return true;
    }

    try {
      final client = await _getGoogleClient();
      if (client == null) return false;

      final driveApi = drive.DriveApi(client);

      final mediaResponse = await driveApi.files.get(
        backupId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> fileBytes = [];
      await for (var data in mediaResponse.stream) {
        fileBytes.addAll(data);
      }

      if (fileBytes.isEmpty) return false;

      await dbFile.writeAsBytes(fileBytes);
      return true;
    } catch (e) {
      debugPrint('Error restoring Google Drive backup: $e');
      return false;
    }
  }

  /// Deletes a backup.
  Future<bool> deleteBackup(String backupId) async {
    final isSim = (await getStorageType()) == CloudSyncStorageType.localDirectory;
    if (isSim) {
      await Future.delayed(const Duration(milliseconds: 500));
      final file = File(backupId);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    }

    try {
      final client = await _getGoogleClient();
      if (client == null) return false;

      final driveApi = drive.DriveApi(client);
      await driveApi.files.delete(backupId);
      return true;
    } catch (e) {
      debugPrint('Error deleting Google Drive backup: $e');
      return false;
    }
  }

  /// Downloads/exports a backup file to a target local directory path.
  Future<File?> downloadBackupToLocal(String backupId, String fileName, String targetDirPath) async {
    final isSim = (await getStorageType()) == CloudSyncStorageType.localDirectory;
    final exportFile = File(p.join(targetDirPath, fileName));

    if (isSim) {
      final sourceFile = File(backupId);
      if (!await sourceFile.exists()) return null;
      await sourceFile.copy(exportFile.path);
      return exportFile;
    }

    try {
      final client = await _getGoogleClient();
      if (client == null) return null;

      final driveApi = drive.DriveApi(client);
      final mediaResponse = await driveApi.files.get(
        backupId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> fileBytes = [];
      await for (var data in mediaResponse.stream) {
        fileBytes.addAll(data);
      }

      if (fileBytes.isEmpty) return null;

      await exportFile.writeAsBytes(fileBytes);
      return exportFile;
    } catch (e) {
      debugPrint('Error downloading backup: $e');
      return null;
    }
  }

  /// Authenticated HTTP client helper for Google API access.
  Future<http.Client?> _getGoogleClient() async {
    final account = _currentUser;
    if (account == null) return null;

    try {
      final authHeaders = await account.authorizationClient.authorizationHeaders([
        drive.DriveApi.driveAppdataScope,
      ], promptIfNecessary: true);

      if (authHeaders == null) return null;
      return GoogleAuthClient(authHeaders);
    } catch (e) {
      debugPrint('Error obtaining Google API authorization headers: $e');
      return null;
    }
  }
}
