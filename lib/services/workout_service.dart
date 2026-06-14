import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:repbook/models/exercise.dart';
import 'package:repbook/services/cache_service.dart';
import 'package:repbook/services/github_service.dart';

/// An abstract interface defining the workout schedule data source.
abstract class WorkoutService {
  Future<Map<String, List<Exercise>>> fetchSchedule();
}

/// A concrete implementation of [WorkoutService] using the authenticated GitHub API
/// and local caching services to support full offline capabilities.
class GitHubWorkoutService implements WorkoutService {
  final GitHubService gitHubService;
  final CacheService cacheService;

  GitHubWorkoutService({
    required this.gitHubService,
    required this.cacheService,
  });

  /// Loads the workout schedule using local cached JSON and matches downloaded GIF files.
  @override
  Future<Map<String, List<Exercise>>> fetchSchedule() async {
    return loadLocalMappedSchedule();
  }

  /// Downloads the routine JSON from GitHub, saves it locally, and downloads all referenced GIF images.
  /// Returns a fully local-mapped routine schedule.
  Future<Map<String, List<Exercise>>> syncSchedule({
    required String token,
    required String owner,
    required String repo,
    required String path,
    Function(String progress)? onProgress,
  }) async {
    onProgress?.call('Fetching schedule from GitHub...');
    final rawJson = await gitHubService.fetchRawSchedule(
      token: token,
      owner: owner,
      repo: repo,
      path: path,
    );

    // Save JSON cache locally
    await cacheService.saveJsonCache(rawJson);

    // Parse to extract exercise URLs
    final schedule = _parseJson(rawJson);

    final List<Exercise> allExercises = [];
    schedule.forEach((_, exercises) {
      allExercises.addAll(exercises);
    });

    // Cache unique exercise GIFs
    final Set<String> processedUrls = {};
    for (int i = 0; i < allExercises.length; i++) {
      final exercise = allExercises[i];
      if (processedUrls.contains(exercise.gifUrl)) continue;

      onProgress?.call('Caching GIF (${i + 1}/${allExercises.length}): ${exercise.name}...');

      try {
        final alreadyCached = await cacheService.gifExists(exercise.gifUrl);
        if (!alreadyCached) {
          final bytes = await gitHubService.downloadBytes(exercise.gifUrl);
          await cacheService.saveGif(exercise.gifUrl, bytes);
        }
        processedUrls.add(exercise.gifUrl);
      } catch (e) {
        // Log individual errors but continue syncing other exercises
        // so the sync process is robust against single-image failures.
        debugPrint('Error caching GIF for ${exercise.name}: $e');
      }
    }

    return loadLocalMappedSchedule();
  }

  /// Reads local cached JSON and replaces remote GIF URLs with local absolute file paths where available.
  Future<Map<String, List<Exercise>>> loadLocalMappedSchedule() async {
    final cachedJson = await cacheService.readJsonCache();
    if (cachedJson == null) {
      return {}; // Empty schedule, user needs to run first sync
    }

    final schedule = _parseJson(cachedJson);
    final Map<String, List<Exercise>> localSchedule = {};

    for (final entry in schedule.entries) {
      final day = entry.key;
      final exercises = entry.value;
      final List<Exercise> mappedExercises = [];

      for (final exercise in exercises) {
        final cached = await cacheService.gifExists(exercise.gifUrl);
        if (cached) {
          final localPath = await cacheService.getGifLocalPath(exercise.gifUrl);
          mappedExercises.add(exercise.copyWith(localFilePath: localPath));
        } else {
          mappedExercises.add(exercise);
        }
      }
      localSchedule[day] = mappedExercises;
    }

    return localSchedule;
  }

  Map<String, List<Exercise>> _parseJson(String rawJson) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final repBook = decoded['RepBook'] as Map<String, dynamic>?;

      if (repBook == null) {
        throw const FormatException('Missing "RepBook" root property in schedule JSON.');
      }

      final Map<String, List<Exercise>> schedule = {};
      repBook.forEach((key, value) {
        if (value is List) {
          schedule[key] = value
              .map((item) => Exercise.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          schedule[key] = [];
        }
      });

      return schedule;
    } catch (e) {
      throw FormatException('Failed to parse workout schedule JSON: $e');
    }
  }
}
