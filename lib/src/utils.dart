part of 'easy_localization_app.dart';

/// convert string [localeString] returns the locale.
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

/// convert [locale] to Srting at matches of [separator] and returns a string representing the locale.
String localeToString(Locale locale, {String separator = '_'}) {
  return locale.toString().split('_').join(separator);
}

/// Emit a [info] log event
void printInfo(String info) {
  print('\u001b[32mEasy Localization: $info\u001b[0m');
}

/// Emit a [warning] log event
void printWarning(String warning) {
  print('\u001B[34m[WARNING] Easy Localization: $warning\u001b[0m');
}

/// Emit a [error] log event
void printError(String error) {
  print('\u001b[31m[ERROR] Easy Localization: $error\u001b[0m');
}
