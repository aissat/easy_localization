/// Interface for the EasyLocalization storage.
abstract class IEasyLocalizationStorage {
  /// Initializes the storage.
  Future<void> init();

  /// Retrieves the value associated with the given [key].
  ///
  /// Returns the value of type [T].
  T getValue<T>(String key);

  /// Sets the value associated with the given [key] to the specified [value].
  Future<void> setValue<T>(String key, T value);

  /// Removes the value associated with the given [key].
  Future<void> removeValue(String key);

  /// Closes the storage.
  Future<void> close();
}
