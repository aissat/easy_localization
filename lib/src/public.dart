import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'localization.dart';

/// {@template tr}
/// Main function for translate your language keys
/// [key] Localization key
/// [BuildContext] The location in the tree where this widget builds
/// [args] List of localized strings. Replaces {} left to right
/// [namedArgs] Map of localized strings. Replaces the name keys {key_name} according to its name
/// [gender] Gender switcher. Changes the localized string based on gender string
///
/// Example:
///
/// ```json
/// {
///    "msg":"{} are written in the {} language",
///    "msg_named":"Easy localization are written in the {lang} language",
///    "msg_mixed":"{} are written in the {lang} language",
///    "gender":{
///       "male":"Hi man ;) {}",
///       "female":"Hello girl :) {}",
///       "other":"Hello {}"
///    }
/// }
/// ```
/// ```dart
/// Text('msg').tr(args: ['Easy localization', 'Dart']), // args
/// Text('msg_named').tr(namedArgs: {'lang': 'Dart'}),   // namedArgs
/// Text('msg_mixed').tr(args: ['Easy localization'], namedArgs: {'lang': 'Dart'}), // args and namedArgs
/// Text('gender').tr(gender: _gender ? "female" : "male"), // gender
/// ```
/// {@endtemplate}
String tr(
  String key, {
  List<String>? args,
  Map<String, String>? namedArgs,
  String? gender,
}) {
  return Localization.instance
      .tr(key, args: args, namedArgs: namedArgs, gender: gender);
}

/// {@template plural}
/// function translate with pluralization
/// [key] Localization key
/// [value] Number value for pluralization
/// [BuildContext] The location in the tree where this widget builds
/// [format] Formats a numeric value using a [NumberFormat](https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html) class
///
/// Example:
///```json
/// {
///   "day": {
///     "zero":"{} дней",
///     "one": "{} день",
///     "two": "{} дня",
///     "few": "{} дня",
///     "many": "{} дней",
///     "other": "{} дней"
///   },
///   "money": {
///     "zero": "You not have money",
///     "one": "You have {} dollar",
///     "many": "You have {} dollars",
///     "other": "You have {} dollars"
///   },
///   "money_args": {
///     "zero": "{} has no money",
///     "one": "{} has {} dollar",
///     "many": "{} has {} dollars",
///     "other": "{} has {} dollars"
///   }
/// }
/// ```
///
///```dart
/// Text('money').plural(1000000, format: NumberFormat.compact(locale: context.locale.toString())) // output: You have 1M dollars
/// print('day'.plural(21)); // output: 21 день
/// var money = plural('money', 10.23) // output: You have 10.23 dollars
/// var money = plural('money_args', 10.23, args: ['John', '10.23'])  // output: John has 10.23 dollars
/// ```
/// {@endtemplate}
String plural(
  String key,
  num value, {
  List<String>? args,
  NumberFormat? format,
}) {
  return Localization.instance.plural(key, value, args: args, format: format);
}
