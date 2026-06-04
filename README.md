# EchoSee

See the sound around you — a Flutter app that provides real-time speech-to-text subtitling with an accessible, visually clean interface.

## Setup Steps

1. Ensure Flutter SDK `^3.10.8` is installed.
2. Clone the repository and navigate to the project root.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` to launch on a connected device or emulator.

## Dependencies

| Package              | Purpose                           |
|----------------------|-----------------------------------|
| `flutter`            | SDK                               |
| `cupertino_icons`    | iOS-style icons                   |
| `shared_preferences` | Persistent user & auth storage    |

## Auth Flow

```
Splash (3s) → Sign In ─→ Sign Up ─→ Home
                  ↑                    │
                  └──── Sign Out ──────┘
```

- Users are stored in SharedPreferences as a JSON list.
- Current session is persisted across restarts.
- Sign Out returns to the Sign In screen.

## Screens

### Splash Screen
- Deep Navy Blue background with logo centered.
- Static display — no entrance animations.
- Auto-routes to Sign In (or Home if already logged in).

### Sign In Screen
- Logo + email/password fields with show/hide password toggle.
- Fade-in entrance animation.
- Button: loading spinner → success checkmark → navigate to Home.
- Error shake animation + inline error messages on wrong credentials.
- Keyboard-aware layout via `SingleChildScrollView`.

### Sign Up Screen
- Logo + full name, email, and password fields.
- Fields slide up with staggered delays (100/200/300ms).
- Inline validation errors per field.
- Button: loading → success → auto-navigate to Home.
- "Already have an account?" link with fade transition back to Sign In.

### Home Screen
- **Top Bar**: Green "Live" dot + Settings cog (theme, subtitles) + Font Size "A" icon.
- **Subtitle Area**: Scrollable dialogue bubbles in `[Speaker]: [text]` format with live font size scaling.
- **Microphone Button**: Teal circular button — saves a transcript entry.
- **Bottom Navigation Bar** with 4 tabs:
  - **Log** — Transcript screen (free: last 5 / premium: unlimited + search + export PDF).
  - **Listen** — Real-time speech-to-text interface (default).
  - **Vision** — Placeholder for vision-based tools.
  - **Me** — Profile screen with save, subscription card, sign out.

### Profile Screen
- Avatar circle + editable Full Name, Email fields.
- Preferred Language dropdown (English / Urdu).
- Save button with snackbar confirmation.
- Subscription status badge and tappable upgrade card.
- Sign Out button with full route clearance.

### Subscription Screen
- Premium features list: multi-language translation, full history, speaker identification, advanced customization.
- Subscribe / Cancel toggle button with gradient hero icon.
- "Cancel anytime" footer.

### Transcript Screen
- **Free**: Last 5 conversations, auto-delete oldest, slide-in + scale-up animations.
- **Premium**: Unlimited storage, search by speaker/keyword with expand animation, PDF export with elastic success checkmark.

## Features

### Font Size Selector
- Small (0.85×), Medium (1.0×), Large (1.15×).
- `AnimatedDefaultTextStyle` preview updates in real time.
- Selected option highlighted with teal.

### Light / Dark Mode Toggle
- Animated switch with custom toggle thumb icon.
- Default follows system preference.
- Whole-screen fade transition via `AnimatedSwitcher`.

### Subtitle Customization
- 6-color palette with `AnimatedContainer` border highlight + checkmark.
- Position selector: Top / Center / Bottom.
- Drag handle visual for future drag & drop.

## Animations

| Animation                        | Type                              | Location                            |
|----------------------------------|-----------------------------------|-------------------------------------|
| Sign In fade-in                  | `FadeTransition`                  | Sign In Screen                      |
| Sign Up staggered slide-up       | `SlideTransition` (delayed)       | Auth Text Fields                    |
| Button loading spinner           | `CircularProgressIndicator`       | Auth Button                         |
| Button success checkmark         | `Icon` + state swap               | Auth Button                         |
| Error shake                      | `TweenSequence` + `Transform`     | Auth Button                         |
| Font size preview                | `AnimatedDefaultTextStyle`        | Font Size Selector                  |
| Theme switch (whole screen)      | `AnimatedSwitcher` + fade         | MaterialApp home                    |
| Theme toggle knob                | `AnimatedContainer` + `Align`     | Theme Toggle                        |
| Subtitle color picker            | `AnimatedContainer`               | Subtitle Customizer                 |
| Text field slide-up              | `SlideTransition`                 | Auth Text Fields                    |
| Transcript slide-in              | `SlideTransition` + `Offset`      | Transcript Tile                     |
| Transcript detail open           | `ScaleTransition` + `easeOutBack` | Transcript Tile tap                 |
| Search bar expand                | `AnimatedContainer`               | Transcript Screen (premium)         |
| Export success checkmark         | `TweenAnimationBuilder` + elastic | Export action                       |
| Splash → next screen             | `FadeTransition`                  | Route transitions                   |

## Color System (`constants/app_colors.dart`)

| Token              | Light Hex   | Dark Hex    |
|--------------------|-------------|-------------|
| Background         | `#0D1B2A`   | `#0F0F23`   |
| Teal (accent)      | `#00897B`   | `#00897B`   |
| Green (Live dot)   | `#4CAF50`   | `#4CAF50`   |
| Card / Surface     | `#F5F5F5`   | `#1A1A2E`   |
| Subtitle bg        | `#FFFFFF`   | `#16213E`   |
| Speaker label      | `#1565C0`   | `#1565C0`   |

## Architecture

```
lib/
├── constants/       app_colors.dart (theme data, color tokens, enums)
├── models/          transcript.dart (data model with JSON serialization)
├── state/           app_state.dart (ChangeNotifier: theme, auth, fonts,
│                    subtitles, transcripts, preferences, persistence)
├── reusables/
│   ├── app_bottom_nav.dart
│   ├── auth_button.dart         (shake, loading, success states)
│   ├── auth_text_field.dart     (slide-up, inline error, password toggle)
│   ├── font_size_selector.dart
│   ├── theme_toggle.dart
│   ├── subtitle_customizer.dart
│   └── transcript_tile.dart     (slide-in, scale-up on tap)
├── screens/
│   ├── splash_screen.dart
│   ├── sign_in_screen.dart
│   ├── sign_up_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── subscription_screen.dart
│   └── transcript_screen.dart
└── main.dart         entry point, MaterialApp with AnimatedSwitcher theme
```

## Orientation

Locked to **Portrait** on Android (manifest) and iOS (Info.plist).
