# RepBook

A Flutter application for managing and displaying exercise routines, built using Material 3 and modern dark aesthetics.

---

## 1. Feature Architecture

The schedule UI and rendering logic are implemented under a clean, layered architecture:

- **UI Layer (Views)**
  - [`lib/screens/home_screen.dart`](file:///home/leo/Projects/repbook/lib/screens/home_screen.dart): Renders the main dashboard, BottomNavigationBar tabs (Mon–Sun), error/retry screens, empty day recovery displays, and a custom pulsing skeleton loader.
  - [`lib/widgets/exercise_card.dart`](file:///home/leo/Projects/repbook/lib/widgets/exercise_card.dart): Custom ListView items showing the exercise name, action indicators, and image loading/error fallback semantics.
  - [`lib/widgets/exercise_detail.dart`](file:///home/leo/Projects/repbook/lib/widgets/exercise_detail.dart): Full-screen details dialog featuring pinch-to-zoom technique inspection powered by `InteractiveViewer`.
- **Theme**
  - [`lib/theme/app_theme.dart`](file:///home/leo/Projects/repbook/lib/theme/app_theme.dart): Defines the design system with custom Material 3 Dark tones (Deep Slate `#121826`, Mint `#10B981`, Indigo `#6366F1`).
- **State/Logic Layer (ViewModel)**
  - [`lib/providers/workout_provider.dart`](file:///home/leo/Projects/repbook/lib/providers/workout_provider.dart): A ChangeNotifier that tracks weekday tabs selection and maps routine loads, loading status, and error states.
- **Data Layer (Repository/Service)**
  - [`lib/models/exercise.dart`](file:///home/leo/Projects/repbook/lib/models/exercise.dart): Plain data model representing an exercise with JSON serialization.
  - [`lib/services/workout_service.dart`](file:///home/leo/Projects/repbook/lib/services/workout_service.dart): Abstract interface and simulated Mock service for loading the schedule payload.

---

## 2. Pluggable Data Sources (Switching to the Real API)

To transition from the current mock placeholder response to a real production endpoint:

### Step A: Implement a Real Service
Create an HTTP client implementation conforming to `WorkoutService`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:repbook/models/exercise.dart';
import 'package:repbook/services/workout_service.dart';

class HttpWorkoutService implements WorkoutService {
  final http.Client client;
  final String apiEndpoint;

  HttpWorkoutService({required this.client, required this.apiEndpoint});

  @override
  Future<Map<String, List<Exercise>>> fetchSchedule() async {
    final response = await client.get(
      Uri.parse(apiEndpoint),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
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
    } else {
      throw Exception('Failed to load schedule (Status Code: ${response.statusCode})');
    }
  }
}
```

### Step B: Update Dependency Injection in `lib/main.dart`
In [`lib/main.dart`](file:///home/leo/Projects/repbook/lib/main.dart), swap the registered `WorkoutService` provider instantiation:

```diff
-        Provider<WorkoutService>(
-          create: (_) => MockWorkoutService(),
-        ),
+        Provider<WorkoutService>(
+          create: (_) => HttpWorkoutService(
+            client: http.Client(),
+            apiEndpoint: 'https://api.yourdomain.com/v1/schedule',
+          ),
+        ),
```

---

## 3. Testing

The suite includes 5 comprehensive widget tests covering rendering with data, rendering empty rest days, active BottomNavigationBar navigation, full-screen technique inspections, and error states with active retry button interactions.

To execute tests:
```bash
flutter test
```
