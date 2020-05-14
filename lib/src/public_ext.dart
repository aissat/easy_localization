import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'easy_localization_app.dart';
import 'public.dart' as ez;

/// Text widget extension method for acces to [tr()] and [plural()]
/// Example : 
/// ```drat
/// Text('title').tr()
/// Text('day').plural(21)
/// ```
extension TextTranslateExtension on Text {
  Text tr(
          {BuildContext context,
          List<String> args,
          Map<String, String> namedArgs,
          String gender}) =>
      Text(
          ez.tr(data,
              context: context,
              args: args,
              namedArgs: namedArgs,
              gender: gender),
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis);

  Text plural(num value, {BuildContext context, NumberFormat format}) =>
      Text(ez.plural(data, value, context: context, format: format),
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis);
}

/// Strings extension method for acces to [tr()] and [plural()]
/// Example : 
/// ```drat
/// 'title'.tr()
/// 'day'.plural(21)
/// ```
extension StringTranslateExtension on String {
  String tr(
          {List<String> args, Map<String, String> namedArgs, String gender}) =>
      ez.tr(this, args: args, namedArgs: namedArgs, gender: gender);
  String plural(num value, {NumberFormat format}) =>
      ez.plural(this, value, format: format);
}

/// BuildContext extension method for acces to [locale], [supportedLocales], [fallbackLocale], [delegates] and [deleteSaveLocale()]
/// Example : 
/// ```drat
/// context.locale = Locale('en', 'US');
/// print(context.locale.toString());
///
/// context.deleteSaveLocale();
/// 
/// print(context.supportedLocales); // output: [en_US, ar_DZ, de_DE, ru_RU]
/// print(context.fallbackLocale);   // output: en_US
/// ```
extension BuildContextEasyLocalizationExtension on BuildContext {
  Locale get locale => EasyLocalization.of(this).locale;
  set locale(Locale val) => EasyLocalization.of(this).locale = val;

  List<Locale> get supportedLocales =>
      EasyLocalization.of(this).supportedLocales;

  Locale get fallbackLocale => EasyLocalization.of(this).fallbackLocale;

  // Locale get startLocale => EasyLocalization.of(this).startLocale;

  List<LocalizationsDelegate> get localizationDelegates =>
      EasyLocalization.of(this).delegates;

  /// Clears a saved locale from device storage
  void deleteSaveLocale() => EasyLocalization.of(this).deleteSaveLocale();
}
