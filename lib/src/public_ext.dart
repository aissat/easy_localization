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
  /// {@macro tr}
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

  /// {@macro plural}
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
  /// {@macro tr}
  String tr(
          {List<String> args, Map<String, String> namedArgs, String gender}) =>
      ez.tr(this, args: args, namedArgs: namedArgs, gender: gender);

  /// {@macro plural}
  String plural(num value, {NumberFormat format}) =>
      ez.plural(this, value, format: format);
}

/// BuildContext extension method for acces to [locale], [supportedLocales], [fallbackLocale], [delegates] and [deleteSaveLocale()]
///
/// Example :
///
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
  /// Get current locale
  Locale get locale => EasyLocalization.of(this).locale;

  /// Change app locale
  set locale(Locale val) => EasyLocalization.of(this).locale = val;

  /// Get List of supported locales.
  List<Locale> get supportedLocales =>
      EasyLocalization.of(this).supportedLocales;

  /// Get fallback locale
  Locale get fallbackLocale => EasyLocalization.of(this).fallbackLocale;

  // Locale get startLocale => EasyLocalization.of(this).startLocale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  /// retrun
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get localizationDelegates =>
      EasyLocalization.of(this).delegates;

  /// Clears a saved locale from device storage
  void deleteSaveLocale() => EasyLocalization.of(this).deleteSaveLocale();
}
