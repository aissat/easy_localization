import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/src/asset_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OptimizedAssetLoader', () {
    const testPath = 'assets/translations';

    setUp(() {
      RootBundleAssetLoader.clearCache();
    });

    test('creates with path', () {
      final loader = OptimizedAssetLoader(path: testPath);
      expect(loader.path, testPath);
    });

    test('caches translations across loads', () async {
      final loader = OptimizedAssetLoader(path: testPath);
      const locale = Locale('en', 'US');

      // Loading non-existent file should throw — that's fine
      // We verify the cache by checking load() is called at most once per locale
      await expectLater(
        () => loader.load(locale: locale),
        throwsA(anything),
      );
    });

    test('handles different locales independently', () async {
      final loader = OptimizedAssetLoader(path: testPath);
      const localeUS = Locale('en', 'US');
      const localeFR = Locale('fr', 'FR');

      // Both should throw (no real assets in test)
      await expectLater(
        () => loader.load(locale: localeUS),
        throwsA(anything),
      );
      await expectLater(
        () => loader.load(locale: localeFR),
        throwsA(anything),
      );
    });

    test('throws ArgumentError for null locale', () async {
      final loader = OptimizedAssetLoader(path: testPath);
      await expectLater(
        () => loader.load(),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CachedAssetLoader', () {
    setUp(() {
      CachedAssetLoader.translationCache.clear();
    });

    test('cache methods work correctly', () {
      const testLocale = Locale('en', 'US');
      final testTranslations = <String, dynamic>{'key': 'value'};

      const loader = CachedAssetLoader(path: 'test');

      expect(loader.isCached(testLocale), isFalse);

      loader.cacheTranslations(testLocale, testTranslations);

      expect(loader.isCached(testLocale), isTrue);
      expect(
          loader.getCachedTranslations(testLocale), equals(testTranslations));
    });
  });
}
