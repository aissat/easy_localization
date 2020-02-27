import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/localization.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/test_asset_loaders.dart';

void main() {
  group('localization', () {
    test('is a localization object', () {
      expect(Localization.instance, isInstanceOf<Localization>());
    });
    test('is a singleton', () {
      expect(Localization.instance, Localization.instance);
    });

    test('is a localization object', () {
      expect(Localization.instance, isInstanceOf<Localization>());
    });

    test('load() succeeds', () async {
      expect(
          await Localization.load(
            Locale('en'),
            path: null,
            useOnlyLangCode: true,
            assetLoader: StringAssetLoader(),
          ),
          true);
    });

    test('load() correctly sets locale path', () async {
      expect(
          await Localization.load(
            Locale('en'),
            path: "path",
            useOnlyLangCode: true,
            assetLoader: StringAssetLoader(),
          ),
          true);

      expect(Localization.instance.tr("path"), "path/en.json");
    });

    test('load() respects useOnlyLangCode', () async {
      expect(
          await Localization.load(
            Locale('en', 'us'),
            path: "path",
            useOnlyLangCode: true,
            assetLoader: StringAssetLoader(),
          ),
          true);

      expect(Localization.instance.tr("path"), "path/en.json");

      expect(
          await Localization.load(
            Locale('en', 'us'),
            path: "path",
            useOnlyLangCode: false,
            assetLoader: StringAssetLoader(),
          ),
          true);
      expect(Localization.instance.tr("path"), "path/en-us.json");
    });

    group('tr', () {
      setUpAll(() async {
        await Localization.load(Locale('en'),
            path: null,
            useOnlyLangCode: true,
            assetLoader: StringAssetLoader());
      });
      test('finds and returns resource', () {
        expect(Localization.instance.tr("test"), "test");
      });

      test('returns missing resource as provided', () {
        expect(Localization.instance.tr("test_missing"), "test_missing");
      });

      test('returns resource and replaces argument', () {
        expect(
          Localization.instance.tr("test_replace_one", args: ['one']),
          "test replace one",
        );
      });

      test('returns resource and replaces argument sequentially', () {
        expect(
          Localization.instance.tr("test_replace_two", args: ['one', 'two']),
          "test replace one two",
        );
      });

      test(
          'should raise exception if provided arguments length is different from the count of {} in the resource',
          () {
        // @TODO
      });

      test('gender returns the correct resource', () {
        expect(
          Localization.instance.tr("gender", gender: "male"),
          "Hi man ;)",
        );
        expect(
          Localization.instance.tr("gender", gender: "female"),
          "Hello girl :)",
        );
      });

      test('gender returns the correct resource and replaces args', () {
        expect(
          Localization.instance
              .tr("gender_and_replace", gender: "male", args: ["one"]),
          "Hi one man ;)",
        );
        expect(
          Localization.instance
              .tr("gender_and_replace", gender: "female", args: ["one"]),
          "Hello one girl :)",
        );
      });
    });

    group('plural', () {
      setUpAll(() async {
        await Localization.load(Locale('en-US'),
            path: null,
            useOnlyLangCode: true,
            assetLoader: StringAssetLoader());
      });

      test('zero', () {
        expect(Localization.instance.plural("day", 0), "0 days");
      });

      test('one', () {
        expect(Localization.instance.plural("day", 1), "1 day");
      });
      test('two', () {
        expect(Localization.instance.plural("day", 2), "2 days");
      });

      test('few', () {
        // @TODO not sure how this works
      });

      test('many', () {
        // @TODO not sure how this works
      });

      test('other', () {
        expect(Localization.instance.plural("day", 3), "3 other days");
      });

      test('with number format', () {
        expect(
            Localization.instance
                .plural("day", 3, format: NumberFormat.currency()),
            "USD3.00 other days");
      });
    });

    group('extensions', () {
      setUpAll(() async {
        await Localization.load(Locale('en'),
            path: null,
            useOnlyLangCode: true,
            assetLoader: StringAssetLoader());
      });
      group('string', () {
        test('tr', () {
          expect("test".tr(), "test");
        });

        test('plural', () {
          expect("day".plural(0), "0 days");
        });
      });
    });
  });
}
