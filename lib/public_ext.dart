import 'localization.dart';
import 'package:flutter/widgets.dart';

extension TranslateExtension on Text {
  Text tr({List<String> args, String gender}) =>
      Text(Localization.instance.tr(this.data, args: args, gender: gender),
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
  Text plural(dynamic value) =>
      Text(Localization.instance.plural(this.data, value),
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

extension LocalizationPretty on String {
  tr({List<String> args, String gender}) => Localization.instance.tr(this, args: args, gender: gender);
  plural(dynamic value) => Localization.instance.plural(this, value);
}
