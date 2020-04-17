import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:easy_localization/easy_localization.dart';

import 'csv_parser.dart';

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
  CSVParser csvParser;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    if (csvParser == null) {
      csvParser = CSVParser(await rootBundle.loadString(path));
    } else {
      log('easy localization: CSV parser already loaded');
    }
    return csvParser.getLanguageMap(locale.toString());
  }
}
