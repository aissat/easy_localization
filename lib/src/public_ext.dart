import 'package:easy_localization/src/exceptions.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'easy_localization_app.dart';
import 'public.dart' as ez;

/// Text widget extension method for access to [tr()] and [plural()]
/// Example :
/// ```dart
/// Text('title').tr()
/// Text('day').plural(21)
/// ```
extension TextTranslateExtension on Text {
  /// {@macro tr}
  Text tr(
          {List<String>? args,
          BuildContext? context,
          Map<String, String>? namedArgs,
          String? gender}) =>
      Text(
          ez.tr(
            data ?? '',
            context: context,
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
    BuildContext? context,
    List<String>? args,
    Map<String, String>? namedArgs,
    String? name,
    NumberFormat? format,
  }) =>
      Text(
          ez.plural(
            data ?? '',
            value,
            context: context,
            args: args,
            namedArgs: namedArgs,
            name: name,
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
/// ```dart
/// 'title'.tr()
/// 'day'.plural(21)
/// ```
extension StringTranslateExtension on String {
  /// {@macro tr}
  String tr({
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
    BuildContext? context,
  }) =>
      ez.tr(this,
          context: context, args: args, namedArgs: namedArgs, gender: gender);

  bool trExists() => ez.trExists(this);

  /// {@macro plural}
  String plural(
    num value, {
    List<String>? args,
    BuildContext? context,
    Map<String, String>? namedArgs,
    String? name,
    NumberFormat? format,
  }) =>
      ez.plural(
        this,
        value,
        context: context,
        args: args,
        namedArgs: namedArgs,
        name: name,
        format: format,
      );
}

/// BuildContext extension method for access to [locale], [supportedLocales], [fallbackLocale], [delegates] and [deleteSaveLocale()]
///
/// Example :
///
/// ```dart
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

  /// An extension method for translating your language keys.
  /// Subscribes the widget on current [Localization] that provided from context.
  /// Throws exception if [Localization] was not found.
  ///
  /// [key] Localization key
  /// [args] List of localized strings. Replaces {} left to right
  /// [namedArgs] Map of localized strings. Replaces the name keys {key_name} according to its name
  /// [gender] Gender switcher. Changes the localized string based on gender string
  ///
  /// Example:
  ///
  /// ```json
  /// {
  ///    "msg":"{} are written in the {} language",
  ///    "msg_named":"Easy localization is written in the {lang} language",
  ///    "msg_mixed":"{} are written in the {lang} language",
  ///    "gender":{
  ///       "male":"Hi man ;) {}",
  ///       "female":"Hello girl :) {}",
  ///       "other":"Hello {}"
  ///    }
  /// }
  /// ```
  /// ```dart
  /// Text(context.tr('msg', args: ['Easy localization', 'Dart']), // args
  /// Text(context.tr('msg_named', namedArgs: {'lang': 'Dart'}),   // namedArgs
  /// Text(context.tr('msg_mixed', args: ['Easy localization'], namedArgs: {'lang': 'Dart'}), // args and namedArgs
  /// Text(context.tr('gender', gender: _gender ? "female" : "male"), // gender
  /// ```
  String tr(
    String key, {
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
  }) {
    final localization = Localization.of(this);

    if (localization == null) {
      throw const LocalizationNotFoundException();
    }

    return localization.tr(
      key,
      args: args,
      namedArgs: namedArgs,
      gender: gender,
    );
  }

  String plural(
    String key,
    num number, {
    List<String>? args,
    Map<String, String>? namedArgs,
    String? name,
    NumberFormat? format,
  }) {
    final localization = Localization.of(this);

    if (localization == null) {
      throw const LocalizationNotFoundException();
    }

    return localization.plural(
      key,
      number,
      args: args,
      namedArgs: namedArgs,
      name: name,
      format: format,
    );
  }
}
