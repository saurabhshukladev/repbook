import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Handles the persistence of the workout schedule JSON and exercise GIF files.
class CacheService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localJsonFile async {
    final path = await _localPath;
    return File('$path/schedule_cache.json');
  }

  /// Ensures and returns the local directory path where GIF files are stored.
  Future<String> getGifsDirectory() async {
    final path = await _localPath;
    final dir = Directory('$path/gifs');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// Persists the raw schedule JSON content to disk.
  Future<void> saveJsonCache(String jsonContent) async {
    final file = await _localJsonFile;
    await file.writeAsString(jsonContent);
  }

  /// Reads the cached raw schedule JSON content from disk if it exists.
  Future<String?> readJsonCache() async {
    try {
      final file = await _localJsonFile;
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Saves downloaded GIF bytes locally and returns the absolute file path.
  Future<String> saveGif(String exerciseName, List<int> bytes) async {
    final gifsDir = await getGifsDirectory();
    final safeFilename = _toSafeFilename(exerciseName);
    final file = File('$gifsDir/$safeFilename.gif');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Checks if a GIF for a specific exercise name is already cached locally.
  Future<bool> gifExists(String exerciseName) async {
    final gifsDir = await getGifsDirectory();
    final safeFilename = _toSafeFilename(exerciseName);
    final file = File('$gifsDir/$safeFilename.gif');
    return await file.exists();
  }

  /// Gets the local absolute path of a GIF, whether it exists or not.
  Future<String> getGifLocalPath(String exerciseName) async {
    final gifsDir = await getGifsDirectory();
    final safeFilename = _toSafeFilename(exerciseName);
    return '$gifsDir/$safeFilename.gif';
  }

  /// Deletes all locally cached JSON data and downloaded GIF files.
  Future<void> clearCache() async {
    try {
      final jsonFile = await _localJsonFile;
      if (await jsonFile.exists()) {
        await jsonFile.delete();
      }
      final path = await _localPath;
      final gifsDir = Directory('$path/gifs');
      if (await gifsDir.exists()) {
        await gifsDir.delete(recursive: true);
      }
    } catch (_) {}
  }

  String _toSafeFilename(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_\-]'), '_');
  }
}
