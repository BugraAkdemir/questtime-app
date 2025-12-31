# QuestTime

QuestTime - Gamified study timer application with XP and quest system.

## Features

- 🎯 **Quest System**: Create custom study quests with different subjects, difficulties, and durations
- ⏱️ **Circular Timer**: Beautiful animated circular timer for focused study sessions
- 📊 **Progress Tracking**: Track your XP, level, and study statistics
- 🏆 **Gamification**: Earn XP and coins by completing quests
- 🎨 **Modern UI**: Clean, premium design with Material Icons
- 🌍 **Localization**: Support for English and Turkish
- 📱 **Responsive**: Works on both phones and tablets

## Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Android Studio / Xcode (for mobile development)
- Dart SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/questtime.git
cd questtime
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Building

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS (requires Mac)
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                  # Data models
├── providers/               # State management
├── screens/                 # UI screens
├── services/                # Business logic services
├── theme/                   # App theme configuration
├── utils/                   # Utilities and helpers
└── widgets/                 # Reusable widgets
```

## Technologies Used

- **Flutter**: Cross-platform framework
- **Provider**: State management
- **SharedPreferences**: Local storage
- **Material Design 3**: UI components

## License

This project is private and proprietary.

## Author

Bugra Akdemir
