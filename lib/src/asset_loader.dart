import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/file_loaders/io_file_loader.dart';
import 'package:flutter/services.dart';

/// abstract class used to building your Custom AssetLoader
/// Example:
/// ```
///class FileAssetLoader extends AssetLoader {
///  @override
///  Future<Map<String, dynamic>> load(String path, Locale locale) async {
///    final file = File(path);
///    return json.decode(await file.readAsString());
///  }
///}
/// ```
abstract class AssetLoader {
  // Place inside class RootBundleAssetLoader
  final LinkedFileResolver linkedFileResolver;

  const AssetLoader({required this.linkedFileResolver});

  Future<Map<String, dynamic>?> load(String path, Locale locale);
}

///
/// default used is RootBundleAssetLoader which uses flutter's assetloader
///
class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader({LinkedFileResolver? linkedFileResolver})
      : super(
            linkedFileResolver: linkedFileResolver ?? const JsonLinkedFileResolver(fileLoader: RootBundleFileLoader()));

  factory RootBundleAssetLoader.fromIOFile() {
    return const RootBundleAssetLoader(
      linkedFileResolver: JsonLinkedFileResolver(fileLoader: IOFileLoader()),
    );
  }

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    EasyLocalization.logger.debug('Load asset from $path');

    Map<String, dynamic> baseJson = json.decode(await linkedFileResolver.fileLoader.loadString(localePath));
    return await linkedFileResolver.resolveLinkedFiles(
      basePath: path,
      languageCode: locale.languageCode,
      countryCode: locale.countryCode,
      baseJson: baseJson,
    );
  }
}
