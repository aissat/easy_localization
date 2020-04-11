import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'utils.dart';

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
    return  '$basePath/${localeToString(locale, separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    log('easy localization: Load asset from $path');
    return json.decode(await rootBundle.loadString(localePath));
  }
}
