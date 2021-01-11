import 'dart:developer';

import '../easy_logger.dart';

/// Type for function printing/logging in [EasyLogger].
typedef EasyLogPrinter = Function(Object object, {String name, LevelMessages level, StackTrace stackTrace});

/// Default function printing.
EasyLogPrinter easyLogDefaultPrinter = (Object object, {String name, StackTrace stackTrace, LevelMessages level}) {
  String _prepareString() {
    switch (level) {
      case LevelMessages.debug:
        // white
        return '\u001b[37m[INFO] ${object.toString()}\u001b[0m';
      case LevelMessages.info:
        // green
        return '\u001b[32m[INFO] ${object.toString()}\u001b[0m';
      case LevelMessages.warning:
        // blue
        return '\u001B[34m[WARNING] ${object.toString()}\u001b[0m';
      case LevelMessages.error:
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
