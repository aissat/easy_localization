import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'easy_localization_app.dart';
import 'public.dart' as ez;

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

  Text plural(dynamic value, {BuildContext context, NumberFormat format}) =>
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

extension StringTranslateExtension on String {
  String tr({List<String> args, String gender}) =>
      ez.tr(this, args: args, gender: gender);
  String plural(dynamic value, {NumberFormat format}) =>
      ez.plural(this, value, format: format);
}

//BuildContext extension method for acces to Easy Localization
extension BuildContextEasyLocalizationExtension on BuildContext {
  Locale get locale => EasyLocalization.of(this).locale;
  set locale(Locale val) => EasyLocalization.of(this).locale = val;

  List<Locale> get supportedLocales =>
      EasyLocalization.of(this).supportedLocales;

  Locale get fallbackLocale => EasyLocalization.of(this).fallbackLocale;

  // Locale get startLocale => EasyLocalization.of(this).startLocale;

  List<LocalizationsDelegate> get localizationDelegates =>
      EasyLocalization.of(this).delegates;

  deleteSaveLocale() => EasyLocalization.of(this).deleteSaveLocale();
}
