import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'translations.dart';

class Localization {
  Translations _translations;
  Locale _locale;
  set translations(val) => _translations = val;

  String path;
  bool useOnlyLangCode;
  final RegExp _replaceArgRegex = RegExp(r'{}');

  Localization();

  static Localization _instance;
  static Localization get instance => _instance ?? (_instance = Localization());
  static Localization of(BuildContext context) =>
      Localizations.of<Localization>(context, Localization);

  static bool load(Locale locale, {Translations translations}) {
    instance._locale = locale;
    instance._translations = translations;
    return translations == null ? false : true;
  }

  String tr(String key, {List<String> args, String gender}) {
    if (gender != null) return trGender(key, gender, args: args);
    return _replaceArgs(_resolve(key), args);
  }

  String trGender(
    String key,
    String gender, {
    List<String> args,
  }) =>
      _replaceArgs(
        _gender(key, gender: gender),
        args,
      );

  String _replaceArgs(String res, List<String> args) {
    if (args == null || args.isEmpty) return res;
    args.forEach((String str) => res = res.replaceFirst(_replaceArgRegex, str));
    return res;
  }

  String plural(String key, dynamic value, {NumberFormat format}) {
    final res = Intl.pluralLogic(value,
        zero: _resolve(key + '.zero'),
        one: _resolve(key + '.one'),
        two: _resolve(key + '.two'),
        few: _resolve(key + '.few'),
        many: _resolve(key + '.many'),
        other: _resolve(key + '.other') ?? key,
        locale: _locale.languageCode);
    return _replaceArgs(res, [
      format == null ? '$value' : format.format(value),
    ]);
  }

  String _gender(String key, {String gender}) => Intl.genderLogic(
        gender,
        female: _resolve(key + '.female'),
        male: _resolve(key + '.male'),
        other: _resolve(key + '.male'),
        locale: _locale.languageCode,
      );

  String _resolve(String key) {
    final resource = _translations.get(key);
    if (resource == null) {
      print(
          '[easy_localization] Missing message : Not found this Key ["$key"] .');
      return key;
    }
    return resource;
  }
}
