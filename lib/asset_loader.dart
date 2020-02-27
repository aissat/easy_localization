import 'package:flutter/services.dart';

abstract class AssetLoader {
  const AssetLoader();
  Future<String> load(String localePath);
}

//
//
//
// default used is RootBundleAssetLoader which uses flutter's assetloader
class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  @override
  Future<String> load(String localePath) async {
    return rootBundle.loadString(localePath);
  }
}
