import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'translations.dart';

class EasyLocalizationController extends ChangeNotifier {
  static Locale? _savedLocale;
  static Locale? _savedSubLocale;
  static late Locale _deviceLocale;

  late Locale _locale;
  late Locale _subLocale;
  Locale? _fallbackLocale;

  final Function(FlutterError e) onLoadError;
  // ignore: prefer_typing_uninitialized_variables
  final assetLoader;
  final String path;
  final bool useFallbackTranslations;
  final bool saveLocale;
  final bool saveSubLocale;
  final bool useOnlyLangCode;
  Translations? _translations, _subTranslations, _fallbackTranslations, _subFallbackTranslations;
  Translations? get translations => _translations;
  Translations? get subTranslations => _subTranslations;
  Translations? get fallbackTranslations => _fallbackTranslations;
  Translations? get subFallbackTranslations => _subFallbackTranslations;

  EasyLocalizationController(
      {required List<Locale> supportedLocales,
      required this.useFallbackTranslations,
      required this.saveLocale,
      required this.saveSubLocale,
      required this.assetLoader,
      required this.path,
      required this.useOnlyLangCode,
      required this.onLoadError,
      Locale? startLocale,
      Locale? startSubLocale,
      Locale? fallbackLocale,
      Locale? forceLocale, // used for testing
      Locale? forceSubLocale // used for testing
      }) {
    _fallbackLocale = fallbackLocale;

    if (forceLocale != null) {
      _locale = forceLocale;
    } else if (_savedLocale == null && startLocale != null) {
      _locale = _getFallbackLocale(supportedLocales, startLocale);
      EasyLocalization.logger('Start locale loaded ${_locale.toString()}');
    } else if (saveLocale && _savedLocale != null) {
      EasyLocalization.logger('Saved locale loaded ${_savedLocale.toString()}');
      _locale = selectLocaleFrom(
        supportedLocales,
        _savedLocale!,
        fallbackLocale: fallbackLocale,
      );
    } else {
      // From Device Locale
      _locale = selectLocaleFrom(
        supportedLocales,
        _deviceLocale,
        fallbackLocale: fallbackLocale,
      );
    }

    if (forceSubLocale != null) {
      _subLocale = forceSubLocale;
    } else if (_savedLocale == null && startSubLocale != null) {
      _subLocale = _getFallbackLocale(supportedLocales, startSubLocale);
      EasyLocalization.logger('Sub start locale loaded ${_subLocale.toString()}');
    } else if (saveSubLocale && _savedSubLocale != null) {
      EasyLocalization.logger('Saved sub locale loaded ${_savedSubLocale.toString()}');
      _subLocale = selectLocaleFrom(
        supportedLocales,
        _savedSubLocale!,
        fallbackLocale: fallbackLocale,
      );
    } else {
      // From Device Locale
      _subLocale = selectLocaleFrom(
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
  static Locale _getFallbackLocale(List<Locale> supportedLocales, Locale? fallbackLocale) {
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
      data = Map.from(await loadTranslationData(_locale));
      _translations = Translations(data);

      if (useFallbackTranslations && _fallbackLocale != null) {
        Map<String, dynamic>? baseLangData;

        if (_locale.countryCode != null && _locale.countryCode!.isNotEmpty) {
          baseLangData = await loadBaseLangTranslationData(Locale(_locale.languageCode));
        }

        data = Map.from(await loadTranslationData(_fallbackLocale!));

        if (baseLangData != null) {
          try {
            data.addAll(baseLangData);
          } on UnsupportedError {
            data = Map.of(data)..addAll(baseLangData);
          }
        }

        _fallbackTranslations = Translations(data);
      }
    } on FlutterError catch (e) {
      onLoadError(e);
    } catch (e) {
      onLoadError(FlutterError(e.toString()));
    }
  }

  Future loadSubTranslations() async {
    Map<String, dynamic> subData;
    try {
      subData = Map.from(await loadTranslationData(_subLocale));
      _subTranslations = Translations(subData);

      if (useFallbackTranslations && _fallbackLocale != null) {
        Map<String, dynamic>? baseLangData;

        if (_subLocale.countryCode != null && _subLocale.countryCode!.isNotEmpty) {
          baseLangData = await loadBaseLangTranslationData(Locale(_subLocale.languageCode));
        }

        subData = Map.from(await loadTranslationData(_fallbackLocale!));

        if (baseLangData != null) {
          try {
            subData.addAll(baseLangData);
          } on UnsupportedError {
            subData = Map.of(subData)..addAll(baseLangData);
          }
        }

        _subFallbackTranslations = Translations(subData);
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

  Future<Map<String, dynamic>> loadTranslationData(Locale locale) async {
    late Map<String, dynamic>? data;

    if (useOnlyLangCode) {
      data = await assetLoader.load(path, Locale(locale.languageCode));
    } else {
      data = await assetLoader.load(path, locale);
    }

    if (data == null) return {};

    return data;
  }

  Locale get locale => _locale;

  Locale get subLocale => _subLocale;

  Future<void> setLocale(Locale l) async {
    _locale = l;
    await loadTranslations();
    notifyListeners();
    EasyLocalization.logger('Locale $locale changed');
    await _saveLocale(_locale);
  }

  Future<void> setSubLocale(Locale l) async {
    _subLocale = l;
    await loadSubTranslations();
    notifyListeners();
    EasyLocalization.logger('Sub locale $subLocale changed');
    await _saveSubLocale(_subLocale);
  }

  Future<void> _saveLocale(Locale? locale) async {
    if (!saveLocale) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('locale', locale.toString());
    EasyLocalization.logger('Locale $locale saved');
  }

  Future<void> _saveSubLocale(Locale? locale) async {
    if (!saveSubLocale) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('subLocale', subLocale.toString());
    EasyLocalization.logger('Sub Locale $subLocale saved');
  }

  static Future<void> initEasyLocation() async {
    final preferences = await SharedPreferences.getInstance();
    final strLocale = preferences.getString('locale');
    _savedLocale = strLocale?.toLocale();
    final strSubLocale = preferences.getString('subLocale');
    _savedSubLocale = strSubLocale?.toLocale();
    final foundPlatformLocale = await findSystemLocale();
    _deviceLocale = foundPlatformLocale.toLocale();
    EasyLocalization.logger.debug('Localization initialized');
  }

  Future<void> deleteSaveLocale() async {
    _savedLocale = null;
    _savedSubLocale = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('locale');
    await preferences.remove('subLocale');
    EasyLocalization.logger('Saved locale deleted');
  }

  Locale get deviceLocale => _deviceLocale;

  Future<void> resetLocale() async {
    EasyLocalization.logger('Reset locale to platform locale $_deviceLocale');

    await setLocale(_deviceLocale);
    await setSubLocale(_deviceLocale);
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
    if (countryCode != null && countryCode!.isNotEmpty && countryCode != locale.countryCode) {
      return false;
    }
    if (scriptCode != null && scriptCode != locale.scriptCode) {
      return false;
    }

    return true;
  }
}
