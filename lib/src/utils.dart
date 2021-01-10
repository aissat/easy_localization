part of 'easy_localization_app.dart';

/// Convert string locale [localeString] to [Locale]
Locale localeFromString(String localeString) {
  final localeList = localeString.split('_');
  switch (localeList.length) {
    case 2:
      return Locale(localeList.first, localeList.last);
    case 3:
      return Locale.fromSubtags(
          languageCode: localeList.first, scriptCode: localeList[1], countryCode: localeList.last);
    default:
      return Locale(localeList.first);
  }
}

/// Convert [locale] to Srting with custom [separator]
String localeToString(Locale locale, {String separator = '_'}) {
  return locale.toString().split('_').join(separator);
}
