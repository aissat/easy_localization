import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/services.dart';

abstract class AssetLoader {
  const AssetLoader();
  Future<Map<String, dynamic>> load(String path, Locale locale);
}

//
//
//
// default used is RootBundleAssetLoader which uses flutter's assetloader
class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  String getLocalePath(String basePath, Locale locale) {
    final _codeLang = locale.languageCode;
    final _codeCoun = locale.countryCode;
    final localePath = '$basePath/$_codeLang';
    return locale.countryCode == null
        ? '$localePath.json'
        : '$localePath-$_codeCoun.json';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    log('easy localization: Load asset from $path');
    return json.decode(await rootBundle.loadString(localePath));
  }
}
