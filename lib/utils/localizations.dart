import '../providers/settings_provider.dart';

/// Simple localization helper
class AppLocalizations {
  final LanguageOption language;

  AppLocalizations(this.language);

  bool get isTurkish => language == LanguageOption.turkish;

  // Common strings
  String get appTitle => 'QuestTime';
  String get settings => isTurkish ? 'Ayarlar' : 'Settings';
  String get stats => isTurkish ? 'İstatistikler' : 'Statistics';
  String get theme => isTurkish ? 'Tema' : 'Theme';
  String get languageLabel => isTurkish ? 'Dil' : 'Language';
  String get about => isTurkish ? 'Hakkında' : 'About';
  String get creator => isTurkish ? 'Geliştirici' : 'Creator';
  String get github => isTurkish ? 'GitHub' : 'GitHub';
  String get startNewQuest => isTurkish ? 'Yeni Quest Başlat' : 'Start New Quest';
  String get readyToStudy => isTurkish ? 'Çalışmaya Hazır mısın?' : 'Ready to Study?';
  String get recentQuests => isTurkish ? 'Son Questler' : 'Recent Quests';
  String get questCompleted => isTurkish ? 'Quest Tamamlandı!' : 'Quest Completed!';
  String get xpEarned => isTurkish ? 'XP Kazandın!' : 'XP Earned!';
  String get totalXP => isTurkish ? 'Toplam XP' : 'Total XP';
  String get level => isTurkish ? 'Seviye' : 'Level';
  String get awesome => isTurkish ? 'Harika!' : 'Awesome!';
  String get cancel => isTurkish ? 'İptal' : 'Cancel';
  String get ok => isTurkish ? 'Tamam' : 'OK';
  String get questCancelled => isTurkish ? 'Quest İptal Edildi' : 'Quest Cancelled';
  String get youStudiedFor => isTurkish ? 'Dakika çalıştın.' : 'You studied for';
  String get minutes => isTurkish ? 'dakika' : 'minutes';
  String get note => isTurkish ? 'Not' : 'Note';
  String get xpOnlyOnCompletion => isTurkish
      ? 'XP sadece quest tamamlandığında verilir.'
      : 'XP is only awarded when you complete a quest.';

  // Quest Selection Dialog
  String get subject => isTurkish ? 'Ders' : 'Subject';
  String get difficulty => isTurkish ? 'Zorluk' : 'Difficulty';
  String get duration => isTurkish ? 'Süre (dakika)' : 'Duration (minutes)';
  String get customDuration => isTurkish ? 'Özel Süre' : 'Custom Duration';
  String get customQuest => isTurkish ? 'Özel Ders' : 'Custom Subject';
  String get enterSubjectName => isTurkish ? 'Ders adını girin' : 'Enter subject name';
  String get enterMinutes => isTurkish ? 'Dakika girin (1-999)' : 'Enter minutes (1-999)';
  String get startQuest => isTurkish ? 'Quest Başlat' : 'Start Quest';
  String get invalidDuration => isTurkish
      ? 'Lütfen geçerli bir süre girin (1-999 dakika)'
      : 'Please enter a valid duration (1-999 minutes)';
  String get invalidNumber => isTurkish
      ? 'Lütfen geçerli bir sayı girin (1-999)'
      : 'Please enter a valid number (1-999)';
  String get enterSubjectNameError => isTurkish
      ? 'Lütfen bir ders adı girin'
      : 'Please enter a subject name';

  // Auth strings
  String get login => isTurkish ? 'Giriş Yap' : 'Login';
  String get signUp => isTurkish ? 'Kayıt Ol' : 'Sign Up';
  String get email => isTurkish ? 'E-posta' : 'Email';
  String get password => isTurkish ? 'Şifre' : 'Password';
  String get confirmPassword => isTurkish ? 'Şifre Tekrar' : 'Confirm Password';
  String get loginButton => isTurkish ? 'Giriş Yap' : 'Login';
  String get signUpButton => isTurkish ? 'Kayıt Ol' : 'Sign Up';
  String get alreadyHaveAccount => isTurkish
      ? 'Zaten hesabınız var mı?'
      : 'Already have an account?';
  String get dontHaveAccount => isTurkish
      ? 'Hesabınız yok mu?'
      : "Don't have an account?";
  String get signUpHere => isTurkish ? 'Buradan kayıt olun' : 'Sign up here';
  String get loginHere => isTurkish ? 'Buradan giriş yapın' : 'Login here';
  String get logout => isTurkish ? 'Çıkış Yap' : 'Logout';
  String get welcome => isTurkish ? 'Hoş Geldiniz' : 'Welcome';
  String get welcomeBack => isTurkish ? 'Tekrar Hoş Geldiniz' : 'Welcome Back';
  String get createAccount => isTurkish ? 'Hesap Oluştur' : 'Create Account';
  String get emailRequired => isTurkish
      ? 'E-posta gereklidir'
      : 'Email is required';
  String get passwordRequired => isTurkish
      ? 'Şifre gereklidir'
      : 'Password is required';
  String get passwordTooShort => isTurkish
      ? 'Şifre en az 6 karakter olmalıdır'
      : 'Password must be at least 6 characters';
  String get passwordsDoNotMatch => isTurkish
      ? 'Şifreler eşleşmiyor'
      : 'Passwords do not match';
  String get invalidEmail => isTurkish
      ? 'Geçersiz e-posta adresi'
      : 'Invalid email address';
  String get notLoggedInWarning => isTurkish
      ? 'Herhangi bir hesaba giriş yapılmadı. Verileriniz kaybolabilir.'
      : 'Not logged in to any account. Your data may be lost.';
  String get loginToSaveData => isTurkish
      ? 'Verilerinizi kaydetmek için giriş yapın'
      : 'Login to save your data';
  String get skip => isTurkish ? 'Atla' : 'Skip';
  String get name => isTurkish ? 'Ad' : 'Name';
  String get username => isTurkish ? 'Kullanıcı Adı' : 'Username';
  String get nameRequired => isTurkish
      ? 'Ad gereklidir'
      : 'Name is required';
  String get usernameRequired => isTurkish
      ? 'Kullanıcı adı gereklidir'
      : 'Username is required';
  String get usernameTooShort => isTurkish
      ? 'Kullanıcı adı en az 3 karakter olmalıdır'
      : 'Username must be at least 3 characters';
  String get profile => isTurkish ? 'Profil' : 'Profile';
  String get editProfile => isTurkish ? 'Profili Düzenle' : 'Edit Profile';
  String get save => isTurkish ? 'Kaydet' : 'Save';
  String get profileUpdated => isTurkish
      ? 'Profil güncellendi'
      : 'Profile updated';
  String get enterName => isTurkish ? 'Adınızı girin' : 'Enter your name';
  String get enterUsername => isTurkish
      ? 'Kullanıcı adınızı girin'
      : 'Enter your username';
  String get stopwatch => isTurkish ? 'Kronometre' : 'Stopwatch';
  String get stopwatchMode => isTurkish
      ? 'Kronometre Modu'
      : 'Stopwatch Mode';
  String get stopwatchDescription => isTurkish
      ? 'Ne kadar çalışırsan o kadar puan kazan!'
      : 'Earn points for however long you study!';
  String get startStopwatch => isTurkish
      ? 'Kronometreyi Başlat'
      : 'Start Stopwatch';
  String get stopStopwatch => isTurkish
      ? 'Kronometreyi Durdur'
      : 'Stop Stopwatch';
  String get stopwatchStopped => isTurkish
      ? 'Kronometre Durduruldu'
      : 'Stopwatch Stopped';
  String get elapsedTime => isTurkish
      ? 'Geçen Süre'
      : 'Elapsed Time';
  String get coins => isTurkish ? 'Coin' : 'Coins';
}

