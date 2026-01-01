# Firebase Setup Instructions

QuestTime application uses Firebase Authentication and Cloud Firestore. Follow the steps below to run the application:

## 1. Create a Project in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click the "Add project" button
3. Enter the project name (e.g., "questtime")
4. Optionally enable Google Analytics
5. Click the "Create project" button

## 2. Add Android Application

1. Open your project in Firebase Console
2. Select "Project settings" from the left menu
3. Click the Android icon in the "Your apps" section
4. Enter Android package name: `com.akdbt.guesttime`
5. Enter App nickname (optional): "QuestTime Android"
6. Click the "Register app" button
7. Download the `google-services.json` file
8. Copy the downloaded `google-services.json` file to the `android/app/` folder

## 3. Add iOS Application (Optional)

1. Open your project in Firebase Console
2. Select "Project settings" from the left menu
3. Click the iOS icon in the "Your apps" section
4. Enter iOS bundle ID: `com.example.studyQuest` (or check from Xcode)
5. Enter App nickname (optional): "QuestTime iOS"
6. Click the "Register app" button
7. Download the `GoogleService-Info.plist` file
8. Add the downloaded `GoogleService-Info.plist` file to the `ios/Runner/` folder in Xcode

## 4. Enable Authentication

1. Select "Authentication" from the left menu in Firebase Console
2. Click the "Get started" button
3. Go to the "Sign-in method" tab
4. Enable "Email/Password" option
5. Click the "Enable" button
6. Click the "Save" button

## 5. Enable Cloud Firestore

1. Select "Firestore Database" from the left menu in Firebase Console
2. Click the "Create database" button
3. Select "Start in test mode" option (for development)
4. Select Cloud Firestore location (e.g., `europe-west1`)
5. Click the "Enable" button

## 6. Firestore Security Rules (Test Mode)

In test mode, Firestore starts with these rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 1, 1);
    }
  }
}
```

**IMPORTANT:** Update security rules for production (with leaderboard support):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User Progress - users can read/write their own data, and read all for leaderboard
    match /userProgress/{userId} {
      // Users can read and write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // All authenticated users can read for leaderboard
      allow read: if request.auth != null;
    }
    match /quests/{userId}/userQuests/{questId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /dailyQuests/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Note for Leaderboard:** The `userProgress` collection allows all authenticated users to read data (for leaderboard functionality). Users can only write their own data.

**Firestore Index Required:**
- Go to Firestore Database > Indexes
- Click on "Single field" tab (NOT composite!)
- Click "Add a single-field index"
- Collection: `userProgress`
- Field: `totalXP`
- Order: `Descending`
- Click "Create"

**Important:** Use **Single field index**, not composite index. If you see "this index is not necessary" warning, you're trying to create a composite index when you only need a single field index.

## 7. Running the Application

1. Run `flutter pub get` command (already done)
2. Make sure the `google-services.json` file is in the `android/app/` folder
3. Run the application: `flutter run`

## Notes

- The `google-services.json` file for Android **must** be in the `android/app/` folder
- The `GoogleService-Info.plist` file for iOS must be added to the `ios/Runner/` folder in Xcode
- **Important**: `google-services.json` contains sensitive information and should NOT be tracked in Git (already added to `.gitignore`)
- On first run, Firebase connection will be established and users will be able to register and login
- User data (XP, quests, daily quests) will be stored in Firebase
- Login is optional - the app works with local storage if not logged in
- Leaderboard feature requires authentication

## Troubleshooting

- **"Default FirebaseApp is not initialized"** error: Make sure the `google-services.json` file is in the correct location
- **"MissingPluginException"** error: Run `flutter clean` and `flutter pub get` commands
- **Authentication error**: Make sure Email/Password authentication is enabled in Firebase Console
- **Leaderboard shows empty**: Make sure Firestore index is created and security rules are updated (see [FIRESTORE_RULES.md](FIRESTORE_RULES.md))
- **"No matching client found for package name"** error: Ensure the package name in `google-services.json` matches `com.akdbt.guesttime`
