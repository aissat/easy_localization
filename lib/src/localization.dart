import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'translations.dart';

class Localization {
  Translations _translations, _fallbackTranslations;
  Locale _locale;

  String? path;
  bool? useOnlyLangCode;
  final RegExp _replaceArgRegex = RegExp(r'{}');
  final RegExp _linkKeyMatcher =
      RegExp(r'(?:@(?:\.[a-z]+)?:(?:[\w\-_|.]+|\([\w\-_|.]+\)))');
  final RegExp _linkKeyPrefixMatcher = RegExp(r'^@(?:\.([a-z]+))?:');
  final RegExp _bracketsMatcher = RegExp(r'[()]');
  final _modifiers = <String, String Function(String?)>{
    'upper': (String? val) => val!.toUpperCase(),
    'lower': (String? val) => val!.toLowerCase(),
    'capitalize': (String? val) => '${val![0].toUpperCase()}${val.substring(1)}'
  };

  Localization();

  static Localization? _instance;
  static Localization get instance => _instance ?? (_instance = Localization());
  static Localization? of(BuildContext context) =>
      Localizations.of<Localization>(context, Localization);

  static bool load(Locale locale, {Translations translations, Translations fallbackTranslations}) {
    instance._locale = locale;
    instance._translations = translations;
    instance._fallbackTranslations = fallbackTranslations;
    return translations == null ? false : true;
  }

  String? tr(String? key,
      {List<String>? args, Map<String, String>? namedArgs, String? gender}) {
    String? res;

    if (gender != null) {
      res = _gender(key!, gender: gender);
    } else {
      res = _resolve(key);
    }

    res = _replaceLinks(res!);

    res = _replaceNamedArgs(res, namedArgs);

    return _replaceArgs(res, args);
  }

  String _replaceLinks(String res, {bool logging = true}) {
    // TODO: add recursion detection and a resolve stack.
    final matches = _linkKeyMatcher.allMatches(res);
    var result = res;

    for (final match in matches) {
      final link = match[0]!;
      final linkPrefixMatches = _linkKeyPrefixMatcher.allMatches(link);
      final linkPrefix = linkPrefixMatches.first[0]!;
      final formatterName = linkPrefixMatches.first[1];

      // Remove the leading @:, @.case: and the brackets
      final linkPlaceholder =
          link.replaceAll(linkPrefix, '').replaceAll(_bracketsMatcher, '');

      var translated = _resolve(linkPlaceholder);

      if (formatterName != null) {
        if (_modifiers.containsKey(formatterName)) {
          translated = _modifiers[formatterName]!(translated);
        } else {
          if (logging) {
            EasyLocalization.logger.warning(
                'Undefined modifier $formatterName, available modifiers: ${_modifiers.keys.toString()}');
          }
        }
      }

      result =
          translated!.isEmpty ? result : result.replaceAll(link, translated);
    }

    return result;
  }

  String? _replaceArgs(String? res, List<String>? args) {
    if (args == null || args.isEmpty) return res;
    args.forEach((String str) => res = res!.replaceFirst(_replaceArgRegex, str));
    return res;
  }

  String _replaceNamedArgs(String res, Map<String, String>? args) {
    if (args == null || args.isEmpty) return res;
    args.forEach((String key, String value) =>
        res = res.replaceAll(RegExp('{$key}'), value));
    return res;
  }

  String? plural(String? key, num value,
      {List<String>? args, NumberFormat? format}) {
    final res = Intl.pluralLogic(value,
        zero: _resolvePlural(key, 'zero'),
        one: _resolvePlural(key, 'one'),
        two: _resolvePlural(key, 'two'),
        few: _resolvePlural(key, 'few'),
        many: _resolvePlural(key, 'many'),
        other: _resolvePlural(key, 'other'),
        locale: _locale.languageCode);
    return _replaceArgs(
        res, args ?? [format == null ? '$value' : format.format(value)]);
  }

  String? _gender(String key, {required String gender}) => Intl.genderLogic(
        gender,
        female: _resolve(key + '.female'),
        male: _resolve(key + '.male'),
        other: _resolve(key + '.other', logging: false),
        locale: _locale.languageCode,
      );

  String? _resolvePlural(String? key, String subKey) {
    final resource = _translations!.get('$key.$subKey');

    if (resource == null && subKey == 'other') {
      EasyLocalization.logger.error('Plural key [$key.$subKey] required');
      return '$key.$subKey';
    } else {
      return resource;
    }
  }

  String _resolve(String key, {bool logging = true}) {
    var resource = _translations.get(key);
    if (resource == null) {
      if (logging) EasyLocalization.logger.warning('Localization key [$key] not found');
      if (_fallbackTranslations == null) {
        return key;
      } else {
        resource = _fallbackTranslations.get(key);
        if (resource == null) {
          if (logging) EasyLocalization.logger.warning('Fallback localization key [$key] not found');
          return key;
        }
      }
    }
    return resource;
  }
}
