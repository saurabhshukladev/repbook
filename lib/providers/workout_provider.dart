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

  /// Triggers a fetch call to the workout service and transitions state accordingly.
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
}
