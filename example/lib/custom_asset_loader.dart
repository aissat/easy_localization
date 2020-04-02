import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

//
//
//
//
class JsonAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String string) => Future.value({});

  @override
  Future localeExists(String localePath) => Future.value();
}

//
//
//
//
class FileAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String localePath) async {
    File file = File(localePath);
    return json.decode(await file.readAsString());
  }

  @override
  Future localeExists(String localePath) async => File(localePath).exists();
}

//
//
//
//
class NetworkAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String localePath) async {
    try{
      return http
          .get(localePath)
          .then((response) => json.decode(response.body.toString()));
    }catch (e){
      //Catch network exceptions
      debugPrint(e.toString());
      return Future.value();
    }
  }

  @override
  Future localeExists(String localePath) => Future.value();
}

// asset loader to be used when doing integration tests
// default AssetLoader suffers from this issue
// https://github.com/flutter/flutter/issues/44182
class TestsAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String localePath) async {
    final ByteData byteData = await rootBundle.load(localePath);
    return json.decode(utf8.decode(byteData.buffer.asUint8List()));
  }

  @override
  Future localeExists(String localePath) =>
      rootBundle.load(localePath);
}
