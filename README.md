# Tetris

A classic Tetris game built with Flutter, playable on Android, iOS, web, macOS, Windows, and Linux from a single codebase.

Programmed by Tinson.

## Features

- Classic gameplay with all 7 tetromino shapes, each with 4 rotation states
- Next-piece preview panel
- Score counter with progressively increasing fall speed as the score rises
- Pause / resume and restart controls
- Game-over detection
- Sound effects on piece lock and line clear (via `flutter_beep`)
- On-screen touch controls for move left/right, soft drop, and rotate, with press-and-hold auto-repeat for movement
- Game state (board, current/next piece, score, etc.) is automatically saved when the app is backgrounded and restored on next launch

## Tech Stack

- [Flutter](https://flutter.dev) / Dart
- Rendering via `CustomPainter` (no external game engine)
- Key packages: `path_provider` (save/load game state), `flutter_beep` (sound effects), `flutter_launcher_icons`, `cupertino_icons`

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (see `pubspec.yaml` for the required Dart SDK version)
- A configured target platform (Android/iOS toolchain, or a desktop/browser for Flutter desktop/web)

### Run

```bash
flutter pub get
flutter run
```

Use `flutter devices` to see available targets, or pass `-d chrome`, `-d macos`, etc. to target a specific platform.

## Project Structure

```
lib/
├── main.dart           # App entry point, UI layout, and on-screen controls
├── game_area.dart       # Core game logic: board state, collision, scoring, save/load, rendering
├── combinations.dart    # Tetromino shape definitions and rotation
├── game_colors.dart     # Color theme
└── repeat_button.dart   # Icon button that auto-repeats while pressed and held
```

## Controls

All controls are on-screen buttons: move left, move right, soft drop (hold to repeat), and rotate. Pause/resume, restart, and an About dialog are also available from the on-screen icon buttons.
