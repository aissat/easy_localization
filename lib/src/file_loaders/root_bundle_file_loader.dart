import 'package:easy_localization/src/file_loaders/file_loader.dart';
import 'package:flutter/services.dart';

/// File loader implementation for Flutter applications using rootBundle
class RootBundleFileLoader implements FileLoader {
  const RootBundleFileLoader();

  @override
  Future<String> loadString(String path) async {
    return rootBundle.loadString(path);
  }
}
