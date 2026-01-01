# Firebase Cloud Messaging (FCM) Bildirim Gönderme Rehberi

Bu rehber, Firebase Console veya programatik olarak kullanıcılara bildirim gönderme yöntemlerini açıklar.

## Yöntem 1: Firebase Console'dan Manuel Bildirim Gönderme (En Kolay)

### Adımlar:

1. **Firebase Console'a giriş yapın**
   - [Firebase Console](https://console.firebase.google.com/) adresine gidin
   - Projenizi seçin

2. **Cloud Messaging bölümüne gidin**
   - Sol menüden **"Cloud Messaging"** seçeneğine tıklayın
   - **"Send your first message"** veya **"New notification"** butonuna tıklayın

3. **Bildirim içeriğini oluşturun**
   - **Notification title**: Başlık (örn: "Günlük Ders Hatırlatması")
   - **Notification text**: Mesaj metni (örn: "Bugün de çalışmayı unutma! Serini kırma 🔥")
   - **Notification image** (opsiyonel): Görsel ekleyebilirsiniz

4. **Hedef kitleyi seçin**
   - **"Send test message"**: Test için FCM token'ı girebilirsiniz
   - **"Target"**:
     - **"User segment"**: Tüm kullanıcılar veya belirli bir segment
     - **"Topic"**: Belirli bir konuya abone olan kullanıcılar
     - **"Single device"**: Tek bir cihaza göndermek için FCM token

5. **Gönderimi zamanlayın**
   - **"Send now"**: Hemen gönder
   - **"Schedule"**: Belirli bir tarih/saat için zamanla

6. **Gönderin**
   - **"Review"** butonuna tıklayın
   - **"Publish"** ile gönderimi onaylayın

### Örnek Bildirim İçeriği:

```
Başlık: Günlük Ders Hatırlatması
Metin: Bugün de çalışmayı unutma! Serini kırma 🔥
```

## Yöntem 2: Firebase Cloud Functions ile Programatik Gönderme (Önerilen)

Cloud Functions kullanarak otomatik bildirimler gönderebilirsiniz (örn: günlük hatırlatmalar).

### Kurulum:

1. **Firebase CLI'yi yükleyin**
   ```bash
   npm install -g firebase-tools
   ```

2. **Firebase'e giriş yapın**
   ```bash
   firebase login
   ```

3. **Projeyi başlatın**
   ```bash
   firebase init functions
   ```
   - Language: JavaScript veya TypeScript seçin
   - ESLint: Evet
   - Dependencies: Otomatik yükle

4. **functions/index.js dosyasını düzenleyin**

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Günlük hatırlatma bildirimi (her gün saat 09:00'da)
exports.sendDailyReminder = functions.pubsub
  .schedule('0 9 * * *') // Her gün saat 09:00 (Cron format)
  .timeZone('Europe/Istanbul') // Türkiye saati
  .onRun(async (context) => {
    const db = admin.firestore();

    // Tüm kullanıcıları al (veya belirli bir koşula göre filtrele)
    const usersSnapshot = await db.collection('userProgress').get();

    const promises = usersSnapshot.docs.map(async (doc) => {
      const userData = doc.data();
      const userId = doc.id;

      // Kullanıcının FCM token'ını al (eğer saklıyorsanız)
      // Not: FCM token'ları Firestore'da saklamanız gerekir
      const userToken = userData.fcmToken; // veya başka bir collection'dan al

      if (!userToken) return;

      const message = {
        notification: {
          title: 'Günlük Ders Hatırlatması',
          body: `Merhaba! Bugün de çalışmayı unutma. Serini kırma 🔥`,
        },
        data: {
          type: 'daily_reminder',
          screen: '/home',
        },
        token: userToken,
      };

      try {
        await admin.messaging().send(message);
        console.log(`Notification sent to ${userId}`);
      } catch (error) {
        console.error(`Error sending to ${userId}:`, error);
      }
    });

    await Promise.all(promises);
    return null;
  });

// Tek kullanıcıya bildirim gönderme
exports.sendNotificationToUser = functions.https.onCall(async (data, context) => {
  const { userId, title, body } = data;

  // Auth kontrolü
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const db = admin.firestore();
  const userDoc = await db.collection('userProgress').doc(userId).get();

  if (!userDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  const userData = userDoc.data();
  const userToken = userData.fcmToken;

  if (!userToken) {
    throw new functions.https.HttpsError('not-found', 'FCM token not found');
  }

  const message = {
    notification: {
      title: title || 'QuestTime',
      body: body || 'Yeni bildirim',
    },
    data: {
      type: 'custom',
    },
    token: userToken,
  };

  try {
    const response = await admin.messaging().send(message);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending notification:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send notification');
  }
});

// Başarım açıldığında bildirim gönderme (örnek)
exports.sendAchievementNotification = functions.firestore
  .document('userProgress/{userId}')
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    // Yeni başarım kontrolü (örnek)
    const newAchievements = newData.unlockedAchievements || [];
    const oldAchievements = oldData.unlockedAchievements || [];

    if (newAchievements.length > oldAchievements.length) {
      const latestAchievement = newAchievements[newAchievements.length - 1];
      const userToken = newData.fcmToken;

      if (userToken) {
        const message = {
          notification: {
            title: 'Başarım Açıldı! 🎉',
            body: `${latestAchievement.title} başarımını kazandın!`,
          },
          data: {
            type: 'achievement',
            achievementId: latestAchievement.id,
            screen: '/achievements',
          },
          token: userToken,
        };

        try {
          await admin.messaging().send(message);
        } catch (error) {
          console.error('Error sending achievement notification:', error);
        }
      }
    }

    return null;
  });
```

5. **FCM Token'ı Flutter uygulamasında saklama**

Flutter uygulamanızda FCM token'ı Firestore'a kaydedin:

```dart
// lib/services/notification_service.dart içine ekleyin
Future<void> saveFCMTokenToFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final token = await _firebaseMessaging.getToken();
  if (token == null) return;

  await FirebaseFirestore.instance
    .collection('userProgress')
    .doc(user.uid)
    .set({
      'fcmToken': token,
    }, SetOptions(merge: true));

  debugPrint('FCM Token saved to Firestore');
}
```

6. **Functions'ı deploy edin**
   ```bash
   firebase deploy --only functions
   ```

### Cron Zamanlama Örnekleri:

```
'0 9 * * *'     - Her gün saat 09:00
'0 20 * * *'    - Her gün saat 20:00
'0 9 * * 1'     - Her Pazartesi saat 09:00
'0 9,18 * * *'  - Her gün 09:00 ve 18:00
'*/30 * * * *'  - Her 30 dakikada bir
```

## Yöntem 3: REST API ile Bildirim Gönderme

HTTP isteği ile bildirim göndermek için:

1. **Firebase Console'dan Server Key alın**
   - Project Settings > Cloud Messaging
   - "Server key" kopyalayın

2. **cURL ile örnek gönderim**

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "USER_FCM_TOKEN",
      "notification": {
        "title": "Günlük Ders Hatırlatması",
        "body": "Bugün de çalışmayı unutma! Serini kırma 🔥"
      },
      "data": {
        "type": "daily_reminder",
        "screen": "/home"
      }
    }
  }'
```

**Not:** REST API için OAuth2 access token gerekir. Cloud Functions kullanmak daha kolaydır.

## Yöntem 4: Topics ile Toplu Bildirim

Belirli bir konuya abone olan tüm kullanıcılara bildirim gönderme:

### Flutter'da Topic'e Abone Olma:

```dart
// Tüm kullanıcılar için genel topic
await FirebaseMessaging.instance.subscribeToTopic('all_users');

// Aktif kullanıcılar için
await FirebaseMessaging.instance.subscribeToTopic('active_users');
```

### Cloud Functions'da Topic'e Bildirim Gönderme:

```javascript
const message = {
  notification: {
    title: 'Yeni Özellik!',
    body: 'QuestTime\'a yeni özellikler eklendi!',
  },
  topic: 'all_users', // veya 'active_users'
};

await admin.messaging().send(message);
```

## Önerilen Yapı: FCM Token'ları Firestore'da Saklama

Kullanıcıların FCM token'larını Firestore'da saklamak için:

### Flutter Uygulamasında:

```dart
// lib/services/notification_service.dart içine ekleyin
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveFCMTokenToFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final token = await _firebaseMessaging.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance
      .collection('userProgress')
      .doc(user.uid)
      .update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });

    debugPrint('FCM Token saved to Firestore: $token');

    // Token refresh olduğunda da güncelle
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance
        .collection('userProgress')
        .doc(user.uid)
        .update({
          'fcmToken': newToken,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      debugPrint('FCM Token refreshed: $newToken');
    });
  } catch (e) {
    debugPrint('Error saving FCM token: $e');
  }
}
```

### initialize() metodunu güncelleyin:

```dart
Future<void> initialize() async {
  // ... mevcut kod ...

  // FCM token'ı Firestore'a kaydet
  await saveFCMTokenToFirestore();
}
```

## Örnek Kullanım Senaryoları

### 1. Günlük Hatırlatma
- Cloud Functions ile scheduled function
- Her gün sabah 09:00'da gönder

### 2. Başarım Açıldığında
- Firestore trigger ile
- Kullanıcı başarım kazandığında otomatik gönder

### 3. Streak Uyarısı
- Streak kırılma riskinde
- Son birkaç saat içinde çalışma yoksa uyarı gönder

### 4. Haftalık Özet
- Her Pazar akşamı
- Haftalık istatistikleri içeren bildirim

## Güvenlik Notları

1. **Server Key'i asla public repository'de paylaşmayın**
2. **Cloud Functions kullanarak server-side'da bildirim gönderin**
3. **Kullanıcı authentication kontrolü yapın**
4. **FCM token'ları güvenli şekilde saklayın**

## Test Etme

1. **Test Token alın**
   - Uygulamayı çalıştırın
   - Log'larda FCM token'ı görün
   - Firebase Console > Cloud Messaging > "Send test message" ile test edin

2. **Cloud Functions test**
   - `firebase functions:log` ile log'ları kontrol edin
   - Hataları kontrol edin

## Sorun Giderme

- **Bildirim gelmiyor**:
  - FCM token'ın doğru kaydedildiğini kontrol edin
  - Bildirim izinlerinin verildiğini kontrol edin
  - Cihazın internete bağlı olduğunu kontrol edin

- **Cloud Functions hatası**:
  - `firebase functions:log` ile log'ları kontrol edin
  - Firestore permissions kontrol edin

- **Token güncellenmiyor**:
  - `onTokenRefresh` listener'ının çalıştığını kontrol edin
  - Firestore update permissions kontrol edin

