import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/test_asset_loaders.dart';

void main() {
    group('language-specific-plurals', () {
      var r = EasyLocalizationController(
          forceLocale: const Locale('fb'),
          supportedLocales: [const Locale('en'), const Locale('ru'), const Locale('fb')],
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

      test('english one', () async {
        Localization.load(const Locale('en'),
            translations: r.translations,
            fallbackTranslations: r.fallbackTranslations);
        expect(Localization.instance.plural('hat', 1), 'one hat');
      }); 
      test('english other', () async {
        Localization.load(const Locale('en'),
            translations: r.translations,
            fallbackTranslations: r.fallbackTranslations);
        expect(Localization.instance.plural('hat', 2), 'other hats');
        expect(Localization.instance.plural('hat', 0), 'other hats');
        expect(Localization.instance.plural('hat', 3), 'other hats');
      }); 
      test('russian one', () async {
        Localization.load(const Locale('ru'),
            translations: r.translations,
            fallbackTranslations: r.fallbackTranslations);
        expect(Localization.instance.plural('hat', 1), 'one hat');
      }); 
      test('russian few', () async {
        Localization.load(const Locale('ru'),
            translations: r.translations,
            fallbackTranslations: r.fallbackTranslations);
        expect(Localization.instance.plural('hat', 2), 'few hats');
        expect(Localization.instance.plural('hat', 3), 'few hats');
      });
      test('russian many', () async {
        Localization.load(const Locale('ru'),
            translations: r.translations,
            fallbackTranslations: r.fallbackTranslations);
        expect(Localization.instance.plural('hat', 0), 'many hats');
        expect(Localization.instance.plural('hat', 5), 'many hats');
      });
    });
}