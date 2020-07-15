import 'dart:developer';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;

import 'asset_loader.dart';

//Loader for multiple xml files
class XmlAssetLoader extends AssetLoader {
  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${localeToString(locale, separator: "-")}.xml';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    log('easy localization loader: load xml file $localePath');
    var doc = xml.parse(await rootBundle.loadString(localePath));
    doc.normalize();
    return convertXmlNodeToMap(doc.lastChild);
  }
}

//Loader for single xml file
class XmlSingleAssetLoader extends AssetLoader {
  Map xmlData;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (xmlData == null) {
      log('easy localization loader: load xml file $path');
      var doc = xml.parse(await rootBundle.loadString(path));
      doc.normalize();
      xmlData = convertXmlNodeToMap(doc.lastChild);
    } else {
      log('easy localization loader: Xml already loaded, read cache');
    }
    return xmlData[locale.toString()];
  }
}

/// Convert xmlNode to Map
Map<String, dynamic> convertXmlNodeToMap(xml.XmlNode xmlNode) {
  final map = <String, dynamic>{};

  for (final entry in xmlNode.children) {
    if (entry is xml.XmlElement) {
      switch (entry.children.length) {
        case 1:
          map[entry.name.toString()] = entry.text;
          break;
        case 0:
          print(entry.name.toString());
          map[entry.name.toString()] = null;
          break;
        default:
          map[entry.name.toString()] = convertXmlNodeToMap(entry);
      }
    }
  }
  return map;
}
