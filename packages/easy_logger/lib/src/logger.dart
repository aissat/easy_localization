import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'logger_printer.dart';

/// Easy Logger callable class
class EasyLogger {
  /// Customized logger, part of [EasyLocalization](https://github.com/aissat/easy_localization) ecosystem.
  /// Callable class, [more info](https://dart.dev/guides/language/language-tour#callable-classes)
  EasyLogger({
    this.name = '',
    this.enableBuildModes = const <BuildMode>[
      BuildMode.profile,
      BuildMode.debug,
    ],
    this.enableLevels = const <LevelMessages>[
      LevelMessages.debug,
      LevelMessages.info,
      LevelMessages.error,
      LevelMessages.warning,
    ],
    EasyLogPrinter? printer,
    this.defaultLevel = LevelMessages.info,
  }) {
    this.printer = printer ?? easyLogDefaultPrinter;
    _currentBuildMode = _getCurrentBuildMode();
  }

  BuildMode? _currentBuildMode;

  /// Name prefix in the logging line.
  /// @Default value `''` empty string.
  /// Example:
  /// ```
  /// [YourName] same log text
  /// ```
  String name;

  /// List of available build modes in which logging is enabled.
  /// @Default value `const <LevelMessages>[BuildMode.profile, BuildMode.debug]`
  List<BuildMode> enableBuildModes;

  /// List of available levels messages in which logging is enabled.
  /// @Default value `const <LevelMessages>[LevelMessages.debug, LevelMessages.info, LevelMessages.error, LevelMessages.warning]`
  List<LevelMessages> enableLevels;

  /// Default message level if no level is set when call [EasyLogger].
  /// @Default value `LevelMessages.info`
  LevelMessages defaultLevel;

  /// Printer function instance.
  /// You can change the standard print function to a custom one.
  /// Example:
  /// ```dart
  /// EasyLogPrinter customLogPrinter = (
  ///   Object object, {
  ///   String name,
  ///   StackTrace stackTrace,
  ///   LevelMessages level,
  /// }) {
  ///   print('$name: ${object.toString()}');
  /// };
  ///
  /// logger.printer = customLogPrinter;
  /// ```
  EasyLogPrinter? printer;

  BuildMode _getCurrentBuildMode() {
    if (kReleaseMode) {
      return BuildMode.release;
    } else if (kProfileMode) {
      return BuildMode.profile;
    }
    return BuildMode.debug;
  }

  /// Check [enableBuildModes] and [enableLevels]
  bool isEnabled(LevelMessages level) {
    if (!enableBuildModes.contains(_currentBuildMode)) {
      return false;
    }
    if (!enableLevels.contains(level)) {
      return false;
    }
    return true;
  }

  /// The main callable function for handling log messages.
  void call(Object object, {StackTrace? stackTrace, LevelMessages? level}) {
    level ??= defaultLevel;
    if (isEnabled(level)) {
      printer!(object, stackTrace: stackTrace, level: level, name: name);
    }
  }

  /// Helper for main callable function.
  /// Call logger function with level [LevelMessages.debug]
  void debug(Object object, {StackTrace? stackTrace}) =>
      call(object, stackTrace: stackTrace, level: LevelMessages.debug);

  /// Helper for main callable function.
  /// Call logger function with level [LevelMessages.info]
  void info(Object object, {StackTrace? stackTrace}) =>
      call(object, stackTrace: stackTrace, level: LevelMessages.info);

  /// Helper for main callable function.
  /// Call logger function with level [LevelMessages.warning]
  void warning(Object object, {StackTrace? stackTrace}) =>
      call(object, stackTrace: stackTrace, level: LevelMessages.warning);

  /// Helper for main callable function.
  /// Call logger function with level [LevelMessages.error]
  void error(Object object, {StackTrace? stackTrace}) =>
      call(object, stackTrace: stackTrace, level: LevelMessages.error);
}
