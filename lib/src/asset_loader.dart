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
}

///
/// default used is RootBundleAssetLoader which uses flutter's assetloader
///
class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  String _getLinkedLocalePath(String basePath, String filePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}/$filePath';
  }

  Future<Map<String, dynamic>> _getLinkedTranslationFileDataFromBaseJson(
      String basePath, Locale locale, Map<String, dynamic> baseJson,
      {List<String> fileLoaded = const []}) async {
    Map<String, dynamic> fullJson = {};

    for (var entry in baseJson.entries) {
      var key = entry.key;
      var value = entry.value;

      if (value is String && value.startsWith(':/')) {
        String filePath = value.substring(2);

        if (fileLoaded.contains(filePath)) {
          throw Exception('Circular reference detected: $filePath is loaded multiple times');
        }

        fileLoaded.add(filePath);
        value = json.decode(await rootBundle.loadString(_getLinkedLocalePath(basePath, filePath, locale)));
      }

      if (value is Map<String, dynamic>) {
        fullJson[key] =
            await _getLinkedTranslationFileDataFromBaseJson(basePath, locale, value, fileLoaded: fileLoaded);
        continue;
      }

      fullJson[key] = value;
    }

    return fullJson;
  }

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    EasyLocalization.logger.debug('Load asset from $path');

    Map<String, dynamic> baseJson = json.decode(await rootBundle.loadString(localePath));
    return _getLinkedTranslationFileDataFromBaseJson(path, locale, baseJson);
  }
}
