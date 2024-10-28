import 'dart:ui';

abstract class EasyLocalizationStorage {
  Future<int?> getVersion();
  Future<void> setVersion({int? value});

  Future<Locale?> getLocale();
  Future<void> setLocale({Locale? value});
}

extension XEasyLocalizationStorage on EasyLocalizationStorage {
  Future reset() {
    return Future.value([
      setVersion(value: null),
      setLocale(value: null),
    ]);
  }
}
