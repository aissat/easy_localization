part of 'easy_localization_app.dart';

/// Convert string locale [localeString] to [Locale]
@Deprecated('Deprecated on Easy Localization 3.0')
Locale localeFromString(String localeString) {
  final localeList = localeString.split('_');
  switch (localeList.length) {
    case 2:
      return Locale(localeList.first, localeList.last);
    case 3:
      return Locale.fromSubtags(
        languageCode: localeList.first,
        scriptCode: localeList[1],
        countryCode: localeList.last,
      );
    default:
      return Locale(localeList.first);
  }
}

/// Convert [locale] to Srting with custom [separator]
@Deprecated('Deprecated on Easy Localization 3.0')
String localeToString(Locale locale, {String separator = '_'}) {
  return locale.toString().split('_').join(separator);
}

/// [Easy Localization] locale helper
extension LocaleToStringHelper on Locale {
  /// Convert [locale] to String with custom separator
  String toStringWithSeparator({String separator = '_'}) {
    return toString().split('_').join(separator);
  }
}

/// [Easy Localization] string locale helper
extension StringToLocaleHelper on String {
  /// Convert string to [Locale] object
  Locale toLocale({String separator = '_'}) {
    final localeList = split(separator);
    switch (localeList.length) {
      case 2:
        return Locale(localeList.first, localeList.last);
      case 3:
        return Locale.fromSubtags(
          languageCode: localeList.first,
          scriptCode: localeList[1],
          countryCode: localeList.last,
        );
      default:
        return Locale(localeList.first);
    }
  }
}
