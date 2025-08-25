import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Initialize the test environment
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();

  group('Asset Loader - Linked Translation Files', () {
    group('RootBundleAssetLoader with linked files', () {
      test('should load single linked file', () async {
        final controller = EasyLocalizationController(
          forceLocale: const Locale('en', 'linked'),
          path: 'i18n',
          supportedLocales: const [Locale('en', 'linked')],
          useOnlyLangCode: false,
          useFallbackTranslations: false,
          saveLocale: false,
          onLoadError: (FlutterError e) {
            log(e.toString());
          },
          assetLoader: RootBundleAssetLoader.fromIOFile(),
        );

        await controller.loadTranslations();
        final result = await controller.loadTranslationData(const Locale('en', 'linked'));

        expect(result['hello'], 'Hello');
        expect(result['app']['name'], 'Test App');
        expect(result['app']['errors']['not_found'], 'Resource not found');
        expect(result['app']['errors']['server_error'], 'Internal server error');
        expect(result['app']['errors']['invalid_input'], 'Invalid input provided');
      });

      test('should load multiple linked files', () async {
        final controller = EasyLocalizationController(
          forceLocale: const Locale('en', 'linked'),
          path: 'i18n',
          supportedLocales: const [Locale('en', 'linked')],
          useOnlyLangCode: false,
          useFallbackTranslations: false,
          saveLocale: false,
          onLoadError: (FlutterError e) {
            log(e.toString());
          },
          assetLoader: RootBundleAssetLoader.fromIOFile(),
        );

        await controller.loadTranslations();
        final result = await controller.loadTranslationData(const Locale('en', 'linked'));

        // Check validation linked file
        expect(result['validation']['required'], 'This field is required');
        expect(result['validation']['email'], 'Please enter a valid email address');
        expect(result['validation']['min_length'], 'Minimum length is {min} characters');

        // Check multiple references to same file work
        expect(result['multiple']['errors']['not_found'], 'Multiple resource not found');
        expect(result['multiple']['validation']['required'], 'Multiple field is required');
      });

      test('should load nested linked files', () async {
        final controller = EasyLocalizationController(
          forceLocale: const Locale('en', 'linked'),
          path: 'i18n',
          supportedLocales: const [Locale('en', 'linked')],
          useOnlyLangCode: false,
          useFallbackTranslations: false,
          saveLocale: false,
          onLoadError: (FlutterError e) {
            log(e.toString());
          },
          assetLoader: RootBundleAssetLoader.fromIOFile(),
        );

        await controller.loadTranslations();
        final result = await controller.loadTranslationData(const Locale('en', 'linked'));

        // Check nested folder structure
        expect(result['nested']['module']['messages']['welcome'], 'Welcome to our app');
        expect(result['nested']['module']['messages']['goodbye'], 'Thank you for using our app');
        expect(result['nested']['module']['messages']['info'], 'This is a nested message file');
      });

      test('should load deeply nested linked files', () async {
        final controller = EasyLocalizationController(
          forceLocale: const Locale('en', 'linked'),
          path: 'i18n',
          supportedLocales: const [Locale('en', 'linked')],
          useOnlyLangCode: false,
          useFallbackTranslations: false,
          saveLocale: false,
          onLoadError: (FlutterError e) {
            log(e.toString());
          },
          assetLoader: RootBundleAssetLoader.fromIOFile(),
        );

        await controller.loadTranslations();
        final result = await controller.loadTranslationData(const Locale('en', 'linked'));

        // Check deep nesting (file linking to another file)
        expect(result['deep_nested']['level1_value'], 'This is level 1');
        expect(result['deep_nested']['level2']['level2_value'], 'This is level 2');
        expect(result['deep_nested']['level2']['final_message'], 'Deep nesting works!');
      });

      test('should preserve original structure with linked files', () async {
        final controller = EasyLocalizationController(
          forceLocale: const Locale('en', 'linked'),
          path: 'i18n',
          supportedLocales: const [Locale('en', 'linked')],
          useOnlyLangCode: false,
          useFallbackTranslations: false,
          saveLocale: false,
          onLoadError: (FlutterError e) {
            log(e.toString());
          },
          assetLoader: RootBundleAssetLoader.fromIOFile(),
        );

        await controller.loadTranslations();
        final result = await controller.loadTranslationData(const Locale('en', 'linked'));

        // Verify that the original structure is preserved
        expect(result['test'], 'test_linked_en');
        expect(result['hello'], 'Hello');
        expect(result.containsKey('app'), true);
        expect(result['app'].containsKey('name'), true);
        expect(result['app'].containsKey('errors'), true);

        // The linked reference should be replaced with actual content
        expect(result['app']['errors'] is Map, true);
        expect(result['app']['errors'] is String, false);
      });
    });

    group('Error handling for linked files', () {
      test('should throw error for cyclic linked files', () async {
        final controller = EasyLocalizationController(
          forceLocale: const Locale('en', 'cyclic'),
          path: 'i18n',
          supportedLocales: const [Locale('en', 'cyclic')],
          useOnlyLangCode: false,
          useFallbackTranslations: false,
          saveLocale: false,
          onLoadError: (FlutterError e) {
            // Don't just log, rethrow the error so we can catch it in tests
            throw e;
          },
          assetLoader: RootBundleAssetLoader.fromIOFile(),
        );

        try {
          await controller.loadTranslations();
          fail('Expected StateError to be thrown');
        } catch (e) {
          expect(e, isA<FlutterError>());
          expect(e.toString(), contains('Cyclic linked files detected'));
        }
      });

      test('should throw error for missing linked file', () async {
        final controller = EasyLocalizationController(
          forceLocale: const Locale('en', 'missing'),
          path: 'i18n',
          supportedLocales: const [Locale('en', 'missing')],
          useOnlyLangCode: false,
          useFallbackTranslations: false,
          saveLocale: false,
          onLoadError: (FlutterError e) {
            // Don't just log, rethrow the error so we can catch it in tests
            throw e;
          },
          assetLoader: RootBundleAssetLoader.fromIOFile(),
        );

        try {
          await controller.loadTranslations();
          fail('Expected FlutterError to be thrown');
        } catch (e) {
          expect(e, isA<FlutterError>());
        }
      });
    });

    group('Edge cases for linked files', () {
      test('should work with useOnlyLangCode setting', () async {
        // Test with a simple locale using useOnlyLangCode
        final controller = EasyLocalizationController(
          forceLocale: const Locale('en'),
          path: 'i18n',
          supportedLocales: const [Locale('en')],
          useOnlyLangCode: true,
          useFallbackTranslations: false,
          saveLocale: false,
          onLoadError: (FlutterError e) {
            log(e.toString());
          },
          assetLoader: RootBundleAssetLoader.fromIOFile(),
        );

        await controller.loadTranslations();
        final result = await controller.loadTranslationData(const Locale('en'));

        // Should successfully load the en.json file
        expect(result['test'], 'test_en');
        expect(result.containsKey('hats'), true);
        expect((result['hats'] as Map<String, dynamic>).containsKey('zero'), true);
      });
    });
  });
}
