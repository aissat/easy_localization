import 'dart:ui';

import 'package:easy_localization_storage/easy_localization_storage.dart';
import 'package:easy_localization_helper/easy_localization_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EasyLocalizationSharedPreferencesStorage extends EasyLocalizationStorage {
  EasyLocalizationSharedPreferencesStorage(
    SharedPreferences store, {
    this.version = 1,
    this.storagePrefix = 'easy_localization.locale',
  }) {
    _store = store;
    versionKey = '$storagePrefix.__v';
    valueKey = '$storagePrefix._v';
  }
  late SharedPreferences _store;

  // TODO: create migrate method by version
  final int version;
  final String storagePrefix;
  late final String versionKey;
  late final String valueKey;

  @override
  Future<int?> getVersion() async {
    int? value;
    try {
      value = _store.getInt(versionKey);
    } catch (_) {}
    return value;
  }

  @override
  Future<void> setVersion({int? value}) async {
    try {
      if (value == null) {
        _store.remove(versionKey);
      } else {
        _store.setInt(versionKey, value);
      }
    } catch (_) {}
  }

  @override
  Future<Locale?> getLocale() async {
    Locale? value;
    try {
      final raw = _store.getString(valueKey);
      if (raw == null) {
        return null;
      }
      return raw.toLocale();
    } catch (_) {}
    return value;
  }

  @override
  Future<void> setLocale({Locale? value}) async {
    try {
      if (value == null) {
        _store.remove(valueKey);
      } else {
        _store.setString(valueKey, value.toString());
      }
    } catch (_) {}
  }
}
