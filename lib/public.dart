import 'localization.dart';

String tr(String key, {List<String> args, String gender}) {
  return Localization.instance.tr(key, args: args, gender: gender);
}

String plural(String key, dynamic value) {
  return Localization.instance.plural(key, value);
}
