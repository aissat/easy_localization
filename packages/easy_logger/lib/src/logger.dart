import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'logger_printer.dart';

/// Easy Logger
class EasyLogger {
  EasyLogger({
    this.name,
    this.enableBuildModes = const <BuildMode>[
      BuildMode.profile,
      BuildMode.debug,
    ],
    this.enableLevels = const <EasyLoggerLevel>[
      EasyLoggerLevel.debug,
      EasyLoggerLevel.info,
      EasyLoggerLevel.error,
      EasyLoggerLevel.warning,
    ],
    EasyLogPrinter printer,
    this.defaultLevel = EasyLoggerLevel.info,
  }) {
    _printer = printer ?? easyLogDefaultPrinter;
    _currentBuildMode = _getCurrentBuildMode();
  }

  BuildMode _currentBuildMode;
  String name;
  List<BuildMode> enableBuildModes;
  List<EasyLoggerLevel> enableLevels;
  EasyLoggerLevel defaultLevel;

  EasyLogPrinter _printer;
  EasyLogPrinter get printer => _printer;
  set printer(EasyLogPrinter newPrinter) => _printer = newPrinter;

  BuildMode _getCurrentBuildMode() {
    if (kReleaseMode) {
      return BuildMode.release;
    } else if (kProfileMode) {
      return BuildMode.profile;
    }
    return BuildMode.debug;
  }

  bool isEnabled(EasyLoggerLevel level) {
    if (!enableBuildModes.contains(_currentBuildMode)) {
      return false;
    }
    if (!enableLevels.contains(level)) {
      return false;
    }
    return true;
  }

  void call(Object object, {StackTrace stackTrace, EasyLoggerLevel level}) {
    level ??= defaultLevel;
    if (isEnabled(level)) {
      _printer(object, stackTrace: stackTrace, level: level, name: name);
    }
  }

  void debug(Object object, {StackTrace stackTrace}) =>
      call(object, stackTrace: stackTrace, level: EasyLoggerLevel.debug);

  void info(Object object, {StackTrace stackTrace}) =>
      call(object, stackTrace: stackTrace, level: EasyLoggerLevel.info);

  void warning(Object object, {StackTrace stackTrace}) =>
      call(object, stackTrace: stackTrace, level: EasyLoggerLevel.warning);

  void error(Object object, {StackTrace stackTrace}) =>
      call(object, stackTrace: stackTrace, level: EasyLoggerLevel.error);
}
