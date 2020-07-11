<p align="center"><img src="https://raw.githubusercontent.com/aissat/easy_localization/develop/logo/logo.svg?sanitize=true" width="600"/></p>
<h1 align="center"> 
Easy and Fast internationalization for your Flutter Apps
</h1>

![Pub Version](https://img.shields.io/pub/v/easy_localization?style=flat-square)
![Code Climate issues](https://img.shields.io/github/issues/aissat/easy_localization?style=flat-square)
![GitHub closed issues](https://img.shields.io/github/issues-closed/aissat/easy_localization?style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/aissat/easy_localization?style=flat-square)
![GitHub repo size](https://img.shields.io/github/repo-size/aissat/easy_localization?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/aissat/easy_localization?style=flat-square)
![GitHub stars](https://img.shields.io/github/stars/aissat/easy_localization?style=flat-square)
![Coveralls github branch](https://img.shields.io/coveralls/github/aissat/easy_localization/dev?style=flat-square)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/aissat/easy_localization/Flutter%20Tester?longCache=true&style=flat-square&logo=github)
![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/aissat/easy_localization?style=flat-square)
![GitHub license](https://img.shields.io/github/license/aissat/easy_localization?style=flat-square)
![Sponsors](https://img.shields.io/opencollective/all/flutter_easy_localization?style=flat-square)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)

## Why easy_localization?

- 🚀 Easy translations for many languages
- 🔌 Load translations as JSON, CSV, Yaml, Xml using [Easy Localization Loader](https://github.com/aissat/easy_localization_loader)
- 💾 React and persist to locale changes
- ⚡ Supports plural, gender, nesting, RTL locales and more
- ⁉️ Error widget for missing translations
- ❤️ Extension methods on `Text` and `BuildContext`
- 💻 Code generation for localization files and keys.
- 👍 Uses BLoC pattern 

## Getting Started

### 🔩 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  easy_localization: <last_version>
```

Create folder and add translation files like this

```
assets
└── translations
    ├── {languageCode}.{ext}                  //only language code
    └── {languageCode}-{countryCode}.{ext}    //or full locale code
```

Example:

```
assets
└── translations
    ├── en.json
    └── en-US.json 
```

Declare your assets localization directory in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/translations/
```

### 🔌 Loading translations from other resources

You can use JSON,CSV,HTTP,XML,Yaml files, etc.

See [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) for more info.

### ⚠️ Note on **iOS**

For translation to work on **iOS** you need to add supported locales to 
`ios/Runner/Info.plist` as described [here](https://flutter.dev/docs/development/accessibility-and-localization/internationalization#specifying-supportedlocales).

Example:

```xml
<key>CFBundleLocalizations</key>
<array>
	<string>en</string>
	<string>nb</string>
</array>
```

### ⚙️ Configuration app

Add EasyLocalization widget like in example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() {
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('de', 'DE')],
      path: 'assets/translations', // <-- change patch to your
      fallbackLocale: Locale('en', 'US'),
      child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: MyHomePage()
    );
  }
}
```

[**Full example**](https://github.com/aissat/easy_localization/blob/master/example/lib/main.dart)

### 📜 Easy localization widget properties

| Properties       | Required | Default                   | Description |
| ---------------- | -------- | ------------------------- | ----------- |
| key              | false    |                           | Widget key. |
| child            | true     |                           | Place for your main page widget. |
| supportedLocales | true     |                           | List of supported locales. |
| path             | true     |                           | Path to your folder with localization files. |
| assetLoader      | false    | `RootBundleAssetLoader()` | Class loader for localization files. You can use custom loaders from [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) or create your own class. |
| fallbackLocale   | false    |                           | Returns the locale when the locale is not in the list `supportedLocales`.|
| startLocale      | false    |                           | Overrides device locale. |
| saveLocale       | false    | `true`                    | Save locale in device storage. |
| useOnlyLangCode  | false    | `false`                   | Trigger for using only language code for reading localization files.</br></br>Example:</br>`en.json //useOnlyLangCode: true`</br>`en-US.json //useOnlyLangCode: false`  |
| preloaderColor   | false    | `Colors.white`            | Background color for EmptyPreloaderWidget.</br>If you use a different color background, change the color to avoid flickering |
| preloaderWidget  | false    | `EmptyPreloaderWidget()`  | Shows your custom widget while translation is loading. |


## Usage

### 🔥 Change or get locale

Easy localization uses extension methods [BuildContext] for access to locale.

It's more easiest way change locale or get parameters 😉.

ℹ️ No breaking changes, you can use old the static method `EasyLocalization.of(context)`

Example:

```dart
context.locale = Locale('en', 'US');

print(context.locale.toString());
```

### 🔥 Translate `tr()`

Main function for translate your language keys

You can use extension methods of [String] or [Text] widget, you can also use `tr()` as a static function.

```dart
Text('title').tr() //Text widget

print('title'.tr()); //String

var title = tr('title') //Static function
```

#### Arguments:

| Name | Type | Description |
| -------- | -------- | -------- |
| context| `BuildContext` | The location in the tree where this widget builds |
| args| `List<String>` | List of localized strings. Replaces `{}` left to right |
| namedArgs| `Map<String, String>` | Map of localized strings. Replaces the name keys `{key_name}` according to its name |
| gender | `String` | Gender switcher. Changes the localized string based on gender string |

Example:

``` json
{
   "msg":"{} are written in the {} language",
   "msg_named":"Easy localization are written in the {lang} language",
   "msg_mixed":"{} are written in the {lang} language",
   "gender":{
      "male":"Hi man ;) {}",
      "female":"Hello girl :) {}",
      "other":"Hello {}"
   }
}
```

```dart
// args
Text('msg').tr(args: ['Easy localization', 'Dart']),

// namedArgs
Text('msg_named').tr(namedArgs: {'lang': 'Dart'}),

// args and namedArgs
Text('msg_mixed').tr(args: ['Easy localization'], namedArgs: {'lang': 'Dart'}),

// gender
Text('gender').tr(gender: _gender ? "female" : "male"),

```

### 🔥 Plurals `plural()`

You can translate with pluralization.
To insert a number in the translated string, use `{}`. Number formatting supported, for more information read [NumberFormat](https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html) class documentation.

You can use extension methods of [String] or [Text] widget, you can also use `plural()` as a static function.

#### Arguments:

| Name | Type | Description |
| -------- | -------- | -------- |
| context| `BuildContext` | The location in the tree where this widget builds|
| value| `num` | Number value for pluralization |
| format| `NumberFormat` | Formats a numeric value using a [NumberFormat](https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html) class |

Example:

``` json
{
  "day": {
    "zero":"{} дней",
    "one": "{} день",
    "two": "{} дня",
    "few": "{} дня",
    "many": "{} дней",
    "other": "{} дней"
  },
  "money": {
    "zero": "You not have money",
    "one": "You have {} dollar",
    "many": "You have {} dollars",
    "other": "You have {} dollars"
  }
}
```
⚠️ Key "other" required!

```dart
//Text widget with format
Text('money').plural(1000000, format: NumberFormat.compact(locale: context.locale.toString())) // output: You have 1M dollars

//String
print('day'.plural(21)); // output: 21 день

//Static function
var money = plural('money', 10.23) // output: You have 10.23 dollars
```

### 🔥 Delete save locale `deleteSaveLocale()`

Clears a saved locale from device storage

Example:

```dart
RaisedButton(
  onPressed: (){
    context.deleteSaveLocale();
  },              
  child: Text(LocaleKeys.reset_locale).tr(),
)
```

### 🔥 Get Easy localization widget properties

At any time, you can take the main [properties](#-easy-localization-widget-properties) of the Easy localization widget using [BuildContext].

Are supported: supportedLocales, fallbackLocale, localizationDelegates.

Example:

```dart
print(context.supportedLocales); // output: [en_US, ar_DZ, de_DE, ru_RU]

print(context.fallbackLocale); // output: en_US
```

## 💻 Code generation

Code generation supports only json files, for more information run in terminal `flutter pub run easy_localization:generate -h`

### Command line arguments

| Arguments | Short |  Default | Description |
| ------ | ------ |  ------ | ------ |
| --help | -h |  | Help info |
| --source-dir | -S | resources/langs | Folder containing localization files |
| --source-file | -s | First file | File to use for localization |
| --output-dir | -O | lib/generated | Output folder stores for the generated file |
| --output-file | -o | codegen_loader.g.dart | Output file name |
| --format | -f | json | Support json or keys formats |

### 🔌 Localization asset loader class

Steps:
1. Open your terminal in the folder's path containing your project 
2. Run in terminal `flutter pub run easy_localization:generate`
3. Change asset loader and past import.

```dart
import 'generated/codegen_loader.g.dart';
...
void main(){
  runApp(EasyLocalization(
    child: MyApp(),
    supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
    path: 'resources/langs',
    assetLoader: CodegenLoader()
  ));
}
...
```
4. All done!

### 🔑 Localization keys

If you have many localization keys and are confused, key generation will help you. The code editor will automatically prompt keys

Steps:
1. Open your terminal in the folder's path containing your project 
2. Run in terminal `flutter pub run easy_localization:generate -f keys -o locale_keys.g.dart`
3. Past import.

```dart
import 'generated/locale_keys.g.dart';
```
4. All done!

How to usage generated keys:

```dart
print(LocaleKeys.title.tr()); //String
//or
Text(LocaleKeys.title).tr(); //Widget
```

## Screenshots

| Arabic RTL | English LTR | Error widget |
| ---------- | ----------- | ------------ |
| ![Arabic RTL](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_ar.png "Arabic RTL") | ![English LTR](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_en.png "English LTR") | ![Error widget](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_err.png "Error widget") |

## Donations

We need your support. Projects like this can not be successful without support from the community. If you find this project useful, and would like to support further development and ongoing maintenance, please consider donating.

<p align="center">
  <a href="https://opencollective.com/flutter_easy_localization/donate" target="_blank">
    <img src="https://opencollective.com/flutter_easy_localization/donate/button@2x.png?color=blue" width=300 />
  </a>
</p>

### Sponsors

<img src="https://opencollective.com/flutter_easy_localization/tiers/backer.svg?avatarHeight=48"/>


### Contributors thanks

![contributors](https://contributors-img.firebaseapp.com/image?repo=aissat/easy_localization)
<a href="https://github.com/aissat/easy_localization/graphs/contributors"></a>
