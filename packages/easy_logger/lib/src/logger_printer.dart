import 'package:flutter/foundation.dart';

import '../easy_logger.dart';

/// Type for function printing/logging in [EasyLogger].
typedef EasyLogPrinter = Function(Object object,
    {String? name, LevelMessages? level, StackTrace? stackTrace});

/// Default debug-mode function printing.
EasyLogPrinter easyLogDefaultPrinter = (Object object,
    {String? name, StackTrace? stackTrace, LevelMessages? level}) {
  final String levelName = level?.name != null ? '[${level?.name}] ' : '';
  final String tag = name != null ? '[$name] ' : '';

  if (kDebugMode) {
    print(_getColoredString(level, '$tag$levelName${object.toString()}'));

    if (stackTrace != null) {
      print(_getColoredString(level, '__________________________________'));
      print(_getColoredString(level, stackTrace.toString()));
    }
  }
};

String _getColoredString(LevelMessages? level, String string) {
  switch (level) {
    case LevelMessages.debug:
      // gray
      return '\u001b[90m$string\u001b[0m';
    case LevelMessages.info:
      // green
      return '\u001b[32m$string\u001b[0m';
    case LevelMessages.warning:
      // blue
      return '\u001B[34m$string\u001b[0m';
    case LevelMessages.error:
      // red
      return '\u001b[31m$string\u001b[0m';
    default:
      // gray
      return '\u001b[90m$string\u001b[0m';
  }
}

extension _LevelMessagesExtension on LevelMessages {
  String get name {
    switch (this) {
      case LevelMessages.debug:
        return 'DEBUG';
      case LevelMessages.info:
        return 'INFO';
      case LevelMessages.warning:
        return 'WARNING';
      case LevelMessages.error:
        return 'ERROR';
    }
  }
}
