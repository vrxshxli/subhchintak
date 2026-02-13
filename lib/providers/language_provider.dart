import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_translations.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  bool _hasChosenLanguage = false;

  String get currentLanguage => _currentLanguage;
  bool get hasChosenLanguage => _hasChosenLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'en';
    _hasChosenLanguage = prefs.getBool('has_chosen_language') ?? false;
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _currentLanguage = langCode;
    _hasChosenLanguage = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', langCode);
    await prefs.setBool('has_chosen_language', true);
    notifyListeners();
  }

  /// Get translated string. Falls back to English if key not found in current language.
  String t(String key) {
    final langMap = AppTranslations.translations[_currentLanguage];
    if (langMap != null && langMap.containsKey(key)) {
      return langMap[key]!;
    }
    // Fallback to English
    final enMap = AppTranslations.translations['en'];
    if (enMap != null && enMap.containsKey(key)) {
      return enMap[key]!;
    }
    return key; // Return key itself as last fallback
  }
}