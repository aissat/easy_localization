import 'dart:async';

import 'package:easy_logger/easy_logger.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> printLog = <String>[];
ZoneSpecification? spec;
dynamic Function() overridePrint(Function() testFn) => () {
      spec = ZoneSpecification(
        print: (_, __, ___, String msg) {
          // Add to log instead of printing to stdout
          printLog.add(msg);
        },
      );
      return Zone.current.fork(specification: spec).run(testFn);
    };

late EasyLogger logger;
void main() {
  group('Logger testing print', () {
    logger = EasyLogger(name: 'test logger');

    test('Logger print', overridePrint(() {
      printLog = <String>[];
      logger('Same print');
      expect(printLog.first, contains('Same print'));
      expect(printLog.first, contains(logger.name));
    }));

    test('Logger print info', overridePrint(() {
      printLog = <String>[];
      logger('print info', level: LevelMessages.info);
      expect(printLog.first, contains('print info'));
      expect(printLog.first, contains('[INFO]'));
    }));

    test('Logger print debug', overridePrint(() {
      printLog = <String>[];
      logger('print debug', level: LevelMessages.debug);
      expect(printLog.first, contains('print debug'));
      expect(printLog.first, contains('[DEBUG]'));
    }));

    test('Logger print warning', overridePrint(() {
      printLog = <String>[];
      logger('print warning', level: LevelMessages.warning);
      expect(printLog.first, contains('print warning'));
      expect(printLog.first, contains('[WARNING]'));
    }));

    test('Logger print error', overridePrint(() {
      printLog = <String>[];
      logger('print error', level: LevelMessages.error);
      expect(printLog.first, contains('print error'));
      expect(printLog.first, contains('[ERROR]'));
    }));

    test('Logger print error with StackTrace', overridePrint(() {
      printLog = <String>[];

      StackTrace testStackTrace;
      testStackTrace = StackTrace.fromString('test stack');

      logger('print error',
          level: LevelMessages.error, stackTrace: testStackTrace);
      expect(printLog.first, contains('print error'));
      expect(printLog.first, contains('[ERROR]'));
      expect(printLog.last, contains('test stack'));
    }));
  });

  group('Logger BuildModes', () {
    logger = EasyLogger(name: 'test logger');

    test('Logger BuildModes is not null', () {
      expect(logger.enableBuildModes, isNotNull);
      expect(logger.enableBuildModes, isNotEmpty);
    });

    test('Logger default enable', () {
      expect(logger.isEnabled(LevelMessages.debug), true);
    });
  });
}
