import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'localization.dart';

class AppLocalizations {
  AppLocalizations(
    this.locale, {
    this.path,
    this.loadPath,
    this.useOnlyLangCode = false,
  });

  Locale locale;
  final String path;
  final String loadPath;

  /// use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, dynamic> _sentences;

  Future<bool> load(Locale locale) async {
    String data;

    var _codeLang = locale.languageCode;
    var _codeCoun = locale.countryCode;

    this.locale = Locale(_codeLang, _codeCoun);

    var basePath = path != null ? path : loadPath;
    var localePath = '$basePath/$_codeLang';
    localePath += useOnlyLangCode ? '.json' : '-$_codeCoun.json';

    if (path != null) {
      data = await rootBundle.loadString(localePath);
    } else if (loadPath != null) {
      data = await http
          .get(localePath)
          .then((response) => response.body.toString());
    }

    Map<String, dynamic> _result = json.decode(data);

    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value;
    });
    Localization.load(_sentences, locale);
    return true;
  }
}

class EasyLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
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
  Future<AppLocalizations> load(Locale value) async {
    AppLocalizations localizations = AppLocalizations(value,
        path: path, loadPath: loadPath, useOnlyLangCode: useOnlyLangCode);
    await localizations.load(value);
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}
