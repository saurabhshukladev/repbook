import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:repbook/providers/settings_provider.dart';
import 'package:repbook/providers/workout_provider.dart';
import 'package:repbook/screens/settings_screen.dart';
import 'package:repbook/widgets/exercise_card.dart';

/// The primary home screen containing the weekday tabs and active routine list.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load local settings and cached routine on startup
    Future.microtask(() async {
      if (mounted) {
        await context.read<SettingsProvider>().loadSettings();
        if (mounted) {
          context.read<WorkoutProvider>().loadSchedule();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'GitHub Settings',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
            ),
            const SizedBox(width: 10),
            const Text('RepBook'),
          ],
        ),
        actions: [
          if (provider.status == WorkoutStatus.success || provider.status == WorkoutStatus.error)
            IconButton(
              icon: const Icon(Icons.sync_rounded),
              tooltip: 'Sync schedule',
              onPressed: () {
                final settings = context.read<SettingsProvider>();
                if (settings.isConfigured) {
                  provider.syncSchedule(
                    token: settings.githubPat,
                    owner: settings.githubOwner,
                    repo: settings.githubRepo,
                    path: settings.githubPath,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please configure GitHub settings first.',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: Colors.white,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                }
              },
            ),
        ],
      ),
      body: _buildBody(context, provider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.selectedDayIndex,
        onTap: (index) => provider.selectDay(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day_outlined),
            activeIcon: Icon(Icons.calendar_view_day),
            label: 'Mon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day_outlined),
            activeIcon: Icon(Icons.calendar_view_day),
            label: 'Tue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day_outlined),
            activeIcon: Icon(Icons.calendar_view_day),
            label: 'Wed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day_outlined),
            activeIcon: Icon(Icons.calendar_view_day),
            label: 'Thu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day_outlined),
            activeIcon: Icon(Icons.calendar_view_day),
            label: 'Fri',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day_outlined),
            activeIcon: Icon(Icons.calendar_view_day),
            label: 'Sat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_day_outlined),
            activeIcon: Icon(Icons.calendar_view_day),
            label: 'Sun',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WorkoutProvider provider) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    switch (provider.status) {
      case WorkoutStatus.initial:
      case WorkoutStatus.loading:
        if (provider.syncProgressMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 24),
                  Text(
                    provider.syncProgressMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return const _LoadingSkeleton();
      case WorkoutStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'An unknown error occurred.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (settings.isConfigured) {
                      provider.syncSchedule(
                        token: settings.githubPat,
                        owner: settings.githubOwner,
                        repo: settings.githubRepo,
                        path: settings.githubPath,
                      );
                    } else {
                      provider.loadSchedule();
                    }
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case WorkoutStatus.success:
        // If the schedule is completely empty (no cached data)
        if (provider.schedule.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    settings.isConfigured ? 'Ready to Sync' : 'Configuration Required',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      settings.isConfigured
                          ? 'Tap the Sync button on the top-right to download your routine and exercise GIFs from GitHub.'
                          : 'Tap the Settings icon on the top-left to configure your GitHub Personal Access Token and repository details.',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!settings.isConfigured)
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      ),
                      icon: const Icon(Icons.settings_rounded),
                      label: const Text('Go to Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        final exercises = provider.selectedDayExercises;
        if (exercises.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exercises planned',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enjoy your rest day! Focus on recovery.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
              child: Text(
                '${provider.selectedDayName} Routine',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return ExerciseCard(exercise: exercises[index]);
                },
              ),
            ),
          ],
        );
    }
  }
}

/// A custom pulsing skeleton screen shown while loading data.
class _LoadingSkeleton extends StatefulWidget {
  const _LoadingSkeleton();

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
                child: Container(
                  width: 140,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 120,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
