# Firebase Setup Instructions

QuestTime uygulaması Firebase Authentication ve Cloud Firestore kullanmaktadır. Uygulamayı çalıştırmak için aşağıdaki adımları takip edin:

## 1. Firebase Console'da Proje Oluşturma

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. "Add project" (Proje Ekle) butonuna tıklayın
3. Proje adını girin (örn: "questtime")
4. Google Analytics'i isteğe bağlı olarak etkinleştirin
5. "Create project" (Proje Oluştur) butonuna tıklayın

## 2. Android Uygulaması Ekleme

1. Firebase Console'da projenizi açın
2. Sol menüden "Project settings" (Proje ayarları) seçin
3. "Your apps" (Uygulamalarınız) bölümünde Android ikonuna tıklayın
4. Android package name: `com.akdbt.guesttime` girin
5. App nickname (isteğe bağlı): "QuestTime Android" girin
6. "Register app" (Uygulamayı kaydet) butonuna tıklayın
7. `google-services.json` dosyasını indirin
8. İndirilen `google-services.json` dosyasını `android/app/` klasörüne kopyalayın

## 3. iOS Uygulaması Ekleme (Opsiyonel)

1. Firebase Console'da projenizi açın
2. Sol menüden "Project settings" (Proje ayarları) seçin
3. "Your apps" (Uygulamalarınız) bölümünde iOS ikonuna tıklayın
4. iOS bundle ID: `com.example.studyQuest` girin (veya Xcode'dan kontrol edin)
5. App nickname (isteğe bağlı): "QuestTime iOS" girin
6. "Register app" (Uygulamayı kaydet) butonuna tıklayın
7. `GoogleService-Info.plist` dosyasını indirin
8. İndirilen `GoogleService-Info.plist` dosyasını Xcode'da `ios/Runner/` klasörüne ekleyin

## 4. Authentication'ı Etkinleştirme

1. Firebase Console'da sol menüden "Authentication" seçin
2. "Get started" (Başlayın) butonuna tıklayın
3. "Sign-in method" (Giriş yöntemi) sekmesine gidin
4. "Email/Password" seçeneğini etkinleştirin
5. "Enable" (Etkinleştir) butonuna tıklayın
6. "Save" (Kaydet) butonuna tıklayın

## 5. Cloud Firestore'u Etkinleştirme

1. Firebase Console'da sol menüden "Firestore Database" seçin
2. "Create database" (Veritabanı oluştur) butonuna tıklayın
3. "Start in test mode" (Test modunda başlat) seçeneğini seçin (geliştirme için)
4. Cloud Firestore location (konum) seçin (örn: `europe-west1`)
5. "Enable" (Etkinleştir) butonuna tıklayın

## 6. Firestore Güvenlik Kuralları (Test Modu)

Test modunda Firestore şu kurallarla başlar:

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

**ÖNEMLİ:** Production için güvenlik kurallarını güncelleyin:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /userProgress/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
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

## 7. Uygulamayı Çalıştırma

1. `flutter pub get` komutunu çalıştırın (zaten yapıldı)
2. `google-services.json` dosyasının `android/app/` klasöründe olduğundan emin olun
3. Uygulamayı çalıştırın: `flutter run`

## Notlar

- Android için `google-services.json` dosyası **mutlaka** `android/app/` klasöründe olmalıdır
- iOS için `GoogleService-Info.plist` dosyası Xcode'da `ios/Runner/` klasörüne eklenmelidir
- İlk çalıştırmada Firebase bağlantısı kurulacak ve kullanıcılar kayıt olup giriş yapabilecektir
- Kullanıcı verileri (XP, quests, daily quests) Firebase'de saklanacaktır

## Sorun Giderme

- **"Default FirebaseApp is not initialized"** hatası: `google-services.json` dosyasının doğru konumda olduğundan emin olun
- **"MissingPluginException"** hatası: `flutter clean` ve `flutter pub get` komutlarını çalıştırın
- **Authentication hatası**: Firebase Console'da Email/Password authentication'ın etkin olduğundan emin olun

