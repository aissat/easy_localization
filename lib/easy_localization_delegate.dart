import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

    return true;
  }

  String tr(String key, {List<String> args, String gender}) {
    String res;

    if (gender != null) {
      res = _gender(key, gender: gender);
    }

    if (res == null) {
      res = this._resolve(key, this._sentences);
    }

    if (args != null) {
      args.forEach((String str) {
        res = res.replaceFirst(RegExp(r'{}'), str);
      });
    }

    return res;
  }

  String plural(String key, dynamic value) {
    final res = Intl.pluralLogic(value,
        zero: this._resolve(key + '.zero', this._sentences),
        one: this._resolve(key + '.one', this._sentences),
        two: this._resolve(key + '.two', this._sentences),
        few: this._resolve(key + '.few', this._sentences),
        many: this._resolve(key + '.many', this._sentences),
        other: this._resolve(key + '.other', this._sentences),
        locale: locale.languageCode);
    return res.replaceFirst(RegExp(r'{}'), '$value');
  }

  String _gender(String key, {String gender}) {
    final res = Intl.genderLogic(gender,
        female: this._resolve(key + '.female', this._sentences),
        male: this._resolve(key + '.male', this._sentences),
        other: this._resolve(key + '.male', this._sentences),
        locale: locale.languageCode);
    return res;
  }

  String _resolve(String path, dynamic obj) {
    List<String> keys = path.split('.');

    if (keys.length > 1) {
      for (int index = 0; index <= keys.length; index++) {
        if (obj.containsKey(keys[index]) && obj[keys[index]] is! String) {
          return _resolve(
              keys.sublist(index + 1, keys.length).join('.'), obj[keys[index]]);
        }

        return obj[path] ?? path;
      }
    }

    return obj[path] ?? path;
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
