import 'package:flutter/widgets.dart';
import 'localization.dart';

class EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final Locale locale;
  final String path;
  final String loadPath;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  EasyLocalizationDelegate({
    @required this.locale,
    this.path,
    this.loadPath,
    this.useOnlyLangCode = false,
  });

  @override
  bool isSupported(Locale locale) => locale != null;

  @override
  Future<Localization> load(Locale value) async {
    await Localization.load(value,
        path: path, loadPath: loadPath, useOnlyLangCode: useOnlyLangCode);

    return Localization.instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
