# QuestTime ⏱️

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10.4+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10.4+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

**A gamified study timer application that makes learning fun and productive**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Project Structure](#-project-structure) • [Contributing](#-contributing)

</div>

---

## 📖 About

QuestTime is a modern, gamified study timer application designed to help students and learners stay focused and motivated. Transform your study sessions into engaging quests, earn XP, level up, compete on the leaderboard, and track your progress with beautiful statistics.

### Key Highlights

- 🎮 **Gamification**: Turn studying into a game with XP, levels, and achievements
- ⏱️ **Focus Timer**: Beautiful circular timer with smooth animations
- 🏆 **Leaderboard**: Compete with other users globally based on XP
- ⏲️ **Stopwatch Mode**: Study without time limits, earn rewards based on actual time
- 📊 **Progress Tracking**: Comprehensive statistics and progress visualization
- 🎯 **Custom Quests**: Create personalized study quests with custom subjects
- 🔐 **Cloud Sync**: Firebase integration for data synchronization across devices
- 🌍 **Multilingual**: Full support for English and Turkish
- 🎨 **Modern UI**: Clean, premium design following Material Design 3 principles
- 📱 **Responsive**: Optimized for both phones and tablets

---

## ✨ Features

### Core Features

#### 🎯 Quest System
- Create custom study quests with different subjects (Mathematics, Science, History, Language, etc.)
- Support for custom subject names
- Multiple difficulty levels (Easy, Medium, Hard)
- Flexible duration options (15, 30, 45, 60 minutes) or custom duration
- **Stopwatch Mode**: Study without fixed duration, earn rewards based on actual time
- Real-time XP and coin display during stopwatch sessions
- XP calculation based on subject, difficulty, and duration

#### ⏱️ Circular Timer
- Beautiful animated circular progress indicator
- Smooth, non-jumping animations (100ms update frequency)
- Real-time progress tracking
- Pause/Resume functionality
- Visual feedback with Material Icons
- Stopwatch mode support with elapsed time tracking

#### 🏆 Leaderboard System
- **Global Ranking**: Compete with users worldwide based on total XP
- **Top 3 Podium**: Special display for top 3 users with medals (Gold, Silver, Bronze)
- **Your Rank**: See your current position in the leaderboard
- **Real-time Updates**: Pull-to-refresh to see latest rankings
- **User Profiles**: View other users' names, usernames, levels, and XP
- **Authentication Required**: Login to participate in leaderboard

#### 📊 Progress Tracking
- **XP System**: Earn experience points by completing quests
- **Leveling**: Automatic level calculation based on total XP
- **Statistics Dashboard**:
  - Total study time
  - Completed quests count
  - Average session duration
  - Total XP earned
  - Current level
  - Coins earned

#### 🔐 Authentication & Cloud Sync
- **Firebase Authentication**: Email/password login and signup
- **Cloud Firestore**: Automatic data synchronization across devices
- **Profile Management**: View and edit your name and username
- **Optional Login**: Use the app without an account (with local storage)
- **Data Safety**: Warning banner when not logged in
- **Data Persistence**: Local data cleared on logout, restored on login

#### 🏆 Gamification
- **XP Rewards**: Earn XP based on quest parameters
- **Coins System**: Collect coins from completed quests
- **Level Progression**: Level up as you gain more XP
- **Achievement Tracking**: Track your study milestones
- **Competitive Element**: Leaderboard rankings

#### 🎨 User Interface
- **Modern Design**: Clean, premium aesthetic with vibrant colors
- **Material Icons**: Consistent iconography throughout
- **Dark/Light Theme**: Automatic theme switching based on system settings
- **Enhanced Gradients**: Multi-color gradients for XP and achievements
- **Premium Effects**: Soft glows, enhanced shadows, and smooth animations
- **Responsive Layout**: Adapts beautifully to different screen sizes
- **Consolidated Menu**: All actions in a single, organized menu

#### 🌍 Localization
- **English**: Full English language support
- **Turkish**: Complete Turkish translation
- **Easy Toggle**: Switch languages from the stats screen

#### 📱 Platform Support
- **Android**: Full support with native Android features
- **iOS**: Complete iOS implementation (requires Mac for building)

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.10.4 or higher)
  ```bash
  flutter --version
  ```
- **Dart SDK** (included with Flutter)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **Git** (for cloning the repository)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/BugraAkdemir/questtime-app.git
   cd questtime-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup** (Required for authentication and leaderboard)
   - Follow the instructions in [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
   - Download `google-services.json` and place it in `android/app/`
   - Configure Firestore security rules (see [FIRESTORE_RULES.md](FIRESTORE_RULES.md))
   - Create Firestore index for leaderboard (see [FIRESTORE_RULES.md](FIRESTORE_RULES.md))

4. **Run the app**
   ```bash
   flutter run
   ```

   Or run on a specific device:
   ```bash
   flutter run -d <device-id>
   ```

### Verify Installation

After running `flutter pub get`, you should see:
```
Running "flutter pub get" in questtime-app...
Got dependencies!
```

---

## 📱 Building

### Android

#### Debug APK
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

#### Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS Required)

```bash
flutter build ios --release
```

**Note**: iOS builds require:
- macOS operating system
- Xcode installed
- Valid Apple Developer account (for device testing)
- CocoaPods installed (`sudo gem install cocoapods`)

---

## 💻 Usage

### Creating a Quest

1. Tap the **"Start New Quest"** button on the home screen
2. Select a **Subject** (or choose "Custom Subject" to enter your own)
3. Choose a **Difficulty** level (Easy, Medium, Hard)
4. Select a **Duration** (15, 30, 45, 60 minutes, custom, or **Stopwatch**)
5. Tap **"Start Quest"** to begin your study session

### Using the Timer

- **Start**: The timer begins automatically when you start a quest
- **Pause**: Tap the pause button to pause the timer
- **Resume**: Tap the play button to continue
- **Complete**: When the timer reaches zero (or you stop a stopwatch), you'll earn XP and coins
- **Stopwatch Mode**: Study without time limits, see real-time XP and coins as you study

### Viewing Statistics

1. Navigate to the **Stats** screen from the menu
2. View your:
   - Current level and XP progress
   - Total study time
   - Completed quests
   - Average session duration
   - Total coins earned
3. Toggle language (English/Turkish) using the language button

### Leaderboard

1. Navigate to the **Leaderboard** from the menu
2. View:
   - Top 3 users with special podium display (Gold, Silver, Bronze)
   - Your current rank and position
   - Complete leaderboard list
3. Pull down to refresh and see latest rankings

**Note**: You must be logged in to view and participate in the leaderboard.

### Profile Management

1. Navigate to **Profile** from the menu
2. View and edit your:
   - Name
   - Username
   - Email
3. Changes are automatically synced to Firebase

### Authentication

- **Login**: Optional - you can use the app without logging in
- **Sign Up**: Create an account with email, password, name, and username
- **Data Sync**: Logged-in users' data is synced across devices via Firebase
- **Warning**: A banner appears when not logged in, warning about potential data loss

### Market (Coming Soon)

The market feature is currently under development. A "Coming Soon" message will be displayed when accessed.

---

## 🏗️ Project Structure

```
questtime-app/
├── android/                 # Android platform-specific code
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml
│   │           └── kotlin/
│   │               └── com/akdbt/guesttime/
│   │                   └── MainActivity.kt
│   └── build.gradle.kts
│
├── ios/                     # iOS platform-specific code
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   └── Assets.xcassets/
│   └── Runner.xcodeproj/
│
├── lib/                     # Main application code
│   ├── main.dart           # App entry point
│   │
│   ├── models/             # Data models
│   │   ├── quest.dart      # Quest model
│   │   ├── user_progress.dart
│   │   ├── daily_quest.dart
│   │   └── shop_item.dart
│   │
│   ├── providers/          # State management (Provider pattern)
│   │   ├── app_state_provider.dart
│   │   ├── settings_provider.dart
│   │   ├── shop_provider.dart
│   │   └── auth_provider.dart
│   │
│   ├── screens/            # UI screens
│   │   ├── home_screen.dart      # Main screen with timer
│   │   ├── stats_screen.dart     # Statistics dashboard
│   │   ├── market_screen.dart    # Market/shop (coming soon)
│   │   ├── leaderboard_screen.dart # Global leaderboard
│   │   ├── profile_screen.dart   # User profile management
│   │   └── auth_screen.dart      # Login/signup screen
│   │
│   ├── services/          # Business logic services
│   │   ├── storage_service.dart  # Local data persistence
│   │   ├── firestore_service.dart     # Cloud Firestore operations
│   │   ├── auth_service.dart  # Firebase Authentication
│   │   └── xp_service.dart     # XP and level calculations
│   │
│   ├── theme/             # Theme configuration
│   │   └── app_theme.dart # Light/dark themes
│   │
│   ├── utils/             # Utilities and helpers
│   │   ├── constants.dart
│   │   ├── enums.dart     # Subject, Difficulty enums
│   │   ├── localizations.dart # i18n strings
│   │   └── subject_icons.dart # Icon mappings
│   │
│   └── widgets/          # Reusable widgets
│       ├── circular_timer.dart      # Animated timer widget
│       ├── quest_card.dart          # Quest display card
│       └── quest_selection_dialog.dart # Quest creation dialog
│
├── build/                 # Build outputs (gitignored)
├── pubspec.yaml          # Dependencies and metadata
├── README.md             # This file
├── FIREBASE_SETUP.md     # Firebase setup instructions
├── FIRESTORE_RULES.md    # Firestore security rules
└── DESIGN_SYSTEM.md      # Design system documentation
```

### Key Files

- **`lib/main.dart`**: Application entry point, provider setup, routing
- **`lib/providers/app_state_provider.dart`**: Main state management for quests and progress
- **`lib/services/firestore_service.dart`**: Cloud Firestore operations and leaderboard queries
- **`lib/screens/leaderboard_screen.dart`**: Global leaderboard implementation
- **`lib/widgets/circular_timer.dart`**: Animated circular timer implementation
- **`lib/theme/app_theme.dart`**: Theme definitions (colors, typography, etc.)

---

## 🛠️ Technologies Used

### Core Framework
- **[Flutter](https://flutter.dev/)** (3.10.4+) - Cross-platform UI framework
- **[Dart](https://dart.dev/)** (3.10.4+) - Programming language

### State Management
- **[Provider](https://pub.dev/packages/provider)** (^6.1.1) - State management solution

### Backend & Storage
- **[Firebase Core](https://pub.dev/packages/firebase_core)** (^2.24.2) - Firebase initialization
- **[Firebase Auth](https://pub.dev/packages/firebase_auth)** (^4.16.0) - User authentication
- **[Cloud Firestore](https://pub.dev/packages/cloud_firestore)** (^4.14.0) - Cloud database
- **[SharedPreferences](https://pub.dev/packages/shared_preferences)** (^2.2.2) - Local data persistence

### UI & Animations
- **Material Design 3** - Design system
- **[Lottie](https://pub.dev/packages/lottie)** (^3.1.2) - Animation support
- **[Confetti](https://pub.dev/packages/confetti)** (^0.7.0) - Celebration animations

### Utilities
- **[UUID](https://pub.dev/packages/uuid)** (^4.3.3) - Unique ID generation
- **[Intl](https://pub.dev/packages/intl)** (^0.19.0) - Internationalization
- **[URL Launcher](https://pub.dev/packages/url_launcher)** (^6.2.5) - External link handling

---

## 🎨 Design System

QuestTime follows a carefully crafted design system with:

- **Color Palette**: Vibrant purple (#7C3AED) and Cyan (#06B6D4) as primary colors
- **Typography**: Clean sans-serif fonts with clear hierarchy
- **Spacing**: Consistent 8/12/16/24 spacing system
- **Components**: Rounded cards (12-20px radius), soft shadows, premium feel
- **Gradients**: Multi-color gradients for XP, achievements, and premium elements
- **Effects**: Enhanced glows, shadows, and smooth animations

For detailed design specifications, see [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).

---

## 🔧 Configuration

### Android

- **Package Name**: `com.akdbt.guesttime`
- **Namespace**: `com.akdbt.guesttime`
- **Min SDK**: 21
- **Target SDK**: Latest

### iOS

- **Bundle Identifier**: `com.example.studyQuest`
- **Minimum iOS Version**: 13.0

### Firebase

- See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for complete setup instructions
- See [FIRESTORE_RULES.md](FIRESTORE_RULES.md) for security rules and index configuration

---

## 📝 Development

### Running in Debug Mode

```bash
flutter run --debug
```

### Running in Release Mode

```bash
flutter run --release
```

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Cleaning Build Files

```bash
flutter clean
```

---

## 🤝 Contributing

Contributions are welcome! However, please note that this is currently a private project. If you'd like to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep widgets small and focused
- Follow the existing project structure

---

## 🐛 Known Issues

- Market feature is under development (shows "Coming Soon")
- iOS build requires macOS and Xcode

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

```
Copyright 2025 Bugra Akdemir

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

## 👤 Author

**Bugra Akdemir**

- GitHub: [@BugraAkdemir](https://github.com/BugraAkdemir)
- Repository: [questtime-app](https://github.com/BugraAkdemir/questtime-app)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design system
- Firebase team for backend services
- All open-source contributors whose packages made this project possible

---

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/BugraAkdemir/questtime-app/issues) page
2. Create a new issue with detailed information
3. Include device information, Flutter version, and error logs

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ Star this repo if you find it helpful!

</div>
