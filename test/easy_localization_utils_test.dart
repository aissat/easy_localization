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
        expect(locale, Locale('en'));
      });

      test('localeFromString language code and country code', () {
        var locale = 'en_US'.toLocale();
        expect(locale, Locale('en', 'US'));
      });

      test('localeFromString language, country, script code', () {
        var locale = 'zh_Hant_HK'.toLocale();
        expect(
            locale,
            Locale.fromSubtags(
                languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'));
      });

      test('localeToString', () {
        var locale = Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK');
        var string = locale.toStringWithSeparator();
        expect(string, 'zh_Hant_HK');
      });

      test('localeToString custom separator', () {
        var locale = Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK');
        var string = locale.toStringWithSeparator(separator: '|');
        expect(string, 'zh|Hant|HK');
      });
    });
  });
}
