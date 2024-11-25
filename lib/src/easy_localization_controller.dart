import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_helper/easy_localization_helper.dart';
import 'package:easy_localization_storage/easy_localization_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';

import 'translations.dart';

class EasyLocalizationController extends ChangeNotifier {
  static Locale? _savedLocale;
  static late Locale _deviceLocale;
  static EasyLocalizationStorage? _storage;
  static EasyLocalizationStorage get storage {
    if (_storage == null) {
      throw StateError(
          'EasyLocalizationController not initialized. Call initEasyLocation first.');
    }
    return _storage!;
  }

  static set storage(EasyLocalizationStorage storage) {
    _storage = storage;
  }

  late Locale _locale;
  Locale? _fallbackLocale;
  late List<Locale> _supportedLocales;

  final Function(FlutterError e) onLoadError;
  final AssetLoader assetLoader;
  final String path;
  final bool useFallbackTranslations;
  final bool saveLocale;
  final bool useOnlyLangCode;
  List<AssetLoader>? extraAssetLoaders;
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
    this.extraAssetLoaders,
    Locale? startLocale,
    Locale? fallbackLocale,
    Locale? forceLocale, // used for testing
  }) {
    _fallbackLocale = fallbackLocale;
    _supportedLocales = supportedLocales;
    if (forceLocale != null) {
      _locale = forceLocale;
    } else if (_savedLocale == null && startLocale != null) {
      _locale = _getFallbackLocale(supportedLocales, startLocale);
      EasyLocalization.logger('Start locale loaded ${_locale.toString()}');
    }
    // If saved locale then get
    else if (saveLocale && _savedLocale != null) {
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
  }

  @visibleForTesting
  static Locale selectLocaleFrom(
    List<Locale> supportedLocales,
    Locale deviceLocale, {
    Locale? fallbackLocale,
  }) {
    final selectedLocale = supportedLocales.firstWhere(
      (locale) => locale.supports(deviceLocale),
      orElse: () => _getFallbackLocale(
        supportedLocales,
        fallbackLocale,
        deviceLocale: deviceLocale,
      ),
    );
    return selectedLocale;
  }

  //Get fallback Locale
  static Locale _getFallbackLocale(
      List<Locale> supportedLocales, Locale? fallbackLocale,
      {final Locale? deviceLocale}) {
    if (deviceLocale != null) {
      // a locale that matches the language code of the device locale is
      // preferred over the fallback locale
      final deviceLanguage = deviceLocale.languageCode;
      for (Locale locale in supportedLocales) {
        if (locale.languageCode == deviceLanguage) {
          return locale;
        }
      }
    }
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
          baseLangData =
              await loadBaseLangTranslationData(Locale(locale.languageCode));
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

  Future<Map<String, dynamic>?> loadBaseLangTranslationData(
      Locale locale) async {
    try {
      return await loadTranslationData(Locale(locale.languageCode));
    } on FlutterError catch (e) {
      // Disregard asset not found FlutterError when attempting to load base language fallback
      EasyLocalization.logger.warning(e.message);
    }
    return null;
  }

  Future<Map<String, dynamic>> loadTranslationData(Locale locale) async =>
      _combineAssetLoaders(
        path: path,
        locale: locale,
        assetLoader: assetLoader,
        useOnlyLangCode: useOnlyLangCode,
        extraAssetLoaders: extraAssetLoaders,
      );

  Future<Map<String, dynamic>> _combineAssetLoaders({
    required String path,
    required Locale locale,
    required AssetLoader assetLoader,
    required bool useOnlyLangCode,
    List<AssetLoader>? extraAssetLoaders,
  }) async {
    final result = <String, dynamic>{};
    final loaderFutures = <Future<Map<String, dynamic>?>>[];

    // need scriptCode, it might be better to use ignoreCountryCode as the variable name of useOnlyLangCode
    final Locale desiredLocale = useOnlyLangCode
        ? Locale.fromSubtags(
            languageCode: locale.languageCode, scriptCode: locale.scriptCode)
        : locale;

    List<AssetLoader> loaders = [
      assetLoader,
      if (extraAssetLoaders != null) ...extraAssetLoaders
    ];

    for (final loader in loaders) {
      loaderFutures.add(loader.load(path, desiredLocale));
    }

    await Future.wait(loaderFutures).then((List<Map<String, dynamic>?> value) {
      for (final Map<String, dynamic>? map in value) {
        if (map != null) {
          result.addAllRecursive(map);
        }
      }
    });

    return result;
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
    await storage.setLocale(value: locale);
    EasyLocalization.logger('Locale $locale saved');
  }

  static Future<void> initEasyLocation(EasyLocalizationStorage storage) async {
    EasyLocalizationController.storage = storage;
    _savedLocale = await storage.getLocale();
    final foundPlatformLocale = await findSystemLocale();
    _deviceLocale = foundPlatformLocale.toLocale();
    EasyLocalization.logger.debug('Localization initialized');
  }

  Future<void> deleteSaveLocale() async {
    _savedLocale = null;
    storage.setLocale();
    EasyLocalization.logger('Saved locale deleted');
  }

  Locale get deviceLocale => _deviceLocale;
  Locale? get savedLocale => _savedLocale;

  Future<void> resetLocale() async {
    final locale = selectLocaleFrom(_supportedLocales, deviceLocale,
        fallbackLocale: _fallbackLocale);

    EasyLocalization.logger(
        'Reset locale to $locale while the platform locale is $_deviceLocale and the fallback locale is $_fallbackLocale');
    await setLocale(locale);
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
