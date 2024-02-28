import 'dart:developer';

import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/test_asset_loaders.dart';

void main() {
  group('ExtraAssetLoaders', () {
    test('should work normal if no extraAssetLoaders is provided', () async {
      final EasyLocalizationController controller = EasyLocalizationController(
        forceLocale: const Locale('en'),
        path: 'path/en.json',
        supportedLocales: const [Locale('en')],
        useOnlyLangCode: true,
        useFallbackTranslations: false,
        saveLocale: false,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        assetLoader: const ImmutableJsonAssetLoader(),
        extraAssetLoaders: null,
      );

      var result = await controller.loadTranslationData(const Locale('en'));

      expect(result, {'test': 'test'});
      expect(result.entries.length, 1);
    });

    test('load assets from external loader and merge with asset loader',
        () async {
      final EasyLocalizationController controller = EasyLocalizationController(
        forceLocale: const Locale('en'),
        path: 'path/en.json',
        supportedLocales: const [Locale('en')],
        useOnlyLangCode: true,
        useFallbackTranslations: false,
        saveLocale: false,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        assetLoader: const ImmutableJsonAssetLoader(),
        extraAssetLoaders: [const ExternalAssetLoader()],
      );

      final Map<String, dynamic> result =
          await controller.loadTranslationData(const Locale('en'));

      expect(result, {
        'test': 'test',
        'package_value_01': 'package_value_01',
        'package_value_02': 'package_value_02',
        'package_value_03': 'package_value_03',
      });
      expect(result.entries.length, 4);
    });

    test(
        'load assets from external loader with nested translations and merge with asset loader',
        () async {
      final EasyLocalizationController controller = EasyLocalizationController(
        forceLocale: const Locale('en'),
        path: 'path/en.json',
        supportedLocales: const [Locale('en')],
        useOnlyLangCode: true,
        useFallbackTranslations: false,
        saveLocale: false,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        assetLoader: const ImmutableJsonAssetLoader(),
        extraAssetLoaders: [const NestedAssetLoader()],
      );

      final Map<String, dynamic> result =
          await controller.loadTranslationData(const Locale('en'));

      expect(result, {
        'test': 'test',
        'nested': {
          'super': {
            'duper': {
              'nested': 'nested.super.duper.nested',
            }
          }
        },
      });
      expect(result.entries.length, 2);
    });

    test(
        'load assets from external loader and merge duplicates with asset loader',
        () async {
      final EasyLocalizationController controller = EasyLocalizationController(
        forceLocale: const Locale('en'),
        path: 'path/en.json',
        supportedLocales: const [Locale('en')],
        useOnlyLangCode: true,
        useFallbackTranslations: false,
        saveLocale: false,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        assetLoader: const ImmutableJsonAssetLoader(),
        extraAssetLoaders: [const ImmutableJsonAssetLoader()],
      );

      final Map<String, dynamic> result =
          await controller.loadTranslationData(const Locale('en'));

      expect(result, {'test': 'test'});
      expect(result.entries.length, 1);
    });
  });
}
