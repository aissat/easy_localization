import 'package:intl/intl.dart';
import 'localization.dart';

String tr(String key, {List<String> args, String gender}) {
  return Localization.instance.tr(key, args: args, gender: gender);
}

String plural(String key, dynamic value, {NumberFormat format}) {
  return Localization.instance.plural(key, value, format: format);
}

