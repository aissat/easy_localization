import 'dart:developer';

import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/test_asset_loaders.dart';

void main() {
  // Setup
  var r = EasyLocalizationController(
      forceLocale: const Locale('fb'),
      supportedLocales: [const Locale('en'), const Locale('ar'), const Locale('ru'), const Locale('fb')],
      fallbackLocale: const Locale('fb'),
      path: 'path',
      useOnlyLangCode: true,
      useFallbackTranslations: true,
      onLoadError: (FlutterError e) {
        log(e.toString());
      },
      saveLocale: false,
      assetLoader: const JsonAssetLoader());

  setUpAll(() async {
    await r.loadTranslations();
  });

  group('English plural', () {
    test('English one (no ignorePluralRules)', () async {
      Localization.load(
        const Locale('en'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: false,
      );

      expect(Localization.instance.plural('hat', 1), 'one hat');
    });
    test('English all cases (no ignorePluralRules)', () async {
      Localization.load(
        const Locale('en'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: false,
      );

      expect(Localization.instance.plural('hat', 1), 'one hat');
      expect(Localization.instance.plural('hat', 0), 'other hats');
      expect(Localization.instance.plural('hat', 2), 'other hats');
      expect(Localization.instance.plural('hat', 3), 'other hats');
      expect(Localization.instance.plural('hat', 4), 'other hats');
      expect(Localization.instance.plural('hat', 11), 'other hats');
      expect(Localization.instance.plural('hat', 101), 'other hats');
      expect(Localization.instance.plural('hat', 111), 'other hats');
    });
    test('English all cases (with ignorePluralRules) | using `_pluralCaseFallback`', () async {
      Localization.load(
        const Locale('en'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: true,
      );

      expect(Localization.instance.plural('hat', 0), 'no hats');
      expect(Localization.instance.plural('hat', 1), 'one hat');
      expect(Localization.instance.plural('hat', 2), 'two hats');
      expect(Localization.instance.plural('hat', 3), 'other hats');
      expect(Localization.instance.plural('hat', 4), 'other hats');
      expect(Localization.instance.plural('hat', 11), 'other hats');
      expect(Localization.instance.plural('hat', 101), 'other hats');
      expect(Localization.instance.plural('hat', 111), 'other hats');
    });
  });

  group('Russian plural', () {
    test('Russian one', () async {
      Localization.load(
        const Locale('ru'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
      );
      expect(Localization.instance.plural('hat', 1), 'one hat');
    });
    test('Russian few (no ignorePluralRules)', () async {
      Localization.load(
        const Locale('ru'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: false,
      );
      expect(Localization.instance.plural('hat', 2), 'few hats');
      expect(Localization.instance.plural('hat', 3), 'few hats');
    });
    test('Russian few (with ignorePluralRules)', () async {
      Localization.load(
        const Locale('ru'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: true,
      );
      expect(Localization.instance.plural('hat', 2), 'two hats');
      expect(Localization.instance.plural('hat', 3), 'other hats');
    });
    test('Russian many (no ignorePluralRules)', () async {
      Localization.load(
        const Locale('ru'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: false,
      );
      expect(Localization.instance.plural('hat', 0), 'many hats');
      expect(Localization.instance.plural('hat', 5), 'many hats');
      expect(Localization.instance.plural('hat', 101), 'one hat');
    });
    test('Russian many (with ignorePluralRules)', () async {
      Localization.load(
        const Locale('ru'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: true,
      );
      expect(Localization.instance.plural('hat', 0), 'no hats');
      expect(Localization.instance.plural('hat', 5), 'other hats');
      expect(Localization.instance.plural('hat', 101), 'other hats');
    });
  });

  group("Arabic plural", () {
    test('Arabic few (no ignorePluralRules)', () async {
      Localization.load(
        const Locale('ar'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: false,
      );
      expect(Localization.instance.plural('hat', 2), 'two hats');
      expect(Localization.instance.plural('hat', 10), 'few hats');
      expect(Localization.instance.plural('hat', 110), 'few hats');
    });
    test('Arabic few (with ignorePluralRules)', () async {
      Localization.load(
        const Locale('ar'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: true,
      );
      expect(Localization.instance.plural('hat', 2), 'two hats');
      expect(Localization.instance.plural('hat', 3), 'other hats');
      expect(Localization.instance.plural('hat', 10), 'other hats');
      expect(Localization.instance.plural('hat', 110), 'other hats');
    });
    test('Arabic many (no ignorePluralRules)', () async {
      Localization.load(
        const Locale('ar'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: false,
      );

      expect(Localization.instance.plural('hat', 11), 'many hats');
      expect(Localization.instance.plural('hat', 111), 'many hats');
    });
    test('Arabic many (with ignorePluralRules)', () async {
      Localization.load(
        const Locale('ar'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: true,
      );
      expect(Localization.instance.plural('hat', 10), 'other hats');
      expect(Localization.instance.plural('hat', 11), 'other hats');
      expect(Localization.instance.plural('hat', 111), 'other hats');
    });
    test('Arabic all cases (no ignorePluralRules)', () async {
      Localization.load(
        const Locale('ar'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: false,
      );

      expect(Localization.instance.plural('hat', 0), 'no hats');
      expect(Localization.instance.plural('hat', 1), 'one hat');
      expect(Localization.instance.plural('hat', 2), 'two hats');
      expect(Localization.instance.plural('hat', 3), 'few hats');
      expect(Localization.instance.plural('hat', 4), 'few hats');
      expect(Localization.instance.plural('hat', 11), 'many hats');
      expect(Localization.instance.plural('hat', 101), 'other hats');
      expect(Localization.instance.plural('hat', 111), 'many hats');
      expect(Localization.instance.plural('hat', 103), 'few hats');
    });
    test('Arabic all cases (with ignorePluralRules) | using `_pluralCaseFallback`', () async {
      Localization.load(
        const Locale('ar'),
        translations: r.translations,
        fallbackTranslations: r.fallbackTranslations,
        ignorePluralRules: true,
      );

      expect(Localization.instance.plural('hat', 0), 'no hats');
      expect(Localization.instance.plural('hat', 1), 'one hat');
      expect(Localization.instance.plural('hat', 2), 'two hats');
      expect(Localization.instance.plural('hat', 3), 'other hats');
      expect(Localization.instance.plural('hat', 4), 'other hats');
      expect(Localization.instance.plural('hat', 11), 'other hats');
      expect(Localization.instance.plural('hat', 101), 'other hats');
      expect(Localization.instance.plural('hat', 111), 'other hats');
      expect(Localization.instance.plural('hat', 103), 'other hats');
    });
  });
}
