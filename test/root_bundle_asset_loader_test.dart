import 'package:easy_localization/src/asset_loader.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('RootBundleAssetLoader', () {
    const path = 'i18n';
    const locale = Locale('en');
    late RootBundleAssetLoader assetLoader;

    setUp(() async {
      assetLoader = const RootBundleAssetLoader(path: path);
      await assetLoader.load(locale: locale);
    });

    test('getLocalePath returns the correct path', () async {
      const expectedPath = '$path/en.json';
      var result = assetLoader.getLocalePath(locale);

      expect(result, expectedPath);
    });

    test('load throws an error when the locale is null', () {
      assetLoader = const RootBundleAssetLoader(path: path);
      expect(() => assetLoader.load(locale: null), throwsArgumentError);
    });
  });
}
