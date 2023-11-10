import 'dart:io' as io;

import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';

import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'translations.dart';
import 'asset_loader.dart';
import 'easy_localization_storage_interface.dart';
import 'easy_localization_app.dart';

class EasyLocalizationController extends ChangeNotifier {
  static Locale? _savedLocale;
  static late Locale _deviceLocale;
  static IEasyLocalizationStorage? _storage;

  static late List<Map<String, dynamic>>? _listtranslationData;

  static List<Locale> _supportedLocales = [];

  static List<Locale> get supportedLocales => _supportedLocales;

  static late AssetLoader _assetLoader;

  static late Locale _locale;
  final Locale? _fallbackLocale;

  final Function(FlutterError e) onLoadError;
  final bool useFallbackTranslations;
  final bool saveLocale;
  final bool useOnlyLangCode;
  Translations? _translations, _fallbackTranslations;
  Translations? get translations => _translations;
  Translations? get fallbackTranslations => _fallbackTranslations;

  EasyLocalizationController({
    required this.useFallbackTranslations,
    required this.saveLocale,
    required this.useOnlyLangCode,
    required this.onLoadError,
    Locale? startLocale,
    Locale? fallbackLocale,
    List<Locale>? supportedLocales,
    Locale? forceLocale, // used for testing
  }) : _fallbackLocale = fallbackLocale {
    assert(_storage != null || saveLocale == false,
        'storage must not be null if saveLocale is true');

    // _supportedLocales = supportedLocales ?? <Locale>[];

    if (forceLocale != null) {
      _locale = forceLocale;
    } else if (_savedLocale == null && startLocale != null) {
      _locale = _getFallbackLocale(_supportedLocales, startLocale);
      EasyLocalization.logger('Start locale loaded ${_locale.toString()}');
    }
    // If saved locale then get
    else if (saveLocale && _savedLocale != null) {
      EasyLocalization.logger('Saved locale loaded ${_savedLocale.toString()}');
      _locale = selectLocaleFrom(
        _supportedLocales,
        _savedLocale!,
        fallbackLocale: fallbackLocale,
      );
    } else {
      // From Device Locale
      _locale = selectLocaleFrom(
        _supportedLocales,
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

  Future<void> loadTranslations() async {
    try {
      final translationData = await loadTranslationData(_locale);
      _translations = Translations(Map.from(translationData));

      if (useFallbackTranslations && _fallbackLocale != null) {
        final baseLangData =
            await loadTranslationData(Locale(_locale.languageCode));
        final fallbackTranslationData =
            await loadTranslationData(_fallbackLocale!);

        if (baseLangData.isNotEmpty) {
          fallbackTranslationData.addAll(baseLangData);
        }

        _fallbackTranslations = Translations(Map.from(fallbackTranslationData));
      }
    } catch (e) {
      onLoadError(FlutterError(e.toString()));
    }
  }

  Future<Map<String, dynamic>> loadTranslationData(Locale locale) async {
    late final Map<String, dynamic> translationData;

    try {
      if (_listtranslationData != null) {
        var index = _supportedLocales.indexOf(locale);
        translationData = _listtranslationData![index];
        _listtranslationData?.clear();
        _listtranslationData = null;
      } else {
        translationData = await _assetLoader.load(locale: locale);
      }
    } catch (e) {
      EasyLocalization.logger.error('loadTranslationData $e ');
    }

    return translationData;
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
    if (!saveLocale && _storage == null) return;

    // final preferences = await SharedPreferences.getInstance();
    // await preferences.setString('locale', locale.toString());
    await _storage?.setValue<String>('locale', locale.toString());
    EasyLocalization.logger('Locale $locale saved');
  }

  /// Initializes the EasyLocalization by loading supported locales data and setting the device and saved locale.
  ///
  /// Parameters:
  /// - [assetLoader]: The asset loader used to load the supported locales data.
  /// - [storage]: The storage implementation used to store the locale data.
  static Future<void> initEasyLocation(AssetLoader assetLoader,
      {IEasyLocalizationStorage? storage}) async {
    // Initialize storage if provided
    _storage = storage;
    _assetLoader = assetLoader;
    storage?.init();

    // Get the saved locale from the storage
    final strLocale = storage?.getValue<String>('locale');
    _savedLocale = strLocale?.toLocale();

    // Get the device locale
    final foundPlatformLocale = await findSystemLocale();
    _deviceLocale = foundPlatformLocale.toLocale();

    // Load supported locales data
    _listtranslationData = await _loadSupportedLocalesData(assetLoader);

    // Log initialization
    EasyLocalization.logger.debug('Localization initialized');
  }

  /// Loads the supported locales data from the asset loader.
  ///
  /// Parameters:
  /// - [loader]: The asset loader used to load the supported locales data.
  ///
  /// Returns a list of translation data for each supported locale.
  static Future<List<Map<String, dynamic>>> _loadSupportedLocalesData(
    AssetLoader loader,
  ) async {
    EasyLocalization.logger.debug('Load supported locales data');
    EasyLocalization.logger.debug('device locale: $_deviceLocale');
    EasyLocalization.logger.debug('saved locale: $_savedLocale');
    EasyLocalization.logger.debug('loader path: ${loader.path}');
    EasyLocalization.logger
        .debug('loader supported locales: ${loader.supportedLocales}');

    List<Map<String, dynamic>> translationData = [];

    // Set the supported locales if provided
    if (loader.supportedLocales != null) {
      _supportedLocales = loader.supportedLocales!;
    }

    // Check if the assets directory exists
    if (loader.path != null) {
      final io.Directory assetsDirectory = io.Directory(loader.path!);
      if (assetsDirectory.existsSync()) {
        // Get the list of assets files in the directory
        final List<io.FileSystemEntity> assets =
            assetsDirectory.listSync(recursive: false, followLinks: false);

        // Set the supported locales based on the assets files
        _supportedLocales = loader.supportedLocales ??
            assets
                .whereType<io.File>()
                .map((e) => Path.basename(e.path)
                    .split('.')
                    .first
                    .toLocale(separator: '-'))
                .toList();
      } else {
        throw io.PathExistsException;
      }
    }

    // Load translation data for each supported locale
    for (var locale in _supportedLocales) {
      translationData.add(await loader.load(locale: locale));
    }

    return translationData;
  }

  Future<void> deleteSaveLocale() async {
    _savedLocale = null;
    await _storage?.removeValue('locale');
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
