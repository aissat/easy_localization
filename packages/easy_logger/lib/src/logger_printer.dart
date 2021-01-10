import 'dart:developer';

import '../easy_logger.dart';

typedef EasyLogPrinter = Function(Object object, {String name, EasyLoggerLevel level, StackTrace stackTrace});

EasyLogPrinter easyLogDefaultPrinter = (Object object, {String name, StackTrace stackTrace, EasyLoggerLevel level}) {
  String _prepareString() {
    switch (level) {
      case EasyLoggerLevel.debug:
        // white
        return '\u001b[37m[INFO] ${object.toString()}\u001b[0m';
      case EasyLoggerLevel.info:
        // green
        return '\u001b[32m[INFO] ${object.toString()}\u001b[0m';
      case EasyLoggerLevel.warning:
        // blue
        return '\u001B[34m[WARNING] ${object.toString()}\u001b[0m';
      case EasyLoggerLevel.error:
        // red
        return '\u001b[31m[ERROR] ${object.toString()}\u001b[0m';
      default:
        // gray
        return '\u001b[90m${object.toString()}\u001b[0m';
    }
  }

  log(
    _prepareString(),
    name: name,
    stackTrace: stackTrace,
  );
};
