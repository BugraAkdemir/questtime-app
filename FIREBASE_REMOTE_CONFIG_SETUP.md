# Firebase Remote Config Kurulum Rehberi

Bu rehber, QuestTime uygulaması için Firebase Remote Config'i nasıl yapılandıracağınızı açıklar. Remote Config, uygulama güncelleme kontrolü için kullanılır.

## 📋 Adımlar

### 1. Firebase Console'a Giriş

1. https://console.firebase.google.com/ adresine gidin
2. QuestTime projenizi seçin

### 2. Remote Config'i Etkinleştirme

1. Sol menüden **"Remote Config"** seçeneğine tıklayın
2. İlk kez kullanıyorsanız **"Get started"** butonuna tıklayın

### 3. Varsayılan Değerleri Ayarlama

1. Remote Config sayfasında **"Add parameter"** butonuna tıklayın
2. Aşağıdaki parametreleri ekleyin:

#### Parametre 1: `minimum_version_code`
- **Key**: `minimum_version_code`
- **Data type**: Number
- **Default value**: `300` (Mevcut versiyon kodu - pubspec.yaml'daki +300 değeri)
- **Description**: Minimum desteklenen versiyon kodu

#### Parametre 2: `update_required`
- **Key**: `update_required`
- **Data type**: Boolean
- **Default value**: `false`
- **Description**: Zorunlu güncelleme gerekip gerekmediği

#### Parametre 3: `update_url`
- **Key**: `update_url`
- **Data type**: String
- **Default value**: `https://bugradev.com/release`
- **Description**: Güncelleme indirme linki

### 4. Parametreleri Kaydetme

1. Her parametreyi ekledikten sonra **"Save"** butonuna tıklayın
2. Tüm parametreler eklendikten sonra **"Publish changes"** butonuna tıklayın

### 5. Güncelleme Senaryoları

#### Senaryo 1: Yeni Versiyon Yayınlandı (Zorunlu Güncelleme)

Eğer kullanıcıların eski versiyonu kullanmasını engellemek istiyorsanız:

1. `minimum_version_code` değerini yeni versiyon koduna güncelleyin (örn: `301`)
2. `update_required` değerini `true` yapın
3. **"Publish changes"** butonuna tıklayın

**Örnek**:
- Yeni versiyon: 3.0.1+301
- `minimum_version_code`: `301`
- `update_required`: `true`

#### Senaryo 2: Yeni Versiyon Yayınlandı (Opsiyonel Güncelleme)

Eğer kullanıcıların eski versiyonu kullanmaya devam etmesine izin veriyorsanız:

1. `minimum_version_code` değerini yeni versiyon koduna güncelleyin
2. `update_required` değerini `false` bırakın
3. **"Publish changes"** butonuna tıklayın

**Örnek**:
- Yeni versiyon: 3.0.1+301
- `minimum_version_code`: `301`
- `update_required`: `false`

#### Senaryo 3: Kritik Hata Düzeltmesi (Acil Güncelleme)

Kritik bir hata düzeltildiyse ve tüm kullanıcıların güncellemesi gerekiyorsa:

1. `minimum_version_code` değerini mevcut en düşük versiyon koduna ayarlayın
2. `update_required` değerini `true` yapın
3. **"Publish changes"** butonuna tıklayın

**Örnek**:
- Mevcut versiyon: 3.0.0+300
- `minimum_version_code`: `300` (veya daha düşük)
- `update_required`: `true`

### 6. Versiyon Kodu Nasıl Belirlenir?

Versiyon kodu, `pubspec.yaml` dosyasındaki `version` alanındaki `+` işaretinden sonraki sayıdır:

```yaml
version: 3.0.0+300
#              ^^^
#              Bu kısım versiyon kodudur
```

**Versiyon numarası artırma örnekleri**:
- 3.0.0+300 → 3.0.1+301 (Patch update)
- 3.0.0+300 → 3.1.0+310 (Minor update)
- 3.0.0+300 → 4.0.0+400 (Major update)

## 🔧 Test Etme

### Test Senaryosu 1: Güncelleme Gerekli

1. Firebase Console'da `minimum_version_code` değerini mevcut versiyon kodundan **yüksek** bir değere ayarlayın (örn: `301`)
2. `update_required` değerini `true` yapın
3. **"Publish changes"** butonuna tıklayın
4. Uygulamayı açın - Update dialog görünmeli

### Test Senaryosu 2: Güncelleme Gerekli Değil

1. Firebase Console'da `minimum_version_code` değerini mevcut versiyon kodundan **düşük** bir değere ayarlayın (örn: `299`)
2. `update_required` değerini `false` yapın
3. **"Publish changes"** butonuna tıklayın
4. Uygulamayı açın - Update dialog görünmemeli

## 📱 Uygulama Davranışı

### Güncelleme Gerekli Olduğunda:

1. Kullanıcı uygulamayı açar
2. Uygulama Firebase Remote Config'den minimum versiyon kodunu kontrol eder
3. Eğer kullanıcının versiyonu eskiyse veya `update_required` true ise:
   - Update dialog gösterilir
   - Dialog kapatılamaz (back button çalışmaz)
   - "Son Sürümü İndir" butonuna tıklandığında `bugradev.com/release` linkine yönlendirilir

### Güncelleme Gerekli Olmadığında:

1. Kullanıcı uygulamayı açar
2. Versiyon kontrolü yapılır
3. Güncelleme gerekmiyorsa normal şekilde uygulama açılır

## ⚠️ Önemli Notlar

1. **Versiyon Kodu**: Her yeni APK/AAB yayınladığınızda versiyon kodunu artırın
2. **Minimum Fetch Interval**: Remote Config 1 saatte bir kontrol edilir (kod içinde ayarlanmıştır)
3. **Offline Mode**: Eğer internet bağlantısı yoksa, varsayılan değerler kullanılır
4. **Update URL**: `bugradev.com/release` linkinin çalıştığından emin olun

## 🚀 Yeni Versiyon Yayınlama Checklist

- [ ] `pubspec.yaml` dosyasında versiyon kodunu artırın
- [ ] Yeni APK/AAB oluşturun
- [ ] Firebase Remote Config'de `minimum_version_code` değerini güncelleyin
- [ ] Gerekirse `update_required` değerini `true` yapın
- [ ] **"Publish changes"** butonuna tıklayın
- [ ] `bugradev.com/release` linkine yeni APK'yı yükleyin
- [ ] Test edin

## 📞 Sorun Giderme

### Dialog Görünmüyor

- Firebase Remote Config'in doğru yapılandırıldığından emin olun
- İnternet bağlantısını kontrol edin
- Uygulamayı kapatıp tekrar açın
- Firebase Console'da değişikliklerin publish edildiğinden emin olun

### Link Açılmıyor

- `bugradev.com/release` linkinin çalıştığını kontrol edin
- URL launcher izinlerini kontrol edin
- Cihazda varsayılan tarayıcının yüklü olduğundan emin olun

---

**İyi çalışmalar! 🚀**

