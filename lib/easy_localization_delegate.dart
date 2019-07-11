import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this.path);

  Locale locale;
  final String path;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, dynamic> _sentences;

  Future<bool> load() async {
    String data;
    if (this.locale.languageCode == null || this.locale.countryCode == null) {
      this.locale = Locale("en", "US");
    }
    data = await rootBundle.loadString(
        '$path/${this.locale.languageCode}-${this.locale.countryCode}.json');
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

  EasylocaLizationDelegate({@required this.locale, @required this.path});

  @override
  bool isSupported(Locale locale) => locale != null;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale, path);
    await localizations.load();
    // print("Load ${locale.languageCode}");
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}
