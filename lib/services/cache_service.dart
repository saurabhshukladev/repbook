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

  /// Saves downloaded GIF bytes locally using a safe name keyed off the URL.
  Future<String> saveGif(String gifUrl, List<int> bytes) async {
    final gifsDir = await getGifsDirectory();
    final safeFilename = _toSafeGifFilename(gifUrl);
    final file = File('$gifsDir/$safeFilename.gif');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Checks if a GIF for a specific URL is already cached locally.
  Future<bool> gifExists(String gifUrl) async {
    final gifsDir = await getGifsDirectory();
    final safeFilename = _toSafeGifFilename(gifUrl);
    final file = File('$gifsDir/$safeFilename.gif');
    return await file.exists();
  }

  /// Gets the local absolute path of a GIF, whether it exists or not.
  Future<String> getGifLocalPath(String gifUrl) async {
    final gifsDir = await getGifsDirectory();
    final safeFilename = _toSafeGifFilename(gifUrl);
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

  String _toSafeGifFilename(String url) {
    // Generate a unique, filesystem-safe filename from the URL
    final uri = Uri.tryParse(url);
    final path = uri?.path ?? url;
    final cleanPath = path.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_\-]'), '_');
    
    // Extract suffix to keep name length within safety limits
    if (cleanPath.length > 80) {
      return cleanPath.substring(cleanPath.length - 80);
    }
    return cleanPath;
  }
}
