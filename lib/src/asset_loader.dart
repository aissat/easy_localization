import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

/// Abstract class for loading assets.
abstract class AssetLoader {
  final String? path;
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

///
/// The `RootBundleAssetLoader` class is a subclass of `AssetLoader` that uses Flutter's asset loader
/// to load localized JSON files.
///
class RootBundleAssetLoader extends AssetLoader {
  // A custom asset loader that loads assets from the root bundle

  const RootBundleAssetLoader(String path) : super(path: path);

  /// Returns the path for the specified locale
  ///
  /// The [locale] parameter represents the desired locale.
  /// The returned path is based on the [path] of the asset loader
  /// and the [locale] with a separator ("-") between language and country.
  String getLocalePath(Locale locale) {
    return '$path/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  ///
  /// Loads the localized JSON file for the given `locale`.
  ///
  /// Throws an `ArgumentError` if the `locale` is `null`.
  ///
  @override
  Future<Map<String, dynamic>> load({Locale? locale}) async {
    if (locale == null) throw ArgumentError.notNull('locale');
    var localePath = getLocalePath(locale);
    EasyLocalization.logger.debug('Load asset from $path');

    // Load the asset as a string and decode it as JSON
    return json.decode(await rootBundle.loadString(localePath));
  }
}
