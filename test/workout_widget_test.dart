import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:repbook/models/exercise.dart';
import 'package:repbook/providers/workout_provider.dart';
import 'package:repbook/screens/home_screen.dart';
import 'package:repbook/services/workout_service.dart';
import 'package:repbook/widgets/exercise_detail.dart';

class FakeWorkoutService implements WorkoutService {
  final Map<String, List<Exercise>> schedule;
  final bool shouldFail;
  final Duration delay;

  FakeWorkoutService({
    required this.schedule,
    this.shouldFail = false,
    this.delay = Duration.zero,
  });

  @override
  Future<Map<String, List<Exercise>>> fetchSchedule() async {
    await Future.delayed(delay);
    if (shouldFail) {
      throw Exception('Fake API failure');
    }
    return schedule;
  }
}

class RetryWorkoutService implements WorkoutService {
  int callCount = 0;
  final Map<String, List<Exercise>> schedule;

  RetryWorkoutService({required this.schedule});

  @override
  Future<Map<String, List<Exercise>>> fetchSchedule() async {
    callCount++;
    if (callCount == 1) {
      throw Exception('Network connection timed out');
    }
    return schedule;
  }
}

void main() {
  late Map<String, List<Exercise>> testSchedule;

  setUp(() {
    testSchedule = {
      'Monday': [
        const Exercise(name: 'Barbell Bench Press', gifUrl: 'https://example.com/gifs/bench-press.gif'),
        const Exercise(name: 'Lat Pulldown', gifUrl: 'https://example.com/gifs/lat-pulldown.gif'),
      ],
      'Tuesday': [
        const Exercise(name: 'Barbell Squat', gifUrl: 'https://example.com/gifs/barbell-squat.gif'),
      ],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };
  });

  Widget buildTestWidget({required WorkoutService service}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkoutProvider>(
          create: (context) => WorkoutProvider(
            workoutService: service,
            initialDayIndex: 0,
          ),
        ),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('renders loading skeleton while fetching', (WidgetTester tester) async {
    final service = FakeWorkoutService(
      schedule: testSchedule,
      delay: const Duration(seconds: 1),
    );

    await tester.pumpWidget(buildTestWidget(service: service));

    // Verify skeleton loaders are visible initially (since there are 3 mocked in the list builder)
    expect(find.byType(Card), findsNWidgets(3));
    expect(find.text('Monday Routine'), findsNothing);

    // Complete the delayed future
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(); // frame rebuild

    // Verify actual routine data is displayed
    expect(find.text('Monday Routine'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(find.text('Lat Pulldown'), findsOneWidget);
  });

  testWidgets('renders empty days with recovery message', (WidgetTester tester) async {
    final service = FakeWorkoutService(schedule: testSchedule);

    await tester.pumpWidget(buildTestWidget(service: service));
    await tester.pumpAndSettle();

    // Starts on Monday, verify Monday data
    expect(find.text('Barbell Bench Press'), findsOneWidget);

    // Tap on Wednesday tab (index 2)
    await tester.tap(find.text('Wed'));
    await tester.pumpAndSettle();

    // Verify empty day recovery state is active
    expect(find.text('No exercises planned'), findsOneWidget);
    expect(find.text('Enjoy your rest day! Focus on recovery.'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsNothing);
  });

  testWidgets('navigates between days using BottomNavigationBar', (WidgetTester tester) async {
    final service = FakeWorkoutService(schedule: testSchedule);

    await tester.pumpWidget(buildTestWidget(service: service));
    await tester.pumpAndSettle();

    // Starts on Monday, verify Monday data
    expect(find.text('Monday Routine'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget);

    // Tap on Tuesday tab (index 1)
    await tester.tap(find.text('Tue'));
    await tester.pumpAndSettle();

    // Verify Tuesday data
    expect(find.text('Tuesday Routine'), findsOneWidget);
    expect(find.text('Barbell Squat'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsNothing);
  });

  testWidgets('tapping an exercise opens enlarged detail dialog and allows swiping', (WidgetTester tester) async {
    final service = FakeWorkoutService(schedule: testSchedule);

    await tester.pumpWidget(buildTestWidget(service: service));
    await tester.pumpAndSettle();

    // Tap on first exercise card (Monday has: Barbell Bench Press & Lat Pulldown)
    await tester.tap(find.text('Barbell Bench Press'));
    await tester.pumpAndSettle();

    // Verify full-screen detail dialog is presented
    expect(find.byType(ExerciseDetailDialog), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsNWidgets(3));
    expect(find.text('Swipe for next (1 of 2)'), findsOneWidget);

    // Swipe to next exercise (fling right to left)
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 2000);
    await tester.pumpAndSettle();

    // Verify second exercise 'Lat Pulldown' is now rendered
    expect(find.text('Lat Pulldown'), findsNWidgets(3));
    expect(find.text('Swipe for next (2 of 2)'), findsOneWidget);

    // Swipe back to first exercise (fling left to right)
    await tester.fling(find.byType(PageView), const Offset(400, 0), 2000);
    await tester.pumpAndSettle();

    // Verify first exercise is back
    expect(find.text('Barbell Bench Press'), findsNWidgets(3));

    // Tap close button to return to home
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Verify dialog has been popped
    expect(find.byType(ExerciseDetailDialog), findsNothing);
  });

  testWidgets('renders error state and triggers retry', (WidgetTester tester) async {
    final service = RetryWorkoutService(schedule: testSchedule);

    await tester.pumpWidget(buildTestWidget(service: service));
    await tester.pumpAndSettle();

    // Verify error state is rendered
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Network connection timed out'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    // Tap try again to invoke call #2 (which succeeds)
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();

    // Verify success state is rendered
    expect(find.text('Monday Routine'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsOneWidget);
    expect(service.callCount, 2);
  });
}
