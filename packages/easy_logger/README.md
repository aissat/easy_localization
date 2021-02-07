<h1 align="center"> 
EasyLogger
</h1>

## Getting Started

### 🔩 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  easy_logger: <last_version>
```

### ⚙️ Configuration logger

Create global logger value

```dart
import 'package:easy_logger/easy_logger.dart';

final EasyLogger logger = EasyLogger(
  name: 'NamePrefix',
  defaultLevel: LevelMessages.debug,
  enableBuildModes: [BuildMode.debug, BuildMode.profile, BuildMode.release],
  enableLevels: [LevelMessages.debug, LevelMessages.info, LevelMessages.error, LevelMessages.warning],
);

void main() async {
...
}
```

### 📜 EasyLogger properties

| Properties       | Required | Default                   | Description |
| ---------------- | -------- | ------------------------- | ----------- |
| name             | false    | ''                      | Name prefix in the logging line. |
| defaultLevel     | false    | LevelMessages.info | Default message level if no level is set when call [EasyLogger]. |
| enableBuildModes | false    | [BuildMode.debug, BuildMode.profile] | List of available build modes in which logging is enabled. |
| enableLevels     | false    | [LevelMessages.debug, LevelMessages.info, LevelMessages.error, LevelMessages.warning] | List of available levels messages in which logging is enabled. |
| printer          | false    | easyLogDefaultPrinter() | Default function printing. |

## Usage

Simle usage:

```dart
logger('Your log text');
```

Or you can set the message level

```dart
logger('Your log text', level: LevelMessages.info);
```


### 🐛 StackTrace

[EasyLogger] support [StackTrace] dump sending:

```dart
try {
  //same code
} on Exception catch (e, stackTrace) {
   logger('same error', stackTrace: stackTrace);
}
```

### 🖨️ Customise message or build levels

[EasyLogger] supported Flutter build modes. Read more about [Build modes](https://flutter.dev/docs/testing/build-modes)

```dart
// only debug and profile modes
logger.enableBuildModes = [BuildMode.debug, BuildMode.profile]

// logger off
logger.enableLevels = []
```

You can customize what levels of messages you need

```dart
// show only errors
logger.enableBuildModes = [LevelMessages.error]

```

### 🖨️ Customise printer function

[EasyLogger] have easiest way to change default printer function.
Create your custom printer and past like parameter in class.

```dart
EasyLogPrinter customLogPrinter = (
  Object object, {
  String name,
  StackTrace stackTrace,
  LevelMessages level,
}) {
  print('$name: ${object.toString()}');
};

final EasyLogger logger = EasyLogger(
  printer: customLogPrinter,
);
```
Or insert into class object

```dart
logger.printer = customLogPrinter;
```

## 🖨️ Helpers

For easest using logger you can send messages without `level` parameter.

```dart
  logger.debug('your log text');
  logger.info('your log text');
  logger.warning('your log text');
  logger.error('your log text');
```