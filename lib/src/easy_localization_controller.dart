import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'translations.dart';

class EasyLocalizationController extends ChangeNotifier {
  static Locale? _savedLocale;
  static late Locale _deviceLocale;

  late Locale _locale;
  Locale? _fallbackLocale;

  final Function(FlutterError e) onLoadError;
  final assetLoader;
  final String path;
  final bool useFallbackTranslations;
  final bool saveLocale;
  final bool useOnlyLangCode;
  Translations? _translations, _fallbackTranslations;
  Translations? get translations => _translations;
  Translations? get fallbackTranslations => _fallbackTranslations;

  EasyLocalizationController({
    required List<Locale> supportedLocales,
    required this.useFallbackTranslations,
    required this.saveLocale,
    required this.assetLoader,
    required this.path,
    required this.useOnlyLangCode,
    required this.onLoadError,
    Locale? startLocale,
    Locale? fallbackLocale,
    Locale? forceLocale, // used for testing
  }) {
    _fallbackLocale = fallbackLocale;
    if (forceLocale != null) {
      _locale = forceLocale;
    } else if (_savedLocale == null && startLocale != null) {
      _locale = _getFallbackLocale(supportedLocales, startLocale);
      EasyLocalization.logger('Start locale loaded ${_locale.toString()}');
    }
    // If saved locale then get
    else if (saveLocale && _savedLocale != null) {
      EasyLocalization.logger('Saved locale loaded ${_savedLocale.toString()}');
      _locale = _savedLocale!;
    } else {
      // From Device Locale
      _locale = supportedLocales.firstWhere(
          (locale) => _checkInitLocale(locale, _deviceLocale),
          orElse: () => _getFallbackLocale(supportedLocales, fallbackLocale));
    }
  }

  //Get fallback Locale
  Locale _getFallbackLocale(
      List<Locale> supportedLocales, Locale? fallbackLocale) {
    //If fallbackLocale not set then return first from supportedLocales
    if (fallbackLocale != null) {
      return fallbackLocale;
    } else {
      return supportedLocales.first;
    }
  }

  bool _checkInitLocale(Locale locale, Locale? _deviceLocale) {
    // If supported locale not contain countryCode then check only languageCode
    if (locale.countryCode == null) {
      return (locale.languageCode == _deviceLocale!.languageCode);
    } else {
      return (locale == _deviceLocale);
    }
  }

  Future loadTranslations() async {
    Map<String, dynamic>? _data;
    try {
      _data = await loadTranslationData(_locale, path);
      _translations = Translations(_data);
      if (useFallbackTranslations && _fallbackLocale != null) {
        _data = await loadTranslationData(_fallbackLocale!, path);
        _fallbackTranslations = Translations(_data);
      }
    } on FlutterError catch (e) {
      onLoadError(e);
    } catch (e) {
      onLoadError(FlutterError(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> loadTranslationData(
      Locale locale, String path) async {
    Map<String, dynamic>? _data;
    if (useOnlyLangCode) {
      _data = await assetLoader.load(path, Locale(locale.languageCode));
    } else {
      _data = await assetLoader.load(path, locale);
    }
    _data = await loadSeparatedData(_data);
    return _data;
  }

  final RegExp regExpParentheses = RegExp(r'\(([^\)]+)\)', multiLine: false);

  Future<Map<String, dynamic>?> loadSeparatedData(
      Map<String, dynamic>? loadedData) async {
    //check locales tree on separated file
    Future<MapEntry<String, dynamic>> _checkAndLoad(
        String key, dynamic value) async {
      if (value is String) {
        if (value.startsWith('@file')) {
          var math = regExpParentheses.firstMatch(value)?.group(1);
          if (math != null) {
            var fileData = await assetLoader.loadFromPath(math);
            // check again loaded data to separated data
            fileData = await loadSeparatedData(fileData);
            EasyLocalization.logger
                .debug('Separated key $key loaded from $math');
            return MapEntry(key, fileData);
          }
        }
      } else if (value is Map<String, dynamic>) {
        var fileData = await loadSeparatedData(value);
        return MapEntry(key, fileData);
      }
      return MapEntry(key, value);
    }

    var newEntries = <MapEntry<String, dynamic>>[];
    var newMap = <String, dynamic>{};
    for (var entry in loadedData!.entries) {
      newEntries.add(await _checkAndLoad(entry.key, entry.value));
    }
    newMap.addEntries(newEntries);
    return newMap;
  }

  Locale get locale => _locale;

  Future<void> setLocale(Locale l) async {
    _locale = l;
    await loadTranslations();
    notifyListeners();
    EasyLocalization.logger('Locale $locale changed');
    await _saveLocale(_locale);
  }

  Future<void> _saveLocale(Locale? locale) async {
    if (!saveLocale) return;
    final _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('locale', locale.toString());
    EasyLocalization.logger('Locale $locale saved');
  }

  static Future<void> initEasyLocation() async {
    final _preferences = await SharedPreferences.getInstance();
    final _strLocale = _preferences.getString('locale');
    _savedLocale = _strLocale != null ? _strLocale.toLocale() : null;
    final _foundPlatformLocale = await findSystemLocale();
    _deviceLocale = _foundPlatformLocale.toLocale();
    EasyLocalization.logger.debug('Localization initialized');
  }

  Future<void> deleteSaveLocale() async {
    _savedLocale = null;
    final _preferences = await SharedPreferences.getInstance();
    await _preferences.remove('locale');
    EasyLocalization.logger('Saved locale deleted');
  }

  Locale get deviceLocale => _deviceLocale;

  Future<void> resetLocale() async {
    EasyLocalization.logger('Reset locale to platform locale $_deviceLocale');

    await setLocale(_deviceLocale);
  }
}
