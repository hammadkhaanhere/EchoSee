# EchoSee

See the sound around you — a Flutter app that provides real-time speech-to-text subtitling with an accessible, visually clean interface.

## Setup Steps

1. Ensure Flutter SDK `^3.38.9` is installed.
2. Clone the repository and navigate to the project root.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` to launch on a connected device or emulator.

## Dependencies

| Package              | Purpose                           |
|----------------------|-----------------------------------|
| `flutter`            | SDK                               |
| `cupertino_icons`    | iOS-style icons                   |
| `shared_preferences` | Persistent user preference storage |

## Features

### Font Size Selector
- Three options: Small (0.85×), Medium (1.0×), Large (1.15×).
- Animated preview container visually resizes the sample text on selection.
- Button highlights the active choice with teal.

### Light / Dark Mode Toggle
- Animated switch with smooth color transition.
- Toggle icon changes between `dark_mode` and `light_mode`.
- Entire app theme transitions via Flutter's built-in `themeMode` animation.

### Subtitle Customization
- **Color Picker**: 6 swatch palette with a checkmark on the selected color. Each swatch uses `AnimatedContainer` for a micro-interaction border highlight.
- **Position Selector**: Top / Center / Bottom options with animated button states.
- Drag & drop visual cue (handle bar) for future implementation.

### Animations
| Animation                  | Type                         | Location                        |
|----------------------------|------------------------------|---------------------------------|
| Font size preview          | `AnimatedDefaultTextStyle`   | Font Size Selector              |
| Theme switch               | `AnimatedContainer` + toggle | Theme Toggle                    |
| Subtitle color selection   | `AnimatedContainer`          | Subtitle Customizer             |
| Transcript slide-in        | `SlideTransition` + `Offset` | Transcript Tile                 |
| Transcript detail open     | `ScaleTransition` + `easeOutBack` | Transcript Tile tap        |
| Search bar expand          | `AnimatedContainer`          | Transcript Screen (premium)     |
| Export success checkmark   | `TweenAnimationBuilder` + `elasticOut` | Export action          |
| Splash → Home transition   | `FadeTransition`             | Splash Screen                   |


## Architecture

```
lib/
├── constants/       app_colors.dart (theme data, enums)
├── models/          transcript.dart (data model)
├── state/           app_state.dart (ChangeNotifier + persistence)
├── reusables/       shared UI components (bottom nav, selectors, tiles)
├── screens/         splash_screen, home_screen, transcript_screen
└── main.dart        entry point, MaterialApp with theme switching
```

