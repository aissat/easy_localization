import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'utils/test_asset_loaders.dart';

var printLog = [];
overridePrint(testFn()) => () {
      var spec = new ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        printLog.add(msg);
      });
      return Zone.current.fork(specification: spec).run(testFn);
    };

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
            path: "path",
            useOnlyLangCode: true,
            assetLoader: JsonAssetLoader(),
          ),
          true);
    });

    test('load() Failed assertion', () async {
      try {
        await Localization.load(
          null,
          path: null,
          useOnlyLangCode: true,
          assetLoader: JsonAssetLoader(),
        );
      } on AssertionError catch (e) {
        // throw  AssertionError("Expected ArgumentError");
        expect(e, isAssertionError);
      }
    });

    test('load() correctly sets locale path', () async {
      expect(
          await Localization.load(
            Locale('en'),
            path: "path",
            useOnlyLangCode: true,
            assetLoader: JsonAssetLoader(),
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
            assetLoader: JsonAssetLoader(),
          ),
          true);

      expect(Localization.instance.tr("path"), "path/en.json");

      expect(
          await Localization.load(
            Locale('en', 'us'),
            path: "path",
            useOnlyLangCode: false,
            assetLoader: JsonAssetLoader(),
          ),
          true);
      expect(Localization.instance.tr("path"), "path/en-us.json");
    });

    group('tr', () {
      setUpAll(() async {
        await Localization.load(Locale('en'),
            path: "path",
            useOnlyLangCode: true,
            assetLoader: JsonAssetLoader());
      });
      test('finds and returns resource', () {
        expect(Localization.instance.tr("test"), "test");
      });

      test('can resolve resource in any nest level', () {
        expect(
          Localization.instance.tr("nested.super.duper.nested"),
          "nested.super.duper.nested",
        );
      });
      test('can resolve resource that has a key with dots', () {
        expect(
          Localization.instance.tr("nested.but.not.nested"),
          "nested but not nested",
        );
      });

      test('returns missing resource as provided', () {
        expect(Localization.instance.tr("test_missing"), "test_missing");
      });

      test('reports missing resource', overridePrint(() {
        printLog = [];
        expect(Localization.instance.tr("test_missing"), "test_missing");
        expect(printLog.first,
            '[easy_localization] Missing message: "test_missing" for locale: "en", using key as fallback.');
      }));

      test('returns resource and replaces argument', () {
        expect(
          Localization.instance.tr("test_replace_one", args: ['one']),
          "test replace one",
        );
      });
      test('returns resource and replaces argument in any nest level', () {
        expect(
          Localization.instance
              .tr("nested.super.duper.nested_with_arg", args: ['what a nest']),
          "nested.super.duper.nested_with_arg what a nest",
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
            path: "path",
            useOnlyLangCode: true,
            assetLoader: JsonAssetLoader());
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
            path: "path",
            useOnlyLangCode: true,
            assetLoader: JsonAssetLoader());
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

    group('extensions', () {
      setUpAll(() async {
        await Localization.load(Locale('en'),
            path: "path",
            useOnlyLangCode: true,
            assetLoader: JsonAssetLoader());
      });
      group('string', () {
        test('tr', () {
          expect(tr("test"), "test");
        });
        test('plural', () {
          expect(plural("day", 0), "0 days");
        });
      });
    });
  });
}
