import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale,this.path);

  final Locale locale;
  final String path;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Map<String, String> _sentences;

  Future<bool> load() async {
    String data = await rootBundle
        .loadString('$path/${this.locale.languageCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value.toString();
    });

    return true;
  }

  String trans(String key) {
    return this._sentences[key];
  }
}

class EasylocalizationDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  final Locale locale;
  final String path;

  EasylocalizationDelegate({@required this.locale ,@required this.path});

  @override
  bool isSupported(Locale locale) => locale != null;


  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale, path);
    await localizations.load();
    print("Load ${locale.languageCode}");
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}
