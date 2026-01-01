# Version JSON Setup Guide

QuestTime uygulaması artık Firebase Remote Config yerine JSON endpoint'inden versiyon kontrolü yapıyor.

## 📋 JSON Endpoint

Versiyon bilgileri şu URL'den alınır:
```
https://bugradev.com/QuestTime/version.json
```

## 📄 JSON Formatı

`version.json` dosyası aşağıdaki formatta olmalıdır:

```json
{
  "minimum_version_code": 303,
  "update_required": true,
  "update_url": "https://bugradev.com/release",
  "latest_version": "3.0.1",
  "latest_version_code": 303,
  "release_notes": {
    "tr": "Yeni özellikler ve hata düzeltmeleri",
    "en": "New features and bug fixes"
  }
}
```

### Alan Açıklamaları

| Alan | Tip | Zorunlu | Açıklama |
|------|-----|---------|----------|
| `minimum_version_code` | Integer | ✅ | Minimum desteklenen versiyon kodu (pubspec.yaml'daki +XXX değeri) |
| `update_required` | Boolean | ✅ | Zorunlu güncelleme gerekip gerekmediği |
| `update_url` | String | ✅ | Güncelleme indirme linki |
| `latest_version` | String | ❌ | En son versiyon numarası (örn: "3.0.1") |
| `latest_version_code` | Integer | ❌ | En son versiyon kodu |
| `release_notes` | Object | ❌ | Sürüm notları (tr, en) |

## 🚀 Kurulum

### 1. Web Sunucunuzda Dosya Oluşturma

1. `bugradev.com/QuestTime/` klasörüne `version.json` dosyası oluşturun
2. Yukarıdaki JSON formatını kullanın
3. Dosyayı web sunucunuza yükleyin

### 2. JSON İçeriğini Ayarlama

#### Senaryo 1: Zorunlu Güncelleme

Eğer kullanıcıların eski versiyonu kullanmasını engellemek istiyorsanız:

```json
{
  "minimum_version_code": 303,
  "update_required": true,
  "update_url": "https://bugradev.com/release"
}
```

**Sonuç**: Tüm kullanıcılar güncelleme dialogu görecek.

#### Senaryo 2: Opsiyonel Güncelleme

Eğer kullanıcıların eski versiyonu kullanmaya devam etmesine izin veriyorsanız:

```json
{
  "minimum_version_code": 303,
  "update_required": false,
  "update_url": "https://bugradev.com/release"
}
```

**Sonuç**: Sadece versiyon kodu 303'ten düşük olanlar dialog görecek.

#### Senaryo 3: Güncelleme Gerekli Değil

Eğer mevcut versiyon yeterliyse:

```json
{
  "minimum_version_code": 302,
  "update_required": false,
  "update_url": "https://bugradev.com/release"
}
```

**Sonuç**: Versiyon kodu 302 veya üzeri olanlar dialog görmeyecek.

## 🔧 Versiyon Kodu Nasıl Belirlenir?

Versiyon kodu, `pubspec.yaml` dosyasındaki `version` alanındaki `+` işaretinden sonraki sayıdır:

```yaml
version: 3.0.1+303
#              ^^^
#              Bu kısım versiyon kodudur
```

## 📱 Uygulama Davranışı

### Güncelleme Gerekli Olduğunda:

1. Kullanıcı uygulamayı açar
2. Uygulama `bugradev.com/QuestTime/version.json` dosyasını kontrol eder
3. Eğer:
   - `update_required = true` VEYA
   - `currentVersionCode < minimum_version_code`
   - → Update dialog gösterilir
4. Dialog kapatılamaz (back button çalışmaz)
5. "Son Sürümü İndir" butonuna tıklandığında `update_url` linkine yönlendirilir

### Güncelleme Gerekli Olmadığında:

1. Kullanıcı uygulamayı açar
2. Versiyon kontrolü yapılır
3. Güncelleme gerekmiyorsa normal şekilde uygulama açılır

## ✅ Yeni Versiyon Yayınlama Checklist

- [ ] `pubspec.yaml` dosyasında versiyon kodunu artırın (örn: `3.0.1+303`)
- [ ] Yeni APK/AAB oluşturun
- [ ] `version.json` dosyasında `minimum_version_code` değerini güncelleyin
- [ ] Gerekirse `update_required` değerini `true` yapın
- [ ] `version.json` dosyasını web sunucunuza yükleyin
- [ ] `update_url` linkine yeni APK'yı yükleyin
- [ ] Test edin

## 🧪 Test Senaryoları

### Test 1: Güncelleme Gerekli (update_required = true)

```json
{
  "minimum_version_code": 303,
  "update_required": true,
  "update_url": "https://bugradev.com/release"
}
```

**Beklenen**: Tüm kullanıcılar dialog görmeli.

### Test 2: Güncelleme Gerekli (version code check)

```json
{
  "minimum_version_code": 303,
  "update_required": false,
  "update_url": "https://bugradev.com/release"
}
```

**Mevcut versiyon**: 302
**Beklenen**: Dialog gösterilmeli (302 < 303)

### Test 3: Güncelleme Gerekli Değil

```json
{
  "minimum_version_code": 302,
  "update_required": false,
  "update_url": "https://bugradev.com/release"
}
```

**Mevcut versiyon**: 302
**Beklenen**: Dialog gösterilmemeli (302 >= 302)

## ⚠️ Önemli Notlar

1. **JSON Dosyası Erişilebilir Olmalı**: `bugradev.com/QuestTime/version.json` dosyası herkese açık olmalı
2. **HTTPS Kullanın**: Güvenlik için HTTPS kullanın
3. **Cache Kontrolü**: Web sunucunuzda cache ayarlarını kontrol edin
4. **Timeout**: Uygulama 10 saniye içinde yanıt alamazsa güncelleme kontrolü atlanır
5. **Hata Durumu**: JSON alınamazsa veya parse edilemezse, uygulama normal şekilde açılır (güncelleme gerektirmez)

## 📞 Sorun Giderme

### Dialog Görünmüyor

- JSON dosyasının doğru URL'de olduğundan emin olun
- JSON formatının doğru olduğunu kontrol edin
- İnternet bağlantısını kontrol edin
- Uygulamayı kapatıp tekrar açın
- Console loglarını kontrol edin

### JSON Parse Hatası

- JSON formatını kontrol edin (geçerli JSON olmalı)
- Tüm zorunlu alanların mevcut olduğundan emin olun
- Veri tiplerinin doğru olduğunu kontrol edin

### Link Açılmıyor

- `update_url` linkinin çalıştığını kontrol edin
- URL launcher izinlerini kontrol edin
- Cihazda varsayılan tarayıcının yüklü olduğundan emin olun

---

**İyi çalışmalar! 🚀**

