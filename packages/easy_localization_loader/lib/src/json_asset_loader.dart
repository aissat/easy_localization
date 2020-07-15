import 'dart:ui';

import 'asset_loader.dart';

//
//
//
//
class JsonAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) =>
      Future.value({});
}
