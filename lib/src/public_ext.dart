import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'public.dart' as ez;

extension TextTranslateExtension on Text {
  Text tr({BuildContext context,List<String> args, String gender}) =>
      Text(ez.tr(this.data,context: context, args: args, gender: gender),
          key: this.key,
          style: this.style,
          strutStyle: this.strutStyle,
          textAlign: this.textAlign,
          textDirection: this.textDirection,
          locale: this.locale,
          softWrap: this.softWrap,
          overflow: this.overflow,
          textScaleFactor: this.textScaleFactor,
          maxLines: this.maxLines,
          semanticsLabel: this.semanticsLabel,
          textWidthBasis: this.textWidthBasis);
  Text plural(dynamic value, {BuildContext context,NumberFormat format}) =>
      Text(ez.plural(this.data, value,context: context, format: format),
          key: this.key,
          style: this.style,
          strutStyle: this.strutStyle,
          textAlign: this.textAlign,
          textDirection: this.textDirection,
          locale: this.locale,
          softWrap: this.softWrap,
          overflow: this.overflow,
          textScaleFactor: this.textScaleFactor,
          maxLines: this.maxLines,
          semanticsLabel: this.semanticsLabel,
          textWidthBasis: this.textWidthBasis);
}

extension StringTranslateExtension on String {
  tr({List<String> args, String gender}) =>
      ez.tr(this, args: args, gender: gender);
  plural(dynamic value, {NumberFormat format}) =>
      ez.plural(this, value, format: format);
}
