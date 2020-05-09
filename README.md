<p align="center"><img src="./logo/logo.svg" width="600"/></p>
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
![Sponsors](https://opencollective.com/flutter_easy_localization/tiers/backer/badge.svg?label=sponsors&color=brightgreen)
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

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  easy_localization: <last_version>
```


Add translation files as local assets to `path`, e.g:

```
/assets/translations
```

Add translation files like this

```
{path}/{languageCode}.{ext}
{path}/{languageCode}-{countryCode}.{ext}
```

Example:

```
/assets/translations/en.json
/assets/translations/en-US.json
```

Declare your assets localization directory in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/translations/
```

### Loading translations from other resources

You can use JSON,CSV,HTTP,XML,Yaml files, etc.

See [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) for more info.

### Note on **iOS**

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

### Configuration app

Add EasyLocalization widget like in example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() {
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('de', 'DE')],
      path: 'assets/translations',
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

## Usage

### Change Locale:

```dart
context.locale = locale;
```

## Code generation

Code generation keys supports json files, for more information run in terminal `flutter pub run easy_localization:generate -h`

### Localization asset loader class

Example:

```
4. All done!

### Localization keys

If you have many localization keys and are confused, key generation will help you. The code editor will automatically prompt keys

Steps:
1. Open your terminal in the folder's path containing your project 
2. Run in terminal `flutter pub run easy_localization:generate -f keys -o locale_keys.g.dart`
3. Past import.

```dart
import 'generated/locale_keys.g.dart';
```

#### Code generation

Run `flutter pub run easy_localization:generate -h` for help.

## Screenshots

 Arabic RTL | English LTR | Error widget
--- | --- | ---
![Arabic RTL](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_ar.png "Arabic RTL")|![English LTR](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_en.png "English LTR")|![Error widget](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_err.png "Error widget")

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
