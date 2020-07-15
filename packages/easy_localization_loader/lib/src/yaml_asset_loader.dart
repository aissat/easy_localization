import 'dart:developer';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import 'asset_loader.dart';

//Loader for multiple yaml files
class YamlAssetLoader extends AssetLoader {
  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${localeToString(locale, separator: "-")}.yaml';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    log('easy localization loader: load yaml file $localePath');
    YamlMap yaml = loadYaml(await rootBundle.loadString(localePath));
    return convertYamlMapToMap(yaml);
  }
}

//Loader for single yaml file
class YamlSingleAssetLoader extends AssetLoader {
  Map yamlData;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (yamlData == null) {
      log('easy localization loader: load yaml file $path');
      yamlData =
          convertYamlMapToMap(loadYaml(await rootBundle.loadString(path)));
    } else {
      log('easy localization loader: Yaml already loaded, read cache');
    }
    return yamlData[locale.toString()];
  }
}

/// Convert YamlMap to Map
Map<String, dynamic> convertYamlMapToMap(YamlMap yamlMap) {
  final map = <String, dynamic>{};

  for (final entry in yamlMap.entries) {
    if (entry.value is YamlMap || entry.value is Map) {
      map[entry.key.toString()] = convertYamlMapToMap(entry.value);
    } else {
      map[entry.key.toString()] = entry.value.toString();
    }
  }
  return map;
}
