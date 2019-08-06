import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  Future<bool> load() async {
    String data;

    final SharedPreferences _preferences =
        await SharedPreferences.getInstance();

    var _codeLang = _preferences.getString('codeL');
    var _codeCoun = _preferences.getString('codeC');

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

  String tr(String key, {List<String> args}) {
    String res = this._resolve(key, this._sentences);
    if (args != null) {
      args.forEach((String str) {
        res = res.replaceFirst(RegExp(r'{}'), str);
      });
    }
    return res;
  }

  String plural(String key, dynamic value) {
    String res = '';
    if (value == 0) {
      res = this._sentences[key]['zero'];
    } else if (value == 1) {
      res = this._sentences[key]['one'];
    } else {
      res = this._sentences[key]['other'];
    }
    return res.replaceFirst(RegExp(r'{}'), '$value');
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

class EasylocaLizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  final Locale locale;
  final String path;
  final String loadPath;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  EasylocaLizationDelegate({
    @required this.locale,
    this.path,
    this.loadPath,
    this.useOnlyLangCode = false,
  });

  @override
  bool isSupported(Locale locale) => locale != null;

  @override
  Future<AppLocalizations> load(Locale value) async {
    final SharedPreferences _preferences =
        await SharedPreferences.getInstance();
    var _codeLang = _preferences.getString('codeL');
    var _codeCoun = _preferences.getString('codeC');
    if (_codeLang == null || _codeCoun == null) {
      //value = Locale(this.locale.languageCode, this.locale.countryCode);
      await _preferences.setString('codeC', value.countryCode);
      await _preferences.setString('codeL', value.languageCode);
    } else
      value = Locale(_codeLang, _codeCoun);
    AppLocalizations localizations = AppLocalizations(value,
        path: path, loadPath: loadPath, useOnlyLangCode: useOnlyLangCode);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}
