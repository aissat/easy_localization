import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
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
    return '$basePath/${localeToString(locale, separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    log('Load asset from $path', name: 'Easy Localization');
    return json.decode(await rootBundle.loadString(localePath));
  }
}
