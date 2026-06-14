import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:repbook/providers/workout_provider.dart';
import 'package:repbook/screens/home_screen.dart';
import 'package:repbook/services/workout_service.dart';
import 'package:repbook/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WorkoutService>(
          create: (_) => MockWorkoutService(),
        ),
        ChangeNotifierProvider<WorkoutProvider>(
          create: (context) => WorkoutProvider(
            workoutService: context.read<WorkoutService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'RepBook',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
