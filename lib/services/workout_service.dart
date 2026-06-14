import 'dart:convert';
import 'package:repbook/models/exercise.dart';

/// An abstract interface defining the workout schedule data source.
abstract class WorkoutService {
  Future<Map<String, List<Exercise>>> fetchSchedule();
}

/// A mock implementation of [WorkoutService] using the placeholder JSON.
class MockWorkoutService implements WorkoutService {
  final bool shouldFail;
  final Duration delay;

  MockWorkoutService({
    this.shouldFail = false,
    this.delay = const Duration(milliseconds: 1500),
  });

  @override
  Future<Map<String, List<Exercise>>> fetchSchedule() async {
    await Future.delayed(delay);

    if (shouldFail) {
      throw Exception('Failed to load workout schedule. Please try again later.');
    }

    const placeholderJson = '''
    {
      "RepBook": {
        "Monday": [
          {"name": "Barbell Bench Press", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"},
          {"name": "Lat Pulldown", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"},
          {"name": "Overhead Press", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"}
        ],
        "Tuesday": [
          {"name": "Barbell Squat", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"},
          {"name": "Romanian Deadlift", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"},
          {"name": "Standing Calf Raise", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"}
        ],
        "Wednesday": [],
        "Thursday": [
          {"name": "Incline Dumbbell Press", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"},
          {"name": "Dumbbell Row", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"},
          {"name": "Lateral Raise", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"}
        ],
        "Friday": [
          {"name": "Leg Press", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"},
          {"name": "Leg Curl", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"},
          {"name": "Hanging Leg Raise", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"}
        ],
        "Saturday": [],
        "Sunday": []
      }
    }
    ''';

    try {
      final Map<String, dynamic> decoded = jsonDecode(placeholderJson) as Map<String, dynamic>;
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
      throw FormatException('Failed to parse workout schedule: $e');
    }
  }
}
