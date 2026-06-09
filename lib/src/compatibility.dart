import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Compatibility extension for easier migration from v3 to v4
extension EasyLocalizationCompat on EasyLocalization {
  /// Create a widget with v3-style configuration.
  ///
  /// In v4, [supportedLocales], [path], and [assetLoader] moved to
  /// [EasyLocalization.ensureInitialized]. Pass them there instead.
  static Widget withConfig({
    required Widget child,
    List<Locale>? supportedLocales,
    String? path,
    AssetLoader? assetLoader,
    Locale? fallbackLocale,
    bool useOnlyLangCode = false,
    bool useFallbackTranslations = false,
  }) {
    if (supportedLocales != null) {
      EasyLocalization.logger.warning(
        'EasyLocalizationCompat.withConfig: supportedLocales is ignored in v4. '
        'Pass supportedLocales to your AssetLoader (e.g. RootBundleAssetLoader) instead.',
      );
    }
    if (path != null || assetLoader != null) {
      EasyLocalization.logger.warning(
        'EasyLocalizationCompat.withConfig: path/assetLoader should be passed to '
        'EasyLocalization.ensureInitialized() instead of the widget.',
      );
    }
    return EasyLocalization(
      fallbackLocale: fallbackLocale,
      useOnlyLangCode: useOnlyLangCode,
      useFallbackTranslations: useFallbackTranslations,
      child: child,
    );
  }

  /// Create an [AssetLoader] from a v3-style [AssetLoaderType] and [path].
  static AssetLoader migrateAssetLoader({
    String? path,
    AssetLoaderType type = AssetLoaderType.rootBundle,
  }) {
    switch (type) {
      case AssetLoaderType.rootBundle:
        return RootBundleAssetLoader(path: path ?? 'assets/translations');
      case AssetLoaderType.file:
      case AssetLoaderType.network:
        throw UnimplementedError(
          '$type loader is not yet implemented in v4. '
          'Use AssetLoaderType.rootBundle or implement a custom AssetLoader.',
        );
      case AssetLoaderType.custom:
        throw ArgumentError(
          'AssetLoaderType.custom requires you to provide a custom AssetLoader. '
          'Use migrateAssetLoader with rootBundle or create your own loader.',
        );
    }
  }
}

/// Enum for different asset loader types
enum AssetLoaderType { rootBundle, file, network, custom }
