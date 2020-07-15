import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'asset_loader.dart';

//
//
//
//
class FileAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final file = File(path);
    log('easy localization loader: load file $path');
    return json.decode(await file.readAsString());
  }
}
