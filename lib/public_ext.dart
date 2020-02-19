import 'localization.dart';
import 'package:flutter/widgets.dart';

extension TranslateExtension on Text {
  Text tr({List<String> args, String gender}) =>
      Text(Localization.instance.tr(this.data, args: args, gender: gender));
  Text plural(dynamic value) =>
      Text(Localization.instance.plural(this.data, value));
}
