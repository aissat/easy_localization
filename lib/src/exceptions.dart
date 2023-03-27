class LocalizationNotFoundException implements Exception {
  const LocalizationNotFoundException();

  @override
  String toString() => 'Localization not found for current context';
}
