import 'dart:convert';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

/// abstract class used to building your Custom AssetLoader
/// Example:
/// ```
///class FileAssetLoader extends AssetLoader {
///  @override
///  Future<Map<String, dynamic>> load(String path, Locale locale) async {
///    final file = File(path);
///    return json.decode(await file.readAsString());
///  }
///}
/// ```
abstract class AssetLoader {
  const AssetLoader();
  Future<Map<String, dynamic>?> load(String path, Locale locale);
  Future<Map<String, dynamic>?> loadFromPath(String path);
}

///
/// default used is RootBundleAssetLoader which uses flutter's assetloader
///
class RootBundleAssetLoader implements AssetLoader {
  const RootBundleAssetLoader();

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    return loadFromPath(localePath);
  }

  @override
  Future<Map<String, dynamic>?> loadFromPath(String path) async {
    EasyLocalization.logger.debug('Load asset from $path');
    return json.decode(await rootBundle.loadString(path));
  }
}
