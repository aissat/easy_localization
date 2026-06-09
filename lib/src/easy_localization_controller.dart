import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';

import 'asset_loader.dart';
import 'easy_localization_app.dart';
import 'easy_localization_storage_interface.dart';
import 'exceptions.dart';
import 'translations.dart';

class EasyLocalizationController extends ChangeNotifier {
  static Locale? _savedLocale;
  static late Locale _deviceLocale;
  static IEasyLocalizationStorage? _storage;

  static List<Locale> _supportedLocales = [];

  static late AssetLoader _assetLoader;

  static late Locale _locale;

  static List<Locale> get supportedLocales => _supportedLocales;
  final Locale? _fallbackLocale;

  final Function(FlutterError e) onLoadError;
  final bool useFallbackTranslations;
  final bool saveLocale;
  final bool useOnlyLangCode;
  Translations? _translations, _fallbackTranslations;

  bool _loading = false;

  EasyLocalizationController({
    required this.useFallbackTranslations,
    required this.saveLocale,
    required this.useOnlyLangCode,
    required this.onLoadError,
    Locale? startLocale,
    Locale? fallbackLocale,
    List<Locale>? supportedLocales,
    Locale? forceLocale,
  }) : _fallbackLocale = fallbackLocale {
    assert(_storage != null || saveLocale == false,
        'storage must not be null if saveLocale is true');

    if (forceLocale != null) {
      _locale = forceLocale;
    } else if (_savedLocale == null && startLocale != null) {
      _locale = _getFallbackLocale(_supportedLocales, startLocale);
      EasyLocalization.logger('Start locale loaded ${_locale.toString()}');
    } else if (saveLocale && _savedLocale != null) {
      EasyLocalization.logger('Saved locale loaded ${_savedLocale.toString()}');
      _locale = selectLocaleFrom(
        _supportedLocales,
        _savedLocale!,
        fallbackLocale: fallbackLocale,
      );
    } else {
      _locale = selectLocaleFrom(
        _supportedLocales,
        _deviceLocale,
        fallbackLocale: fallbackLocale,
      );
    }
  }
  Locale get deviceLocale => _deviceLocale;

  Translations? get fallbackTranslations => _fallbackTranslations;

  Locale get locale => _locale;

  Translations? get translations => _translations;

  Future<void> deleteSaveLocale() async {
    _savedLocale = null;
    await _storage?.removeValue('locale');
    EasyLocalization.logger('Saved locale deleted');
  }

  Future<Map<String, dynamic>> loadTranslationData(Locale locale) async {
    try {
      return await _assetLoader.load(locale: locale);
    } catch (e, stackTrace) {
      EasyLocalization.logger.error(
          'Failed to load translations for $locale $e',
          stackTrace: stackTrace);
      throw TranslationLoadException(locale, e);
    }
  }

  Future<void> loadTranslations() async {
    try {
      _translations = Translations(await loadTranslationData(_locale));

      if (useFallbackTranslations && _fallbackLocale != null) {
        final fallbackData = await loadTranslationData(_fallbackLocale!);

        try {
          final baseLang = Locale(_locale.languageCode);
          if (baseLang != _locale && supportedLocales.contains(baseLang)) {
            final baseData = await loadTranslationData(baseLang);
            baseData.forEach((k, v) {
              if (v != null) {
                fallbackData.putIfAbsent(k, () => v);
              }
            });
          }
        } catch (e) {
          EasyLocalization.logger
              .warning('Base language ${_locale.languageCode} not found');
        }

        _fallbackTranslations = Translations(fallbackData);
      }
    } on TranslationLoadException catch (e) {
      EasyLocalization.logger.error('TranslationLoadException caught: ${e.locale}');
      onLoadError(FlutterError('Failed to load translations: ${e.locale}'));
    }
  }

  Future<void> resetLocale() async {
    EasyLocalization.logger('Reset locale to platform locale $_deviceLocale');
    await setLocale(_deviceLocale);
  }

  Future<void> setLocale(Locale l) async {
    if (_loading) return;
    _loading = true;
    try {
      _locale = l;
      await loadTranslations();
      notifyListeners();
      EasyLocalization.logger('Locale $locale changed');
      await _saveLocale(_locale);
    } finally {
      _loading = false;
    }
  }

  Future<void> _saveLocale(Locale? locale) async {
    if (!saveLocale && _storage == null) return;

    await _storage?.setValue('locale', locale.toString());
    EasyLocalization.logger('Locale $locale saved');
  }

  /// Initializes the EasyLocalization by loading supported locales data and setting the device and saved locale.
  ///
  /// Parameters:
  /// - [assetLoader]: The asset loader used to load the supported locales data.
  /// - [storage]: The storage implementation used to store the locale data.
  static Future<void> initEasyLocation(AssetLoader assetLoader,
      {IEasyLocalizationStorage? storage}) async {
    _storage = storage;
    _assetLoader = assetLoader;
    await storage?.init();

    final strLocale = storage != null ? await storage.getValue('locale') : null;
    _savedLocale = strLocale?.toLocale();

    final foundPlatformLocale = await findSystemLocale();
    _deviceLocale = foundPlatformLocale.toLocale();

    await _loadSupportedLocalesData(assetLoader);

    EasyLocalization.logger.debug('Localization initialized');
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

  static Locale _getFallbackLocale(
      List<Locale> supportedLocales, Locale? fallbackLocale) {
    if (fallbackLocale != null) {
      return fallbackLocale;
    } else {
      return supportedLocales.first;
    }
  }

  static Future<void> _loadSupportedLocalesData(
    AssetLoader loader,
  ) async {
    EasyLocalization.logger.debug('Load supported locales data');
    EasyLocalization.logger.debug('device locale: $_deviceLocale');
    EasyLocalization.logger.debug('saved locale: $_savedLocale');
    EasyLocalization.logger.debug('loader path: ${loader.path}');
    EasyLocalization.logger
        .debug('loader supported locales: ${loader.supportedLocales}');

    if (loader.supportedLocales != null) {
      _supportedLocales = loader.supportedLocales!;
      return;
    }

    if (_supportedLocales.isEmpty) {
      _supportedLocales = [_deviceLocale];
    }
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
