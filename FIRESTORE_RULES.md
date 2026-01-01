# Firestore Security Rules for Leaderboard

Leaderboard özelliğinin çalışması için Firestore security rules'unu güncellemeniz gerekiyor.

## Güncellenmiş Security Rules

Firebase Console'da Firestore Database > Rules sekmesine gidin ve aşağıdaki kuralları kullanın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User Progress - kullanıcılar kendi verilerini okuyup yazabilir, leaderboard için herkes okuyabilir
    match /userProgress/{userId} {
      // Kullanıcılar kendi verilerini okuyup yazabilir
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // Leaderboard için herkes okuyabilir (sadece totalXP, name, username, level, completedQuestsCount)
      allow read: if request.auth != null;
    }

    // Quests - sadece kendi questlerini okuyup yazabilir
    match /quests/{userId}/userQuests/{questId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Daily Quests - sadece kendi daily questlerini okuyup yazabilir
    match /dailyQuests/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Firestore Index Oluşturma

Leaderboard için `orderBy('totalXP')` kullanıldığından, Firestore'da bir **single field index** oluşturmanız gerekebilir.

### Single Field Index (Önerilen)

1. Firebase Console'da Firestore Database > Indexes sekmesine gidin
2. "Single field" sekmesine tıklayın (composite değil!)
3. "Add a single-field index" butonuna tıklayın
4. Collection ID: `userProgress` girin
5. Field path: `totalXP` girin
6. Order: `Descending` seçin
7. "Create" butonuna tıklayın

**ÖNEMLİ:** Composite index değil, **Single field index** oluşturun! Eğer "this index is not necessary" uyarısı görüyorsanız, single field index kullanmanız gerekiyor.

**Alternatif:** İlk kez leaderboard'u açtığınızda Firestore size otomatik olarak index oluşturma linki verebilir. Bu linke tıklayarak index'i oluşturabilirsiniz.

## Test Etme

1. İki farklı cihazdan iki farklı hesap ile giriş yapın
2. Her iki cihazda da bir quest tamamlayın (XP kazanın)
3. Leaderboard ekranını açın
4. Her iki kullanıcı da leaderboard'da görünmelidir

