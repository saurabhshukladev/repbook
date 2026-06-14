# RepBook

RepBook is a modern, high-contrast, offline-first Flutter application designed for managing and displaying configurable exercise routines. It features a premium monochromatic dark theme (black, white, and grey) and dynamic swipe-based technique navigation.

---

## 1. Architecture & Design

The application follows a clean, decoupled, layered architecture to maintain strict Separation of Concerns (SoC).

```text
lib/
├── models/
│   └── exercise.dart           # Domain Model representing a single exercise (with JSON mappings)
├── services/
│   ├── github_service.dart     # Service encapsulating authenticated GitHub API requests
│   ├── cache_service.dart      # Local file manager for routine JSON and downloaded GIFs
│   └── workout_service.dart    # Abstract service bridging ViewModel and Cache/API sources
├── providers/
│   ├── settings_provider.dart  # State provider managing SharedPreferences PAT configurations
│   └── workout_provider.dart   # State provider managing sync progress, tabs, and routines
├── theme/
│   └── app_theme.dart          # Monochromatic Material 3 design system tokens
├── widgets/
│   ├── exercise_card.dart      # Routine list card displaying large exercise GIF banners
│   └── exercise_detail.dart    # Stateful full-screen detail viewer with swipe page transitions
└── screens/
    ├── home_screen.dart        # Dashboard screen containing weekday tabs and sync workflows
    └── settings_screen.dart    # Form screen for credentials input and local cache clearing
```

### Key Components

* **Monochromatic Dark UI (`AppTheme`)**: Uses deep pitch black (`#000000`) backgrounds, slate dark grey surfaces (`#121212`), white accents, and clean border styles.
* **Offline-First Data Storage (`CacheService`)**: Routine schedules and GIF binaries are persisted directly in the device's local application documents directory, allowing 100% offline usage in gyms with poor network connections.
* **Dynamic Technique Navigation (`ExerciseDetailDialog`)**: Renders details inside a stateful `PageView.builder` so users can swipe left or right to seamlessly browse the previous or next exercises in the day's routine.
* **Pluggable Architecture**: Swapping mock services with production APIs is as simple as registering a new class conforming to `WorkoutService` in `lib/main.dart`.

---

## 2. Setup & How to Use

RepBook fetches exercise schedules from a private or public GitHub repository.

### Step 1: Create Your Schedule JSON
In a GitHub repository (e.g. `workout-schedule`), create a JSON file (e.g. `schedule.json`) matching the following schema. Make sure to reference valid image or GIF URLs:

```json
{
  "RepBook": {
    "Monday": [
      {"name": "Barbell Bench Press", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"},
      {"name": "Lat Pulldown", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"}
    ],
    "Tuesday": [
      {"name": "Barbell Squat", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"}
    ],
    "Wednesday": [],
    "Thursday": [
      {"name": "Incline Dumbbell Press", "gif-url": "https://i.pinimg.com/originals/f3/c6/c6/f3c6c61555639c1bb1a4b2c9c2c799c8.gif"}
    ],
    "Friday": [],
    "Saturday": [],
    "Sunday": []
  }
}
```

### Step 2: Generate a GitHub PAT Token
1. Go to **Settings > Developer Settings > Personal Access Tokens (Fine-grained)**.
2. Generate a token scoped only to the repository containing your schedule JSON.
3. Grant **Read-only** permissions to **Contents**.

### Step 3: Configure settings in RepBook
1. Launch the RepBook app.
2. On first run, it will detect that it is not yet configured. Tap **Go to Settings** (or tap the **Gear/Settings** icon in the top-left corner).
3. Input your credentials:
   * **GitHub PAT Token**: Your generated token (`ghp_...`)
   * **Repository Owner**: Your GitHub username or organization name
   * **Repository Name**: Your repository name
   * **File Path**: Relative path to the JSON file (e.g., `schedule.json`)
4. Tap **Save Settings**.

### Step 4: Sync Routines
1. Tap the **Sync** (refresh) icon in the top-right corner of the Home Screen.
2. The app will connect to GitHub, download the schedule JSON, save it to disk, and download all referenced GIF files. You can monitor progress on-screen.
3. Once completed, the screen will populate with your daily exercises. 

### Step 5: Routine Navigation
* **Weekday selection**: Tap any tab on the bottom navigation bar (Mon–Sun) to filter. The active tab defaults automatically to today's day of the week.
* **Detail view**: Tap on any exercise card to view the animation full-screen.
* **Swiping**: Swipe left or right on the detail screen to navigate to other exercises for that day without returning to the home dashboard.

---

## 3. Development, Testing, and Building

### Running Widget & Unit Tests
A full test suite is available under `test/workout_widget_test.dart` to verify navigation, empty day states, sync errors, and swiping behavior.

Run the tests:
```bash
flutter test
```

### Running the App
Run in debug mode on a connected device:
```bash
flutter run
```

### Building Release APK
Compile a release build APK:
```bash
flutter build apk --release
```
The compiled APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`
