import 'dart:ui';

Locale localeFromString(String localeString) {  
  final List<String> localeList = localeString.split("_");
  switch (localeList.length) {
    case 2:
      return Locale(localeList.first, localeList.last);         
    case 3:
      return Locale.fromSubtags(languageCode: localeList.first, scriptCode: localeList[1], countryCode: localeList.last); 
    default:
      return Locale(localeList.first);
  }
}

String localeToString(Locale locale, {String separator = '_'}){
  return locale.toString().split('_').join(separator);  
}