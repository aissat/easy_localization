import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Abstract class for loading assets.
abstract class AssetLoader {
  /// Path to the assets directory.
  /// Example:
  /// ```dart
  /// path: 'assets/translations',
  /// path: 'assets/translations/lang.csv',
  /// ```
  final String? path;

  /// List of supported locales.
  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  final List<Locale>? supportedLocales;

  /// Constructor for [AssetLoader].
  ///
  /// [path] is the path to the assets directory.
  /// [supportedLocales] is a list of locales that the assets support.
  const AssetLoader({this.path, this.supportedLocales})
      : assert(path != null || supportedLocales != null,
            'path or supportedLocales must not be null');

  /// Loads the assets for the given [locale].
  ///
  /// Returns a map of loaded assets.
  Future<Map<String, dynamic>> load({Locale? locale});
}

/// Base asset loader with optional caching mechanism
class CachedAssetLoader extends AssetLoader {
  const CachedAssetLoader({required super.path});

  static final Map<Locale, Map<String, dynamic>> _translationCache = {};

  /// Provide read access to the cache for other loaders (e.g. [OptimizedAssetLoader]).
  @visibleForTesting
  static Map<Locale, Map<String, dynamic>> get translationCache =>
      _translationCache;

  /// Cache translations for a locale
  void cacheTranslations(Locale locale, Map<String, dynamic> translations) {
    _translationCache[locale] = translations;
  }

  /// Get cached translations for a locale
  Map<String, dynamic>? getCachedTranslations(Locale locale) =>
      _translationCache[locale];

  /// Check if a locale's translations are cached
  bool isCached(Locale locale) => _translationCache.containsKey(locale);

  @override
  Future<Map<String, dynamic>> load({Locale? locale}) async {
    if (locale == null) {
      throw ArgumentError.notNull('locale');
    }

    if (_translationCache.containsKey(locale)) {
      return _translationCache[locale]!;
    }

    return {};
  }
}

///
/// The `RootBundleAssetLoader` class is a subclass of `AssetLoader` that uses Flutter's asset loader
/// to load localized JSON files.
///
class RootBundleAssetLoader extends AssetLoader {
  final bool useOnlyLangCode;

  static final Map<Locale, Map<String, dynamic>> _cache = {};

  const RootBundleAssetLoader({
    required String path,
    this.useOnlyLangCode = false,
    List<Locale>? supportedLocales,
  }) : super(path: path, supportedLocales: supportedLocales);

  String getLocalePath(Locale locale) {
    if (useOnlyLangCode) {
      return '$path/${locale.languageCode}.json';
    } else {
      return '$path/${locale.toStringWithSeparator(separator: "-")}.json';
    }
  }

  @override
  Future<Map<String, dynamic>> load({Locale? locale}) async {
    final l = locale!;
    if (_cache.containsKey(l)) return _cache[l]!;

    final localePath = getLocalePath(l);
    EasyLocalization.logger.debug('Loading asset: $localePath');
    final data = json.decode(await rootBundle.loadString(localePath))
        as Map<String, dynamic>;
    _cache[l] = data;
    return data;
  }

  /// Clear the internal cache (useful for testing or hot-reload).
  @visibleForTesting
  static void clearCache() => _cache.clear();
}

/// Optimized Root Bundle Asset Loader with built-in caching
///
/// Wraps [RootBundleAssetLoader] with its own translation cache.
/// Prefer using [RootBundleAssetLoader] directly — it now includes caching.
class OptimizedAssetLoader extends RootBundleAssetLoader {
  static final Map<Locale, Map<String, dynamic>> _cache = {};

  OptimizedAssetLoader({required String path}) : super(path: path);

  @override
  Future<Map<String, dynamic>> load({Locale? locale}) async {
    if (locale == null) throw ArgumentError.notNull('locale');

    if (_cache.containsKey(locale)) {
      EasyLocalization.logger.debug('Using cached translations for $locale');
      return _cache[locale]!;
    }

    final translations = await super.load(locale: locale);
    _cache[locale] = translations;
    return translations;
  }

  /// Clear the internal cache (useful for testing or hot-reload).
  @visibleForTesting
  static void clearCache() => _cache.clear();
}
