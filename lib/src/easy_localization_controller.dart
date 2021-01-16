import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'translations.dart';

class EasyLocalizationController extends ChangeNotifier {
  static Locale _savedLocale;
  static Locale _osLocale;

  Locale _locale;

  final Function(FlutterError e) onLoadError;
  final assetLoader;
  final String path;
  final bool saveLocale;
  final bool useOnlyLangCode;
  Translations _translations;
  Translations get translations => _translations;

  EasyLocalizationController({
    @required List<Locale> supportedLocales,
    @required this.saveLocale,
    @required this.assetLoader,
    @required this.path,
    @required this.useOnlyLangCode,
    @required this.onLoadError,
    Locale startLocale,
    Locale fallbackLocale,
    Locale forceLocale, // used for testing
  }) {
    if (forceLocale != null) {
      _locale = forceLocale;
    } else if (_savedLocale == null && startLocale != null) {
      _locale = _getFallbackLocale(supportedLocales, startLocale);
      EasyLocalization.logger('Start locale loaded ${_locale.toString()}');
    }
    // If saved locale then get
    else if (saveLocale && _savedLocale != null) {
      EasyLocalization.logger('Saved locale loaded ${_savedLocale.toString()}');
      _locale = _savedLocale;
    } else {
      // From Device Locale
      _locale = supportedLocales.firstWhere(
          (locale) => _checkInitLocale(locale, _osLocale),
          orElse: () => _getFallbackLocale(supportedLocales, fallbackLocale));
    }
  }

  //Get fallback Locale
  Locale _getFallbackLocale(
      List<Locale> supportedLocales, Locale fallbackLocale) {
    //If fallbackLocale not set then return first from supportedLocales
    if (fallbackLocale != null) {
      return fallbackLocale;
    } else {
      return supportedLocales.first;
    }
  }

  bool _checkInitLocale(Locale locale, Locale _osLocale) {
    // If suported locale not contain countryCode then check only languageCode
    if (locale.countryCode == null) {
      return (locale.languageCode == _osLocale.languageCode);
    } else {
      return (locale == _osLocale);
    }
  }

  Future loadTranslations() async {
    Map<String, dynamic> data;
    try {
      useOnlyLangCode
          ? data = await assetLoader.load(path, Locale(_locale.languageCode))
          : data = await assetLoader.load(path, _locale);
      _translations = Translations(data);
    } on FlutterError catch (e) {
      onLoadError(e);
    } catch (e) {
      onLoadError(FlutterError(e.toString()));
    }
  }

  Locale get locale => _locale;
  Future<void> setLocale(Locale l) async {
    _locale = l;
    await loadTranslations();
    notifyListeners();
    await _saveLocale(_locale);
  }

  Future<void> _saveLocale(Locale locale) async {
    if (!saveLocale) return;
    final _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('locale', locale.toString());
  }

  static Future<void> initEasyLocation() async {
    final _preferences = await SharedPreferences.getInstance();
    final _strLocale = _preferences.getString('locale');
    _savedLocale = _strLocale != null ? localeFromString(_strLocale) : null;
    final _deviceLocale = await findSystemLocale();
    _osLocale = localeFromString(_deviceLocale);
  }

  Future<void> deleteSaveLocale() async {
    _savedLocale = null;
    final _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('locale', null);
    EasyLocalization.logger('Saved locale deleted');
  }
}
