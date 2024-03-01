import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

var printLog = [];
dynamic overridePrint(Function() testFn) => () {
      var spec = ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        printLog.add(msg);
      });
      return Zone.current.fork(specification: spec).run(testFn);
    };

void main() {
  group('Utils', () {
    group('Locales', () {
      test('localeFromString only language code', () {
        var locale = 'en'.toLocale();
        expect(locale, const Locale('en'));
      });

      test('localeFromString language code and country code', () {
        var locale = 'en_US'.toLocale();
        expect(locale, const Locale('en', 'US'));
      });

      test('localeFromString language code and script code', () {
        var locale = 'zh_Hant'.toLocale();
        expect(locale,
            const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
      });

      test('localeFromString language, country, script code', () {
        var locale = 'zh_Hant_HK'.toLocale();
        expect(
            locale,
            const Locale.fromSubtags(
                languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'));
      });

      test('localeToString', () {
        var locale = const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK');
        var string = locale.toStringWithSeparator();
        expect(string, 'zh_Hant_HK');
      });

      test('localeToString custom separator', () {
        var locale = const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK');
        var string = locale.toStringWithSeparator(separator: '|');
        expect(string, 'zh|Hant|HK');
      });
    });

    group('MapExtension', () {
      test('should add all key value pairs recursively', () {
        final Map<String, dynamic> map1 = {
          'key1': 'value1',
          'key2': {
            'key3': 'value3',
            'key4': 'value4',
          },
        };

        final Map<String, dynamic> map2 = {
          'key2': {
            'key4': 'new_value4',
            'key5': 'value5',
          },
          'key6': 'value6',
        };

        map1.addAllRecursive(map2);

        expect(map1, {
          'key1': 'value1',
          'key2': {
            'key3': 'value3',
            'key4': 'new_value4',
            'key5': 'value5',
          },
          'key6': 'value6',
        });
      });

      test('should work with empty maps', () {
        final Map<String, dynamic> map1 = {};
        final Map<String, dynamic> map2 = {
          'key1': 'value1',
          'key2': {
            'key3': 'value3',
            'key4': 'value4',
          },
        };

        map1.addAllRecursive(map2);

        expect(map1, {
          'key1': 'value1',
          'key2': {
            'key3': 'value3',
            'key4': 'value4',
          },
        });
      });
    });
  });
}
