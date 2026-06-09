import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

void main() {
  group('EasyLocalizationCompat', () {
    test('withConfig creates EasyLocalization', () {
      final widget = EasyLocalizationCompat.withConfig(
        child: const Placeholder(),
      );

      expect(widget, isA<EasyLocalization>());
    });

    test('withConfig respects useOnlyLangCode', () {
      final widget = EasyLocalizationCompat.withConfig(
        child: const Placeholder(),
        useOnlyLangCode: true,
        fallbackLocale: const Locale('fr', 'FR'),
      );

      expect(widget, isA<EasyLocalization>());
    });

    test('migrateAssetLoader creates RootBundleAssetLoader', () {
      final loader = EasyLocalizationCompat.migrateAssetLoader(
        type: AssetLoaderType.rootBundle,
        path: 'assets/translations',
      );
      expect(loader, isA<RootBundleAssetLoader>());

      final rootBundleLoader = loader as RootBundleAssetLoader;
      expect(rootBundleLoader.useOnlyLangCode, isFalse);
    });

    test('migrateAssetLoader uses default path when not specified', () {
      final loader = EasyLocalizationCompat.migrateAssetLoader(
        type: AssetLoaderType.rootBundle,
      );
      expect(loader, isA<RootBundleAssetLoader>());
    });

    test('migrateAssetLoader throws for unimplemented types', () {
      expect(
        () => EasyLocalizationCompat.migrateAssetLoader(
          type: AssetLoaderType.file,
        ),
        throwsUnimplementedError,
      );
      expect(
        () => EasyLocalizationCompat.migrateAssetLoader(
          type: AssetLoaderType.network,
        ),
        throwsUnimplementedError,
      );
      expect(
        () => EasyLocalizationCompat.migrateAssetLoader(
          type: AssetLoaderType.custom,
        ),
        throwsArgumentError,
      );
    });
  });
}
