import 'package:flutter/services.dart';

abstract class AssetLoader {
  const AssetLoader();
  Future<String> load(String localePath);
  Future<bool> localeExists(String localePath);
}

//
//
//
// default used is RootBundleAssetLoader which uses flutter's assetloader
class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  @override
  Future<String> load(String localePath) async =>
      rootBundle.loadString(localePath);

  @override
  Future<bool> localeExists(String localePath) =>
      rootBundle.load(localePath).then((v) => true).catchError((e) => false);
}
