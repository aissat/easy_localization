import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'localization.dart';

String tr(String key,
    {BuildContext context, List<String> args, String gender}) {
  return context == null
      ? Localization.instance.tr(key, args: args, gender: gender)
      : Localization.of(context).tr(key, args: args, gender: gender);
}

String plural(String key, dynamic value,
    {BuildContext context, NumberFormat format}) {
  return context == null
      ? Localization.instance.plural(key, value, format: format)
      : Localization.of(context).plural(key, value, format: format);
}
