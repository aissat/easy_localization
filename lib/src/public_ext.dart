import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'easy_localization_app.dart';
import 'public.dart' as ez;

/// Text widget extension method for access to [tr()] and [plural()]
/// Example :
/// ```drat
/// Text('title').tr()
/// Text('day').plural(21)
/// ```
extension TextTranslateExtension on Text {
  /// {@macro tr}
  Text tr(
          {List<String>? args,
          Map<String, String>? namedArgs,
          String? gender}) =>
      Text(
          ez.tr(
            data ?? '',
            args: args,
            namedArgs: namedArgs,
            gender: gender,
          ),
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
  Text plural(
    num value, {
    List<String>? args,
    NumberFormat? format,
  }) =>
      Text(
          ez.plural(
            data ?? '',
            value,
            args: args,
            format: format,
          ),
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

/// Strings extension method for access to [tr()] and [plural()]
/// Example :
/// ```drat
/// 'title'.tr()
/// 'day'.plural(21)
/// ```
extension StringTranslateExtension on String {
  /// {@macro tr}
  String tr({
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
  }) =>
      ez.tr(this, args: args, namedArgs: namedArgs, gender: gender);

  /// {@macro plural}
  String plural(
    num value, {
    List<String>? args,
    NumberFormat? format,
  }) =>
      ez.plural(this, value, args: args, format: format);
}

/// BuildContext extension method for access to [locale], [supportedLocales], [fallbackLocale], [delegates] and [deleteSaveLocale()]
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
  Locale get locale => EasyLocalization.of(this)!.locale;

  /// Change app locale
  Future<void> setLocale(Locale val) async =>
      EasyLocalization.of(this)!.setLocale(val);

  /// Old Change app locale
  @Deprecated(
      'This is the func used in the old version of EasyLocalization. The modern func is `setLocale(val)` . '
      'This feature was deprecated after v3.0.0')
  set locale(Locale val) => EasyLocalization.of(this)!.setLocale(val);

  /// Get List of supported locales.
  List<Locale> get supportedLocales =>
      EasyLocalization.of(this)!.supportedLocales;

  /// Get fallback locale
  Locale? get fallbackLocale => EasyLocalization.of(this)!.fallbackLocale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  /// return
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get localizationDelegates =>
      EasyLocalization.of(this)!.delegates;

  /// Clears a saved locale from device storage
  Future<void> deleteSaveLocale() =>
      EasyLocalization.of(this)!.deleteSaveLocale();

  /// Getting device locale from platform
  Locale get deviceLocale => EasyLocalization.of(this)!.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => EasyLocalization.of(this)!.resetLocale();
}
