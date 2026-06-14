import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:repbook/models/exercise.dart';
import 'package:repbook/providers/workout_provider.dart';
import 'package:repbook/widgets/exercise_detail.dart';

/// A card widget showing exercise information with a large, full-width GIF preview banner.
/// Tapping the card opens a detail modal with a pinch-to-zoom view of the exercise GIF.
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          final provider = Provider.of<WorkoutProvider>(context, listen: false);
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => ExerciseDetailDialog(
              exercises: provider.selectedDayExercises,
              initialIndex: provider.selectedDayExercises.indexOf(exercise),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GIF Preview Banner (Larger and fully visible in list view)
            Container(
              height: 180,
              color: theme.scaffoldBackgroundColor,
              child: Stack(
                children: [
                  Semantics(
                    label: 'GIF animation demonstrating ${exercise.name}',
                    image: true,
                    child: Image.network(
                      exercise.gifUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain, // Ensures the entire exercise movement is visible
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                            size: 64,
                          ),
                        );
                      },
                    ),
                  ),
                  // Subtle gradient overlay for visual polish
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Text Details & Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to view demonstration',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fullscreen_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
