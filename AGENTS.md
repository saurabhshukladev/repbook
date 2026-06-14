# AGENTS.md

Welcome! This repository, **RepBook**, is a Flutter Android application for managing configurable exercise sets for each day of the week.

## 1. Project Overview
- **Objective**: Manage daily exercise sets (Monday–Sunday) with CRUD operations, completion tracking, reordering, and workout execution features.
- **Key Features**:
  - Configurable daily routines.
  - Exercise definition: Name, Category, Sets, Reps, Weight, Duration, and custom notes.
  - Interactive dashboard showing the current day's target exercises and real-time progress.
  - Support for local storage (shared preferences, SQLite, or custom JSON format).

## 2. Technical Stack
- **Framework**: Flutter (Dart)
- **State Management**: `provider` (standard/M3 style)
- **Local Persistence**: `shared_preferences` and/or `path_provider` + JSON files or SQLite (`sqflite`/`drift`)
- **UI System**: Material 3, custom modern dark aesthetics (deep slate `#121826`, mint `#10B981`, indigo `#6366F1`), with smooth micro-animations.

## 3. Directory Layout
- `lib/main.dart` - Entrypoint
- `lib/models/` - Data models (`exercise.dart`, `workout_day.dart`)
- `lib/providers/` - Logic & state (`workout_provider.dart`, `theme_provider.dart`)
- `lib/screens/` - Screen views (`home_screen.dart`, `routine_editor_screen.dart`, `exercise_editor_screen.dart`)
- `lib/widgets/` - Reusable UI elements (`exercise_card.dart`, `week_day_selector.dart`)
- `lib/theme/` - Color schemes, typography, and styling presets

## 4. Agent Skills Reference
We have imported agent skills in the `.agents/skills/` directory:
- [flutter-add-integration-test](file:///.agents/skills/flutter-add-integration-test/SKILL.md)
- [flutter-add-widget-preview](file:///.agents/skills/flutter-add-widget-preview/SKILL.md)
- [flutter-add-widget-test](file:///.agents/skills/flutter-add-widget-test/SKILL.md)
- [flutter-apply-architecture-best-practices](file:///.agents/skills/flutter-apply-architecture-best-practices/SKILL.md)
- [flutter-build-responsive-layout](file:///.agents/skills/flutter-build-responsive-layout/SKILL.md)
- [flutter-fix-layout-issues](file:///.agents/skills/flutter-fix-layout-issues/SKILL.md)
- [flutter-implement-json-serialization](file:///.agents/skills/flutter-implement-json-serialization/SKILL.md)
- [flutter-setup-declarative-routing](file:///.agents/skills/flutter-setup-declarative-routing/SKILL.md)
- [flutter-setup-localization](file:///.agents/skills/flutter-setup-localization/SKILL.md)
- [flutter-use-http-package](file:///.agents/skills/flutter-use-http-package/SKILL.md)

Refer to these skills in `.agents/skills/` when executing tasks to ensure compliance with Flutter best practices.

## 5. Agent Workflow Rules
- **No Unconfirmed Commits/Pushes**: Do not execute `git commit` or `git push` commands, or make changes directly to remote repository branches, without explicit user confirmation and approval.

