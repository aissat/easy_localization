import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flat/flat.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

//
//
//
//
class FlatJsonBundleAssetLoader extends AssetLoader {
  const FlatJsonBundleAssetLoader();
  @override
  Future<String> load(String localePath) async {
    String data = await rootBundle.loadString(localePath);
    return json.encode(flatten(json.decode(data)));
  }

  @override
  Future<bool> localeExists(String localePath) =>
      rootBundle.load(localePath).then((v) => true).catchError((e) => false);
}

//
//
//
//
class StringAssetLoader extends AssetLoader {
  @override
  Future<String> load(String string) => Future.value(string);

  @override
  Future<bool> localeExists(String localePath) => Future.value(true);
}

//
//
//
//
class FileAssetLoader extends AssetLoader {
  @override
  Future<String> load(String localePath) {
    File file = File(localePath);
    return file.readAsString();
  }

  @override
  Future<bool> localeExists(String localePath) => File(localePath).exists();
}

//
//
//
//
class NetworkAssetLoader extends AssetLoader {
  @override
  Future<String> load(String localePath) async {
    return http.get(localePath).then((response) => response.body.toString());
  }

  @override
  Future<bool> localeExists(String localePath) => Future.value(true);
}

// asset loader to be used when doing integration tests
// default AssetLoader suffers from this issue
// https://github.com/flutter/flutter/issues/44182
class TestsAssetLoader extends AssetLoader {
  @override
  Future<String> load(String localePath) async {
    final ByteData byteData = await rootBundle.load(localePath);
    return utf8.decode(byteData.buffer.asUint8List());
  }

  @override
  Future<bool> localeExists(String localePath) =>
      rootBundle.load(localePath).then((v) => true).catchError((e) => false);
}
