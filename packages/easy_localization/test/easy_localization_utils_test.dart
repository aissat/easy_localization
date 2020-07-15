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
        var locale = localeFromString('en');
        expect(locale, Locale('en'));
      });

      test('localeFromString language code and country code', () {
        var locale = localeFromString('en_US');
        expect(locale, Locale('en', 'US'));
      });

      test('localeFromString language, country, script code', () {
        var locale = localeFromString('zh_Hant_HK');
        expect(
            locale,
            Locale.fromSubtags(
                languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'));
      });

      test('localeToString', () {
        var locale = Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK');
        var string = localeToString(locale);
        expect(string, 'zh_Hant_HK');
      });

      test('localeToString custom separator', () {
        var locale = Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK');
        var string = localeToString(locale, separator: '|');
        expect(string, 'zh|Hant|HK');
      });
    });

    group('Prints', () {
      test('Info print', overridePrint(() {
        printLog = [];
        printInfo('Info');
        expect(printLog.first, '\u001b[32mEasy Localization: Info\u001b[0m');
      }));

      test('Warning print', overridePrint(() {
        printLog = [];
        printWarning('Warning');
        expect(printLog.first,
            '\u001B[34m[WARNING] Easy Localization: Warning\u001b[0m');
      }));

      test('Error print', overridePrint(() {
        printLog = [];
        printError('Error');
        expect(printLog.first,
            '\u001b[31m[ERROR] Easy Localization: Error\u001b[0m');
      }));
    });
  });
}
