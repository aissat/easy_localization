import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'translations.dart';

class Localization {
  Translations? _translations;
  late Locale _locale;
  set translations(val) => _translations = val;

  late String path;
  late bool useOnlyLangCode;
  final RegExp _replaceArgRegex = RegExp(r'{}');

  Localization();

  static Localization? _instance;
  static Localization get instance => _instance ?? (_instance = Localization());
  static Localization? of(BuildContext context) =>
      Localizations.of<Localization>(context, Localization);

  static bool load(Locale locale, {Translations? translations}) {
    instance._locale = locale;
    instance._translations = translations;
    return translations == null ? false : true;
  }

  String tr(String key,
      {List<String>? args, Map<String, String>? namedArgs, String? gender}) {
    String res;

    if (gender != null) {
      res = _gender(key, gender: gender);
    } else {
      res = _resolve(key);
    }

    res = _replaceNamedArgs(res, namedArgs);

    return _replaceArgs(res, args);
  }

  String _replaceArgs(String res, List<String>? args) {
    if (args == null || args.isEmpty) return res;
    args.forEach((String str) => res = res.replaceFirst(_replaceArgRegex, str));
    return res;
  }

  String _replaceNamedArgs(String res, Map<String, String>? args) {
    if (args == null || args.isEmpty) return res;
    args.forEach((String key, String value) =>
        res = res.replaceAll(RegExp('{$key}'), value));
    return res;
  }

  String plural(String key, num value, {NumberFormat? format}) {
    final res = Intl.pluralLogic(value,
        zero: _resolvePlural(key, 'zero'),
        one: _resolvePlural(key, 'one'),
        two: _resolvePlural(key, 'two'),
        few: _resolvePlural(key, 'few'),
        many: _resolvePlural(key, 'many'),
        other: _resolvePlural(key, 'other'),
        locale: _locale.languageCode);
    return _replaceArgs(res, [
      format == null ? '$value' : format.format(value),
    ]);
  }

  String _gender(String key, {required String gender}) => Intl.genderLogic(
        gender,
        female: _resolve(key + '.female'),
        male: _resolve(key + '.male'),
        other: _resolve(key + '.other', logging: false),
        locale: _locale.languageCode,
      );

  String _resolvePlural(String key, String subKey) {
    final resource = _translations!.get('$key.$subKey');

    if (resource == null && subKey == 'other') {
      printError('Plural key [$key.$subKey] required');
      return '$key.$subKey';
    } else {
      return resource!;
    }
  }

  String _resolve(String key, {bool logging = true}) {
    final resource = _translations!.get(key);
    if (resource == null) {
      if (logging) printWarning('Localization key [$key] not found');
      return key;
    }
    return resource;
  }
}
