import '../easy_logger.dart';

/// Type for function printing/logging in [EasyLogger].
typedef EasyLogPrinter = Function(Object object,
    {String? name, LevelMessages? level, StackTrace? stackTrace});

/// Default function printing.
EasyLogPrinter easyLogDefaultPrinter = (Object object,
    {String? name, StackTrace? stackTrace, LevelMessages? level}) {
  String _coloredString(String string) {
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

  String _prepareObject() {
    switch (level) {
      case LevelMessages.debug:
        return _coloredString('[$name] [DEBUG] ${object.toString()}');
      case LevelMessages.info:
        return _coloredString('[$name] [INFO] ${object.toString()}');
      case LevelMessages.warning:
        return _coloredString('[$name] [WARNING] ${object.toString()}');
      case LevelMessages.error:
        return _coloredString('[$name] [ERROR] ${object.toString()}');
      default:
        return _coloredString('[$name] ${object.toString()}');
    }
  }

  print(_prepareObject());

  if (stackTrace != null) {
    print(_coloredString('__________________________________'));
    print(_coloredString('${stackTrace.toString()}'));
  }
};
