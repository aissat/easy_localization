import 'package:shared_preferences/shared_preferences.dart';

/// Interface for persisting locale data.
abstract class IEasyLocalizationStorage {
  /// Initializes the storage.
  Future<void> init();

  /// Retrieves the string value for [key], or `null` if not found.
  Future<String?> getValue(String key);

  /// Persists [value] for [key].
  Future<void> setValue(String key, String value);

  /// Removes the value for [key].
  Future<void> removeValue(String key);

  /// Closes the storage and releases resources.
  Future<void> close();
}

/// Default implementation backed by `SharedPreferences`.
class SharedPreferencesStorage implements IEasyLocalizationStorage {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<String?> getValue(String key) async =>
      _prefs?.getString(key);

  @override
  Future<void> setValue(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  @override
  Future<void> removeValue(String key) async {
    await _prefs?.remove(key);
  }

  @override
  Future<void> close() async {
    _prefs = null;
  }
}

/// In-memory storage for testing or ephemeral use.
class InMemoryStorage implements IEasyLocalizationStorage {
  final _store = <String, String>{};

  @override
  Future<void> init() async {}

  @override
  Future<String?> getValue(String key) async => _store[key];

  @override
  Future<void> setValue(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> removeValue(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> close() async {
    _store.clear();
  }
}
