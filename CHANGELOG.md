# Changelog

### [3.0.7]

- add _supportedLocales in EasyLocalizationController; log and check the deviceLocale when resetLocale;
- add scriptCode to desiredLocale if useOnlyLangCode is true. scriptCode is needed sometimes, for example zh-Hans, zh-Hant
- add savedLocale get method for context. if context.savedLocale is null, then language option is `following system`, i can display the option in user selection form.

### [3.0.6]

- add 'useFallbackTranslationsForEmptyResources' to be able to use fallback locales for empty resources.

### [3.0.5]

- add 'extraAssetLoaders' to add more assets loaders if it is needed, for example, if you want to add packages localizations to your project.

### [3.0.4]

- determine plural cases based on the actual language rules (#620)
- update intl to 0.19.0 (#638)

### [3.0.3]

- replace log() with stdout.writeln()

### [3.0.2]

- support intl 18
- support dart 3
- added trExists extension
- fix: handle invalid saved local
- handle null returned by assetLoader
- improve parsing scriptCode from local string
- add tr-extension on build context

### [3.0.1]

- added option allowing skip keys of nested object
- fixed plural bug
- fixed typos

### [3.0.0]

- **BREAKING**: Added `EasyLocalization.ensureInitialized()`, Needs to be called
- **BREAKING**: Added support null safety
- **BREAKING**: removed context parameter from `plural()` and `tr()`
- Added Formatting linked translations [more](https://github.com/aissat/easy_localization#linked-translations)
- Updated `plural()` function, with arguments [more](https://github.com/aissat/easy_localization#linked-translations)
  ```dart
    var money = plural('money_args', 10.23, args: ['John', '10.23'])  // output: John has 10.23 dollars
  ```
- Removed preloader widget ~~`preloaderWidget`~~
- fixed many issues.
- customizable logger [EasyLogger]
- device locale and reset device locale
- extensions helpers
- support fallback locale keys redirection

### [2.3.3]

- Updated pubspec dependencies
- Added --source-file argument in codegen

### [2.3.2]

- Updates generated tool.

### [2.3.1]

- Updated `plural()` function, now she is not strict.
- Updates print and log messages

### [2.3.0]

- Added extension methods on [BuildContext] for access to Easy Localization

:fire: It's more easiest way change locale or get parameters

```dart
context.locale = locale;
```
:information_source: No breaking changes, you can use old the static method `EasyLocalization.of(context)`

### [2.2.2]

- Added `preloaderWidget`.
- Fixed many issues.

### [2.2.1]

- Added `startLocale`.

## [2.2.0]

- Added support Locale scriptCode.
- Added `EasyLocalization.of(context).delegates` for `localizationsDelegates`

  ```dart
  supportedLocales: [
      Locale('en', 'US'),
      Locale('ar', 'DZ'),
      Locale('ar','DZ'),localeFromString('ar_DZ')
    ]
  ```

- Added support Custom assets loaders [Easy Localization Loader](https://github.com/aissat/easy_localization_loader).
  - Added support CSV files.

    ```dart
    path: 'resources/langs/langs.csv',
    assetLoader: CsvAssetLoader(),
    ```

  - Added support Yaml files.

    ```dart
    path: 'resources/langs',
    assetLoader: YamlAssetLoader(),
    ```

    ```dart
    path: 'resources/langs/langs.yaml',
    assetLoader: YamlSingleAssetLoader(),
    ```

  - Added support XML files.

    ```dart
    path: 'resources/langs',
    assetLoader: XmlAssetLoader(),
    ```

    ```dart
    path: 'resources/langs/langs.xml',
    assetLoader: XmlSingleAssetLoader(),
    ```

- Added Code generation of localization files.

  ```cmd
  $ flutter pub run easy_localization:generate -h
  -s, --source-dir     Source folder contains all string json files
                      (defaults to "resources/langs")
  -O, --output-dir     Output folder stores generated file
                      (defaults to "lib/generated")
  -o, --output-file    Output file name
                      (defaults to "codegen_loader.g.dart")
  -f, --format         Support json, dart formats
                      [json (default), keys]
  ```

  - generate the json string static keys in a dart class

    ```json
    {
      "msg_named": "{} مكتوبة باللغة {lang}",
    }
    ```

    ```cmd
    flutter pub run easy_localization:generate  -f keys -o locale_keys.g.dart
    ```

    ```dart
    abstract class  LocaleKeys {
      static const msg_named = 'msg_named';
    }
    ```

    ```dart
    Text(LocaleKeys.msg_named).tr(namedArgs: {'lang': 'Dart'}, args: ['Easy localization']),
    ```

  - generate the json Loader in a dart class
  
    ```cmd
    flutter pub run easy_localization:generate
    ```

- fixed many issues.
- Added named arguments.

  ```json
  "msg_named": "{} are written in the {lang} language",
  ```

  ```dart
  Text(LocaleKeys.msg_named).tr(namedArgs: {'lang': 'Dart'}, args: ['Easy localization']),
  ```

## [2.1.0]

- Added Error widget.
- fixed many issues.
- Based on Bloc.
- optimized and clean code more stability

## [2.0.2]

- fixed many issues
- optimized and clean code more stability

## [2.0.1]

- Added change locale dynamically `saveLocale` default value `true`
- fixed many issues

## [2.0.0]

this version came with many updates, here are the main ones:

- optimized and clean code more stability
- fixed many issues
- added Unite test
- Customization AssetLoader localizations `assetLoader` for more details see [custom assetLoader](https://github.com/aissat/easy_localization/blob/dev/example/lib/custom_asset_loader.dart)
- added `fallbackLocale` as optional
- Hiding `EasyLocalizationProvider`
- refactor and update approach localization for more details see [example:](https://github.com/aissat/easy_localization/tree/master/example)

  ``` dart
  // Now V2.0.0
  runApp(EasyLocalization(
    child: MyApp(),
    ...
  ));

  // after V2.0.0
  runApp(EasyLocalization(
    child: MyApp(),
    ...
  ));
  ...
  class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(...);
  }}
  ```

- added Support for context

    ``` dart
    tr("key", context: context),
    plural("key", 1 , context: context),
    ```

## [1.4.1]

- optimized and clean code
- fixed many issues
- added extension for Strings

  ``` dart
  // after 1.4.1
  Text('title'.tr()),
  Text('switch'.tr( gender: _gender ? "female" : "male")),
  Text('counter'.plural(counter)),
  ```

## [1.4.0]

- refactor code changed call ~~`AppLocalizations.of(context).tr()`~~ ~~`AppLocalizations.of(context).plural()`~~ to `tr()` and `plural()`

  ``` dart
  // after 1.4.0
  Text(
    tr('switch', gender: _gender ? "female" : "male"),
  ),
  ```

  ``` dart
  // before 1.4.0
  Text(
    AppLocalizations.of(context).tr('switch', gender: _gender ? "female" : "male"),
  ),
  ```

- added Flutter extension for Text widget

  ``` dart
  // after 1.4.0
  Text('switch').tr( gender: _gender ? "female" : "male"),
  Text('counter').plural(counter),
  ```

## [1.3.5]

- merge  `gender()`  and `tr()`  .

  ``` json
  {
    "gender":{
      "male": "Hi man ;)",
      "female": "Hello girl :)"
    }
  }
  ```

  ``` dart
  new Text(
    AppLocalizations.of(context).tr('switch', gender: _gender ? "female" : "male"),
  ),
  ```

- use parameters `args` for gender.
  
  ``` json
  {
    "gender":{
      "male": "Hi man ;) {}",
      "female": "Hello girl :) {}"
    }
  }
  ```

  ``` dart
  new Text(
    AppLocalizations.of(context).tr('switch', args:["Naama"] gender: _gender ? "female" : "male"),
  ),

## [1.3.4]

- adeed Gender [female,male]  `gender()`  .

  ``` json
  {
    "gender":{
      "male": "Hi man ;)",
      "female": "Hello girl :)"
    }
  }
  ```

  ``` dart
  new Text(
    AppLocalizations.of(context).gender('switch', _gender ? "female" : "male"),
  ),
  `

## [1.3.3+1]

- updated  `plural()` thanks [shushper](https://github.com/shushper) .

  ``` json
  {
    "text": {
      "day": {
        "zero":"{} дней",
        "one": "{} день",
        "two": "{} дня",
        "few": "{} дня",
        "many": "{} дней",
        "other": "{} дней"
      }
    }
  }
  ```

## [1.3.3]

- removed  `data.savedLocale` .
- optimized and clean code
- fixed many issues

## [1.3.2]

- `plural()` added property resolver for nested key translations

  ``` json
  {
  "text": {
    "day": {
      "zero": "day",
      "one": "day",
      "other": "days"
      }
    }
  }

  ```

  ``` dart
  new Text(
    AppLocalizations.of(context).plural("text.day", 2),
  ),
  ```

- fixed many issues

## [1.3.1]

- add useOnlyLangCode flag

## [1.3.0]

- Load translations from remote or backend
- fixed many issues

## [1.2.1]

- supported shared_preferences
- Save selected localization

## [1.2.0]

- Added property resolver for nested key translations
- return translate key if the element or path not exist

``` json
{
  "title": "Hello",
  "msg": "Hello {} in the {} world ",
  "clickMe": "Click me",
  "profile": {
    "reset_password": {
      "label":  "Reset Password",
      "username": "Username",
      "password": "password"
    }
  },
  "clicked": {
    "zero": "You clicked {} times!",
    "one": "You clicked {} time!",
    "other": "You clicked {} times!"
  }
}

new Text(
  AppLocalizations.of(context).tr('profile.reset_password.title'),
 ),
```

## [1.0.4]

- Added Support country codes

## [1.0.3]

- Updated `tr()` function added Multi Argument

## [1.0.2]

- Added string pluralisation .
- Added Argument to `tr()` function.
