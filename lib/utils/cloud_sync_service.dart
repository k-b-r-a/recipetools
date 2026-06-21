import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  // Check if we are running in simulation/mock mode
  bool get isSimulationMode =>
      kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  static const _simSignInKey = 'google_drive_sim_signed_in';
  static const _simEmailKey = 'google_drive_sim_email';

  // Local reference to the authenticated Google account (v7+ does not track this globally)
  GoogleSignInAccount? _currentUser;

  /// Checks if the user is currently signed in.
  Future<bool> isSignedIn() async {
    if (isSimulationMode) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_simSignInKey) ?? false;
    }
    return _currentUser != null;
  }

  /// Gets the signed-in user's email address.
  Future<String?> getUserEmail() async {
    if (isSimulationMode) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_simEmailKey) ?? 'sandbox.user@gmail.com';
    }
    return _currentUser?.email;
  }

  /// Signs the user in to Google Drive.
  Future<bool> signIn() async {
    if (isSimulationMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_simSignInKey, true);
      await prefs.setString(_simEmailKey, 'sandbox.user@gmail.com');
      return true;
    }
    try {
      await GoogleSignIn.instance.initialize();
      final account = await GoogleSignIn.instance.authenticate();
      _currentUser = account;
      return _currentUser != null;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return false;
    }
  }

  /// Signs the user out.
  Future<void> signOut() async {
    if (isSimulationMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_simSignInKey, false);
      return;
    }
    _currentUser = null;
  }

  /// Gets the local SQLite file directory.
  Future<File> _getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'db.sqlite'));
  }

  /// Gets the mock Google Drive folder directory (used in simulation mode).
  Future<Directory> _getMockDriveDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final mockDir = Directory(p.join(docDir.path, 'google_drive_mock'));
    if (!await mockDir.exists()) {
      await mockDir.create(recursive: true);
    }
    return mockDir;
  }

  /// Lists all backups available on Google Drive.
  Future<List<BackupFile>> getBackups() async {
    if (isSimulationMode) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));

      final mockDir = await _getMockDriveDirectory();
      final List<BackupFile> list = [];
      final files = mockDir.listSync();
      
      for (var file in files) {
        if (file is File && p.basename(file.path).startsWith('backup_') && file.path.endsWith('.sqlite')) {
          final stats = file.statSync();
          final name = p.basename(file.path);
          list.add(
            BackupFile(
              id: file.path, // path acts as ID in simulation
              name: name,
              sizeBytes: stats.size,
              dateCreated: stats.changed,
            ),
          );
        }
      }
      // Sort backups by date descending (newest first)
      list.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      return list;
    }

    try {
      final client = await _getGoogleClient();
      if (client == null) return [];
      
      final driveApi = drive.DriveApi(client);
      
      // Query appDataFolder for sqlite backups
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
      return [];
    }
  }

  /// Creates a backup of the current database.
  Future<bool> createBackup() async {
    final dbFile = await _getDatabaseFile();
    if (!await dbFile.exists()) return false;

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final backupFileName = 'backup_$timestamp.sqlite';

    if (isSimulationMode) {
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

  /// Restores the database from a backup file.
  Future<bool> restoreBackup(String backupId) async {
    final dbFile = await _getDatabaseFile();

    if (isSimulationMode) {
      await Future.delayed(const Duration(milliseconds: 1200));
      final sourceFile = File(backupId);
      if (!await sourceFile.exists()) return false;

      // Copy backup over existing db.sqlite
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

      // Write bytes over main database
      await dbFile.writeAsBytes(fileBytes);
      return true;
    } catch (e) {
      debugPrint('Error restoring Google Drive backup: $e');
      return false;
    }
  }

  /// Deletes a backup from Google Drive.
  Future<bool> deleteBackup(String backupId) async {
    if (isSimulationMode) {
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

  /// Authenticated HTTP client helper for Google API access.
  Future<http.Client?> _getGoogleClient() async {
    final account = _currentUser;
    if (account == null) return null;

    final clientAuth = await account.authorizationClient.authorizeScopes([
      drive.DriveApi.driveAppdataScope,
    ]);

    final token = clientAuth.accessToken;

    final credentials = auth.AccessCredentials(
      auth.AccessToken(
        'Bearer',
        token,
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      null,
      [drive.DriveApi.driveAppdataScope],
    );

    return auth.authenticatedClient(http.Client(), credentials);
  }
}
