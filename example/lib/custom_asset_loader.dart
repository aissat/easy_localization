import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

//
//
//
//
class JsonAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) =>
      Future.value({});
}

//
//
//
//
class FileAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = File(path);
    return json.decode(await file.readAsString());
  }
}

//
//
//
//
class NetworkAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    try {
      return http
          .get(path)
          .then((response) => json.decode(response.body.toString()));
    } catch (e) {
      //Catch network exceptions
      debugPrint(e.toString());
      return Future.value();
    }
  }
}

// asset loader to be used when doing integration tests
// default AssetLoader suffers from this issue
// https://github.com/flutter/flutter/issues/44182
class TestsAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final byteData = await rootBundle.load(path);
    return json.decode(utf8.decode(byteData.buffer.asUint8List()));
  }
}

//
// load example/resources/langs/langs.csv
//
class CsvAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final csv = await rootBundle.loadString(path);
    final converter = CsvToListConverter();
    final val = converter.convert(csv);
    return _mappingData(locale, val);
  }

  Map<String, String> _mappingData(Locale locale, List<List<dynamic>> table) {
    var languageIndex = table.first.indexOf(locale.languageCode);
    var translations = <String, String>{};
    for (var i = 1; i < table.length; i++) {
      translations.addAll({table[i][0]: table[i][languageIndex]});
    }
    return translations;
  }
}
