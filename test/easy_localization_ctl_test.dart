import 'dart:async';

import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:flutter/material.dart';
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
  group('EasyLocalizationController', () {
    group('selectLocaleFrom', () {
      test('should return the correct selected locale', () {
        final supportedLocales = [const Locale('en', 'US'), const Locale('fr', 'FR')];
        const deviceLocale = Locale('en', 'US');
        const fallbackLocale = Locale('en', 'US');

        final selectedLocale = EasyLocalizationController.selectLocaleFrom(
          supportedLocales,
          deviceLocale,
          fallbackLocale: fallbackLocale,
        );

        expect(selectedLocale, equals(const Locale('en', 'US')));
      });

      test('should return the fallback locale if no supported locale matches',
          () {
        final supportedLocales = [const Locale('en', 'US'), const Locale('fr', 'FR')];
        const deviceLocale = Locale('es', 'ES');
        const fallbackLocale = Locale('en', 'US');

        final selectedLocale = EasyLocalizationController.selectLocaleFrom(
          supportedLocales,
          deviceLocale,
          fallbackLocale: fallbackLocale,
        );

        expect(selectedLocale, equals(const Locale('en', 'US')));
      });
    });

    // Write more test cases for other functions or methods
  });
}
