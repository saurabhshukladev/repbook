import 'package:flutter/foundation.dart';
import 'package:repbook/models/exercise.dart';
import 'package:repbook/services/workout_service.dart';

/// Represents the loading/rendering state of the workout data.
enum WorkoutStatus { initial, loading, success, error }

/// A state provider that handles fetching schedules and active weekday selection.
class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService;

  WorkoutStatus _status = WorkoutStatus.initial;
  WorkoutStatus get status => _status;

  Map<String, List<Exercise>> _schedule = {};
  Map<String, List<Exercise>> get schedule => _schedule;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _syncProgressMessage;
  String? get syncProgressMessage => _syncProgressMessage;

  int _selectedDayIndex = 0;
  int get selectedDayIndex => _selectedDayIndex;

  WorkoutProvider({
    required WorkoutService workoutService,
    int? initialDayIndex,
  }) : _workoutService = workoutService {
    // Default the selected day to today's day of the week (1 = Monday, 7 = Sunday)
    _selectedDayIndex = initialDayIndex ?? (DateTime.now().weekday - 1);
  }

  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  String get selectedDayName => weekdays[_selectedDayIndex];

  List<Exercise> get selectedDayExercises => _schedule[selectedDayName] ?? [];

  /// Changes the currently active weekday selection.
  void selectDay(int index) {
    if (index >= 0 && index < weekdays.length) {
      _selectedDayIndex = index;
      notifyListeners();
    }
  }

  /// Loads the schedule locally from disk.
  Future<void> loadSchedule() async {
    _status = WorkoutStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedule = await _workoutService.fetchSchedule();
      _status = WorkoutStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = WorkoutStatus.error;
    }
    notifyListeners();
  }

  /// Triggers an authenticated remote sync with GitHub, downloading the raw JSON
  /// and referenced GIF files to local disk storage.
  Future<void> syncSchedule({
    required String token,
    required String owner,
    required String repo,
    required String path,
  }) async {
    if (_workoutService is! GitHubWorkoutService) {
      // Fallback for MockWorkoutService
      await loadSchedule();
      return;
    }

    _status = WorkoutStatus.loading;
    _syncProgressMessage = 'Starting sync...';
    _errorMessage = null;
    notifyListeners();

    try {
      _schedule = await _workoutService.syncSchedule(
        token: token,
        owner: owner,
        repo: repo,
        path: path,
        onProgress: (progress) {
          _syncProgressMessage = progress;
          notifyListeners();
        },
      );
      _status = WorkoutStatus.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = WorkoutStatus.error;
    } finally {
      _syncProgressMessage = null;
      notifyListeners();
    }
  }
}
