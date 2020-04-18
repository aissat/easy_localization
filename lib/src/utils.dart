part of 'easy_localization_app.dart';

Locale localeFromString(String localeString) {
  final localeList = localeString.split('_');
  switch (localeList.length) {
    case 2:
      return Locale(localeList.first, localeList.last);
    case 3:
      return Locale.fromSubtags(
          languageCode: localeList.first,
          scriptCode: localeList[1],
          countryCode: localeList.last);
    default:
      return Locale(localeList.first);
  }
}

String localeToString(Locale locale, {String separator = '_'}) {
  return locale.toString().split('_').join(separator);
}
