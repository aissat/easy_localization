import 'dart:ui';

import 'easy_localization_storage.dart';

/// An in-memory implementation of [EasyLocalizationStorage].
/// Useful for testing.
class EasyLocalizationInMemoryStorage implements EasyLocalizationStorage {
  int? _version = 1;
  Locale? _locale;

  @override
  Future<int?> getVersion() async => _version;

  @override
  Future<void> setVersion({int? value}) async {
    if (value != null && value < 0) {
      throw ArgumentError('Value must be null or non-negative');
    }
    _version = value;
  }

  @override
  Future<Locale?> getLocale() async => _locale;

  @override
  Future<void> setLocale({Locale? value}) async => _locale = value;
}
