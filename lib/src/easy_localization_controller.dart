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
      _locale = selectLocaleFrom(
        supportedLocales,
        _deviceLocale,
        fallbackLocale: fallbackLocale,
      );
    }
  }

  @visibleForTesting
  static Locale selectLocaleFrom(
    List<Locale> supportedLocales,
    Locale deviceLocale, {
    Locale? fallbackLocale,
  }) {
    final selectedLocale = supportedLocales.firstWhere(
      (locale) => locale.supports(deviceLocale),
      orElse: () => _getFallbackLocale(supportedLocales, fallbackLocale),
    );
    return selectedLocale;
  }

  //Get fallback Locale
  static Locale _getFallbackLocale(
      List<Locale> supportedLocales, Locale? fallbackLocale) {
    //If fallbackLocale not set then return first from supportedLocales
    if (fallbackLocale != null) {
      return fallbackLocale;
    } else {
      return supportedLocales.first;
    }
  }

  Future loadTranslations() async {
    Map<String, dynamic> data;
    try {
      data = await loadTranslationData(_locale);
      _translations = Translations(data);
      if (useFallbackTranslations && _fallbackLocale != null) {
        Map<String, dynamic>? baseLangData;
        if (_locale.countryCode != null && _locale.countryCode!.isNotEmpty) {
          baseLangData = await loadBaseLangTranslationData(Locale(locale.languageCode));
        }
        data = await loadTranslationData(_fallbackLocale!);
        if (baseLangData != null) {
          data.addAll(baseLangData);
        }
        _fallbackTranslations = Translations(data);
      }
    } on FlutterError catch (e) {
      onLoadError(e);
    } catch (e) {
      onLoadError(FlutterError(e.toString()));
    }
  }

  Future<Map<String, dynamic>?> loadBaseLangTranslationData(Locale locale) async {
    try {
      return await loadTranslationData(Locale(locale.languageCode));
    } on FlutterError catch (e) {
      // Disregard asset not found FlutterError when attempting to load base language fallback
      EasyLocalization.logger.warning(e.message);
    }
    return null;
  }

  Future loadTranslationData(Locale locale) async {
    if (useOnlyLangCode) {
      return assetLoader.load(path, Locale(locale.languageCode));
    } else {
      return assetLoader.load(path, locale);
    }
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

@visibleForTesting
extension LocaleExtension on Locale {
  bool supports(Locale locale) {
    if (this == locale) {
      return true;
    }
    if (languageCode != locale.languageCode) {
      return false;
    }
    if (countryCode != null &&
        countryCode!.isNotEmpty &&
        countryCode != locale.countryCode) {
      return false;
    }
    if (scriptCode != null && scriptCode != locale.scriptCode) {
      return false;
    }

    return true;
  }
}
