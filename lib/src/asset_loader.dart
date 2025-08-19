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
  // Place inside class RootBundleAssetLoader
  static const int _maxLinkedDepth = 32;

  const RootBundleAssetLoader();

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  String _getLinkedLocalePath(String basePath, String filePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}/$filePath';
  }

  Future<Map<String, dynamic>> _getLinkedTranslationFileDataFromBaseJson(
    String basePath,
    Locale locale,
    Map<String, dynamic> baseJson, {
    required Set<String> visited,
    int depth = 0,
  }) async {
    if (depth > _maxLinkedDepth) {
      throw StateError('Maximum linked files depth ($_maxLinkedDepth) exceeded for $locale at $basePath.');
    }

    final Map<String, dynamic> fullJson = Map<String, dynamic>.from(baseJson);

    for (final entry in baseJson.entries) {
      final key = entry.key;
      var value = entry.value;

      if (value is String && value.startsWith(':/')) {
        final rawPath = value.substring(2).trim();
        final linkedAssetPath = _getLinkedLocalePath(basePath, rawPath, locale);

        if (visited.contains(linkedAssetPath)) {
          throw StateError('Cyclic linked files detected at "$linkedAssetPath" (key: "$key").');
        }

        final Map<String, dynamic> linkedJson =
            json.decode(await rootBundle.loadString(linkedAssetPath)) as Map<String, dynamic>;

        visited.add(linkedAssetPath);
        try {
          final resolved = await _getLinkedTranslationFileDataFromBaseJson(
            basePath,
            locale,
            linkedJson,
            visited: visited,
            depth: depth + 1,
          );
          fullJson[key] = resolved;
        } catch (e) {
          throw StateError(
            'Error resolving linked file "$linkedAssetPath" for key "$key": $e',
          );
        }
      }

      if (value is Map<String, dynamic>) {
        fullJson[key] = await _getLinkedTranslationFileDataFromBaseJson(
          basePath,
          locale,
          value,
          visited: visited,
          depth: depth + 1,
        );
      }
    }

    return fullJson;
  }

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    EasyLocalization.logger.debug('Load asset from $path');

    Map<String, dynamic> baseJson = json.decode(await rootBundle.loadString(localePath));
    return await _getLinkedTranslationFileDataFromBaseJson(
      path,
      locale,
      baseJson,
      visited: <String>{},
    );
  }
}
