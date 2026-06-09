import 'package:flutter/material.dart';

class LocalizationNotFoundException implements Exception {
  const LocalizationNotFoundException();

  @override
  String toString() => 'Localization not found for current context';
}

class TranslationLoadException implements Exception {
  final Locale locale;
  final dynamic cause;
  const TranslationLoadException(this.locale, this.cause);

  @override
  String toString() => 'Failed to load translations for $locale: $cause';
}
