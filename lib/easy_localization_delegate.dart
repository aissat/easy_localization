import 'package:easy_localization/asset_loader.dart';
import 'package:flutter/widgets.dart';
import 'localization.dart';

class EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final Locale locale;
  final String path;
  final String loadPath;
  final AssetLoader assetLoader;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  EasyLocalizationDelegate(
      {@required this.locale,
      this.path,
      this.loadPath,
      this.useOnlyLangCode = false,
      this.assetLoader = const RootBundleAssetLoader()});

  @override
  bool isSupported(Locale locale) => locale != null;

  @override
  Future<Localization> load(Locale value) async {
    await Localization.load(value,
        path: path, useOnlyLangCode: useOnlyLangCode, assetLoader: assetLoader);

    return Localization.instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
