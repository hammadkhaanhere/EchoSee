# EchoSee

See the sound around you — a Flutter app that provides real-time speech-to-text subtitling with an accessible, visually clean interface.

## Screens

### Splash Screen
- Deep Navy Blue background with the EchoSee logo (eye + soundwave combination) centered in a circular container.
- Auto-navigates to the Home Screen after 3 seconds.

### Home Screen
- **Top Bar**: Green "Live" status dot (left), Settings cog and Font Size "A" icons (right).
- **Subtitle Area**: Scrollable list of card-style dialogue bubbles in `[Speaker]: [text]` format.
- **Microphone Button**: Prominent teal circular button at the bottom for toggling speech-to-text.
- **Bottom Navigation Bar** with four tabs:
  - **Log** — Access saved conversation transcripts and history logs.
  - **Listen** — Primary real-time speech-to-text interface (default tab).
  - **Vision** — Visual accessibility and computer vision-based assistance tools.
  - **Me** — Personal profile, account settings, and user preferences.

## Color System (`app_colors.dart`)
| Color          | Hex       | Usage                        |
|----------------|-----------|------------------------------|
| Navy Blue      | `#0D1B2A` | App background               |
| Teal           | `#00897B` | Microphone button, nav accent|
| Green          | `#4CAF50` | "Live" status dot            |
| Card Background| `#F5F5F5` | Dialogue bubbles             |
| Speaker Label  | `#1565C0` | Speaker name label           |

## Orientation
Locked to **Portrait** mode on both Android and iOS.

## Getting Started

```bash
flutter pub get
flutter run
```
