import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> printLog = [];
dynamic overridePrint(Function() testFn) => () {
      var spec = ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        printLog.add(msg);
      });
      return Zone.current.fork(specification: spec).run(testFn);
    };

void main() async {
  group('Logger testing', () {
    test('Logger enable', () {
      expect(EasyLocalization.logger, equals(EasyLocalization.logger));
      expect(EasyLocalization.logger, isNotNull);
    });

    test('Logger print', overridePrint(() {
      printLog = [];
      EasyLocalization.logger('Same print');
      expect(printLog.first, contains('Same print'));
      expect(printLog.first, contains(EasyLocalization.logger.name));
    }));

    test('Logger print info', overridePrint(() {
      printLog = [];
      EasyLocalization.logger('print info', level: LevelMessages.info);
      expect(printLog.first, contains('print info'));
      expect(printLog.first, contains('[INFO]'));
    }));

    test('Logger print debug', overridePrint(() {
      printLog = [];
      EasyLocalization.logger('print debug', level: LevelMessages.debug);
      expect(printLog.first, contains('print debug'));
      expect(printLog.first, contains('[DEBUG]'));
    }));

    test('Logger print warning', overridePrint(() {
      printLog = [];
      EasyLocalization.logger('print warning', level: LevelMessages.warning);
      expect(printLog.first, contains('print warning'));
      expect(printLog.first, contains('[WARNING]'));
    }));

    test('Logger print error', overridePrint(() {
      printLog = [];
      EasyLocalization.logger('print error', level: LevelMessages.error);
      expect(printLog.first, contains('print error'));
      expect(printLog.first, contains('[ERROR]'));
    }));

    test('Logger print error with StackTrace', overridePrint(() {
      printLog = [];

      StackTrace testStackTrace;
      testStackTrace = StackTrace.fromString('test stack');

      EasyLocalization.logger('print error',
          level: LevelMessages.error, stackTrace: testStackTrace);
      expect(printLog.first, contains('print error'));
      expect(printLog.first, contains('[ERROR]'));
      expect(printLog.last, contains('test stack'));
    }));
  });
}
