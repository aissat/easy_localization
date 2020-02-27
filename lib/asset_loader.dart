import 'package:flutter/services.dart';

abstract class AssetLoader {
  const AssetLoader();
  Future<String> load(String localePath);
}

class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  @override
  Future<String> load(String localePath) async {
    return rootBundle.loadString(localePath);
  }
}
