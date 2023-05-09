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

var printLog = [];

dynamic overridePrint(Function() testFn) => () {
      var spec = ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        printLog.add(msg);
      });
      return Zone.current.fork(specification: spec).run(testFn);
    };

void main() {
  group('localization', () {
    var r1 = EasyLocalizationController(
        forceLocale: const Locale('en'),
        path: 'path/en.json',
        supportedLocales: const [Locale('en')],
        useOnlyLangCode: true,
        useFallbackTranslations: false,
        saveLocale: false,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        assetLoader: const JsonAssetLoader());
    var r2 = EasyLocalizationController(
        forceLocale: const Locale('en', 'us'),
        supportedLocales: const [Locale('en', 'us')],
        path: 'path/en-us.json',
        useOnlyLangCode: false,
        useFallbackTranslations: false,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        saveLocale: false,
        assetLoader: const JsonAssetLoader());
    setUpAll(() async {
      EasyLocalization.logger.enableLevels = <LevelMessages>[
        LevelMessages.error,
        LevelMessages.warning,
      ];

      await r1.loadTranslations();
      await r2.loadTranslations();
      Localization.load(const Locale('en'), translations: r1.translations);
    });
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
          Localization.load(const Locale('en'), translations: r1.translations),
          true);
    });

    test('load() with fallback succeeds', () async {
      expect(
          Localization.load(const Locale('en'),
              translations: r1.translations,
              fallbackTranslations: r2.translations),
          true);
    });

    test('merge fallbackLocale with locale without country code succeeds',
        () async {
      await EasyLocalizationController(
        forceLocale: const Locale('es', 'AR'),
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('es', 'AR')
        ],
        path: 'path/en-us.json',
        useOnlyLangCode: false,
        useFallbackTranslations: true,
        fallbackLocale: const Locale('en'),
        onLoadError: (FlutterError e) {
          throw e;
        },
        saveLocale: false,
        assetLoader: const ImmutableJsonAssetLoader(),
      ).loadTranslations();
    });

    test('localeFromString() succeeds', () async {
      expect(const Locale('ar'), 'ar'.toLocale());
      expect(const Locale('ar', 'DZ'), 'ar_DZ'.toLocale());
      expect(const Locale.fromSubtags(languageCode: 'ar', scriptCode: 'Arab'),
          'ar_Arab'.toLocale());
      expect(
          const Locale.fromSubtags(
              languageCode: 'ar', scriptCode: 'Arab', countryCode: 'DZ'),
          'ar_Arab_DZ'.toLocale());
    });

    test('load() Failed assertion', () async {
      try {
        Localization.load(const Locale('en'), translations: null);
      } on AssertionError catch (e) {
        // throw  AssertionError('Expected ArgumentError');
        expect(e, isAssertionError);
      }
    });

    test('load() correctly sets locale path', () async {
      expect(
          Localization.load(const Locale('en'), translations: r1.translations),
          true);
      expect(Localization.instance.tr('path'), 'path/en.json');
    });

    test('load() respects useOnlyLangCode', () async {
      expect(
          Localization.load(const Locale('en'), translations: r1.translations),
          true);
      expect(Localization.instance.tr('path'), 'path/en.json');

      expect(
          Localization.load(const Locale('en', 'us'),
              translations: r2.translations),
          true);
      expect(Localization.instance.tr('path'), 'path/en-us.json');
    });

    test('controller loads saved locale', () async {
      SharedPreferences.setMockInitialValues({
        'locale': 'en',
      });
      await EasyLocalization.ensureInitialized();
      final controller = EasyLocalizationController(
        supportedLocales: const [Locale('en'), Locale('fb')],
        fallbackLocale: const Locale('fb'),
        path: 'path',
        useOnlyLangCode: true,
        useFallbackTranslations: true,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        saveLocale: true,
        assetLoader: const JsonAssetLoader(),
      );
      expect(controller.locale, const Locale('en'));

      SharedPreferences.setMockInitialValues({});
    });

    /// E.g. if user saved a locale that was removed in a later version
    test('controller loads fallback if saved locale is not supported',
        () async {
      SharedPreferences.setMockInitialValues({
        'locale': 'de',
      });
      await EasyLocalization.ensureInitialized();
      final controller = EasyLocalizationController(
        supportedLocales: const [Locale('en'), Locale('fb')],
        fallbackLocale: const Locale('fb'),
        path: 'path',
        useOnlyLangCode: true,
        useFallbackTranslations: true,
        onLoadError: (FlutterError e) {
          log(e.toString());
        },
        saveLocale: true,
        assetLoader: const JsonAssetLoader(),
      );
      expect(controller.locale, const Locale('fb'));

      SharedPreferences.setMockInitialValues({});
    });

    group('locale', () {
      test('locale supports device locale', () {
        const en = Locale('en');
        const en2 = Locale('en', '');
        const enUS = Locale('en', 'US');
        const enGB = Locale('en', 'GB');
        expect(en.supports(enUS), isTrue);
        expect(en2.supports(enUS), isTrue);
        expect(enUS.supports(enUS), isTrue);
        expect(enGB.supports(enUS), isFalse);

        const zh = Locale('zh', '');
        const zh2 = Locale('zh', '');
        const zhCN = Locale('zh', 'CN');
        const zhHans =
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
        const zhHant =
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
        const zhHansCN = Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN');
        expect(zh.supports(zhHansCN), isTrue);
        expect(zh2.supports(zhHansCN), isTrue);
        expect(zhCN.supports(zhHansCN), isTrue);
        expect(zhHans.supports(zhHansCN), isTrue);
        expect(zhHant.supports(zhHansCN), isFalse);
        expect(zhHansCN.supports(zhHansCN), isTrue);
      });

      test('select locale from device locale', () {
        const en = Locale('en', '');
        const zh = Locale('zh', '');
        const zhHans =
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
        const zhHant =
            Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
        const zhHansCN = Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN');

        expect(
          EasyLocalizationController.selectLocaleFrom([en, zh], zhHansCN),
          zh,
        );
        expect(
          EasyLocalizationController.selectLocaleFrom(
              [zhHant, zhHans], zhHansCN),
          zhHans,
        );
      });
    });

    group('tr', () {
      var r = EasyLocalizationController(
          forceLocale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('fb')],
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
        Localization.load(const Locale('en'),
            translations: r.translations,
            fallbackTranslations: r.fallbackTranslations);
      });
      test('finds and returns resource', () {
        expect(Localization.instance.tr('test'), 'test');
      });

      test('can resolve resource in any nest level', () {
        expect(
          Localization.instance.tr('nested.super.duper.nested'),
          'nested.super.duper.nested',
        );
      });
      test('can resolve resource that has a key with dots', () {
        expect(
          Localization.instance.tr('nested.but.not.nested'),
          'nested but not nested',
        );
      });

      test('won\'t fail for missing key (no periods)', () {
        expect(
          Localization.instance.tr('Processing'),
          'Processing',
        );
      });

      test('won\'t fail for missing key with periods', () {
        expect(
          Localization.instance.tr('Processing.'),
          'Processing.',
        );
      });

      test('can resolve linked locale messages', () {
        expect(Localization.instance.tr('linked'), 'this is linked');
      });

      test('can resolve linked locale messages and apply modifiers', () {
        expect(Localization.instance.tr('linkAndModify'),
            'this is linked and MODIFIED');
      });

      test('can resolve multiple linked locale messages and apply modifiers',
          () {
        expect(Localization.instance.tr('linkMany'), 'many Locale messages');
      });

      test('can resolve linked locale messages with brackets', () {
        expect(Localization.instance.tr('linkedWithBrackets'),
            'linked with brackets.');
      });

      test('can resolve any number of nested arguments', () {
        expect(
            Localization.instance
                .tr('nestedArguments', args: ['a', 'argument', '!']),
            'this is a nested argument!');
      });

      test('can resolve nested named arguments', () {
        expect(
            Localization.instance.tr('nestedNamedArguments', namedArgs: {
              'firstArg': 'this',
              'secondArg': 'named argument',
              'thirdArg': '!'
            }),
            'this is a nested named argument!');
      });

      test('returns missing resource as provided', () {
        expect(Localization.instance.tr('test_missing'), 'test_missing');
      });

      test('reports missing resource', overridePrint(() {
        printLog = [];
        expect(Localization.instance.tr('test_missing'), 'test_missing');
        final logIterator = printLog.iterator;
        logIterator.moveNext();
        expect(logIterator.current,
            contains('Localization key [test_missing] not found'));
        logIterator.moveNext();
        expect(logIterator.current,
            contains('Fallback localization key [test_missing] not found'));
      }));

      test('uses fallback translations', overridePrint(() {
        printLog = [];
        expect(Localization.instance.tr('test_missing_fallback'), 'fallback!');
      }));

      test('reports missing resource with fallback', overridePrint(() {
        printLog = [];
        expect(Localization.instance.tr('test_missing_fallback'), 'fallback!');
        expect(printLog.first,
            contains('Localization key [test_missing_fallback] not found'));
      }));

      test('returns resource and replaces argument', () {
        expect(
          Localization.instance.tr('test_replace_one', args: ['one']),
          'test replace one',
        );
      });
      test('returns resource and replaces argument in any nest level', () {
        expect(
          Localization.instance
              .tr('nested.super.duper.nested_with_arg', args: ['what a nest']),
          'nested.super.duper.nested_with_arg what a nest',
        );
      });

      test('returns resource and replaces argument sequentially', () {
        expect(
          Localization.instance.tr('test_replace_two', args: ['one', 'two']),
          'test replace one two',
        );
      });

      test(
          'should raise exception if provided arguments length is different from the count of {} in the resource',
          () {
        // @TODO
      });

      test('return resource and replaces named argument', () {
        expect(
          Localization.instance.tr('test_replace_named',
              namedArgs: {'arg1': 'one', 'arg2': 'two'}),
          'test named replace one two',
        );
      });

      test('returns resource and replaces named argument in any nest level',
          () {
        expect(
          Localization.instance.tr('nested.super.duper.nested_with_named_arg',
              namedArgs: {'arg': 'what a nest'}),
          'nested.super.duper.nested_with_named_arg what a nest',
        );
      });

      test('gender returns the correct resource', () {
        expect(
          Localization.instance.tr('gender', gender: 'male'),
          'Hi man ;)',
        );
        expect(
          Localization.instance.tr('gender', gender: 'female'),
          'Hello girl :)',
        );
      });

      test('gender returns the correct resource and replaces args', () {
        expect(
          Localization.instance
              .tr('gender_and_replace', gender: 'male', args: ['one']),
          'Hi one man ;)',
        );
        expect(
          Localization.instance
              .tr('gender_and_replace', gender: 'female', args: ['one']),
          'Hello one girl :)',
        );
      });
    });

    group('plural', () {
      var r = EasyLocalizationController(
          forceLocale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('fb')],
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
        Localization.load(const Locale('en'),
            translations: r.translations,
            fallbackTranslations: r.fallbackTranslations);
      });

      test('zero', () {
        expect(Localization.instance.plural('hat', 0), 'no hats');
      });

      test('one', () {
        expect(Localization.instance.plural('hat', 1), 'one hat');
      });
      test('two', () {
        expect(Localization.instance.plural('hat', 2), 'two hats');
      });

      test('few', () {
        // @TODO not sure how this works
      });

      test('many', () {
        // @TODO not sure how this works
      });

      test('other', () {
        expect(Localization.instance.plural('hat', -1), 'other hats');
      });

      test('other as fallback', () {
        expect(Localization.instance.plural('hat_other', 1), 'other hats');
      });

      test('other as fallback and fallback translations priority',
          overridePrint(() {
        printLog = [];
        expect(
          Localization.instance.plural('test_fallback_plurals', 2),
          '2 seconds', // isNot('fallback two'),
        );
        expect(printLog, isEmpty);
      }));

      test('with number format', () {
        expect(
            Localization.instance
                .plural('day', 3, format: NumberFormat.currency()),
            'USD3.00 other days');
      });

      test('zero with args', () {
        expect(Localization.instance.plural('money', 0, args: ['John', '0']),
            'John has no money');
      });

      test('one with args', () {
        expect(Localization.instance.plural('money', 1, args: ['John', '1']),
            'John has 1 dollar');
      });

      test('other with args', () {
        expect(Localization.instance.plural('money', 3, args: ['John', '3']),
            'John has 3 dollars');
      });

      test('zero with named args', () {
        expect(
          Localization.instance.plural('money_named_args', 0,
              namedArgs: {'name': 'John', 'money': '0'}),
          'John has no money',
        );
      });

      test('one with named args', () {
        expect(
          Localization.instance.plural('money_named_args', 1,
              namedArgs: {'name': 'John', 'money': '1'}),
          'John has 1 dollar',
        );
      });

      test('other with named args', () {
        expect(
          Localization.instance.plural('money_named_args', 3,
              namedArgs: {'name': 'John', 'money': '3'}),
          'John has 3 dollars',
        );
      });

      test('named args and value name', () {
        expect(
          Localization.instance.plural('money_named_args', 3,
              namedArgs: {'name': 'John'}, name: 'money'),
          'John has 3 dollars',
        );
      });
    });

    group('extensions', () {
      // setUpAll(() async {
      //   await Localization.load(Locale('en'),
      //       path: 'path',
      //       useOnlyLangCode: true,
      //       assetLoader: JsonAssetLoader());
      // });
      group('string', () {
        test('tr', () {
          expect('test'.tr(), 'test');
        });

        test('trExists', () {
          expect('test'.trExists(), true);
          expect('xyz'.trExists(), false);
        });

        test('plural', () {
          expect('day'.plural(0), '0 days');
        });
      });
    });

    group('extensions', () {
      // setUpAll(() async {
      //   await Localization.load(Locale('en'),
      //       path: 'path',
      //       useOnlyLangCode: true,
      //       assetLoader: JsonAssetLoader());
      // });
      group('string', () {
        test('tr', () {
          expect(tr('test'), 'test');
        });
        test('plural', () {
          expect(plural('day', 0), '0 days');
        });
      });
    });
  });
}
