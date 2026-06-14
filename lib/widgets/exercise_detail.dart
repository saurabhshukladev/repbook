import 'package:flutter/material.dart';
import 'package:repbook/models/exercise.dart';

/// A full-screen dialog that displays the exercise GIF and allows swiping left/right to navigate between exercises in the active routine.
class ExerciseDetailDialog extends StatefulWidget {
  final List<Exercise> exercises;
  final int initialIndex;

  const ExerciseDetailDialog({
    super.key,
    required this.exercises,
    required this.initialIndex,
  });

  @override
  State<ExerciseDetailDialog> createState() => _ExerciseDetailDialogState();
}

class _ExerciseDetailDialogState extends State<ExerciseDetailDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentExercise = widget.exercises[_currentIndex];

    return Dialog.fullscreen(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            currentExercise.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close details',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.exercises.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final exercise = widget.exercises[index];
            return SafeArea(
              child: Column(
                children: [
                  // Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Semantics(
                          label: 'Enlarged demonstration GIF of ${exercise.name}',
                          image: true,
                          child: Image.network(
                            exercise.gifUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback UI for failed or mock image loads
                              return Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.fitness_center_rounded,
                                        color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                        size: 120,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Demonstration Placeholder',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                        child: Text(
                                          'Using mock URL:\n${exercise.gifUrl}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom Details Panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          exercise.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 22,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.exercises.length > 1) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: _currentIndex > 0 ? 1.0 : 0.2,
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Swipe for next (${_currentIndex + 1} of ${widget.exercises.length})',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Opacity(
                                opacity: _currentIndex < widget.exercises.length - 1 ? 1.0 : 0.2,
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
