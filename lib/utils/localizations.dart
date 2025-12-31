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
}

