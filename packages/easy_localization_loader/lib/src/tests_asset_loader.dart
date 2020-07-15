import 'dart:convert';

import 'dart:ui';

import 'package:flutter/services.dart';

import 'asset_loader.dart';

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
