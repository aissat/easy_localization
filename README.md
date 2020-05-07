# Easy localization

Easy internationalization for Flutter apps

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

## Features

- Easy translations for many languages
- Load translations as JSON, CSV, Yaml, Xml using [easy\_localization\_loader](https://github.com/aissat/easy_localization_loader)
- React and persist to locale changes
- Supports `plural`, `gender`, nesting, RTL locales and more
- Optional code generation
- Error widget for missing translations
- Extension methods on `Text`
- Uses BLoC pattern

See [example](example) and [CHANGELOG.md](CHANGELOG.md).

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  easy_localization:

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
/assets/translations/nb.json
```

or as a single CVS file using [easy_localization_loader](https://github.com/aissat/easy_localization_loader)

> With [easy_localization_loader](https://github.com/aissat/easy_localization_loader), you can load translations using various file format like; JSON, CSV, XML, Yaml files, and even load remote assets using HTTP. You can also create a custom assset loader.

```
{path}/translations.cvs
```

Describe translations in your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/translations/
```

Then in your code use one of the following `tr` methods:

```dart
  Text(tr('hi'))
  Text('hi').tr()
  'hi'.tr()
```

#### A simple example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() {
  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: [Locale('en'), Locale('nb')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      assetLoader: RootBundleAssetLoader(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        EasyLocalization.of(context).delegate,
      ],
      supportedLocales: EasyLocalization.of(context).supportedLocales,
      locale: EasyLocalization.of(context).locale,
      home: Scaffold(
        body: Center(
          child: Text('hi').tr(),
        ),
      ),
    );
  }
}
```

#### Note on **iOS**

For translation to work on **iOS** you need to add supported locales to 
`ios/Runner/Info.plist` as described [here](https://flutter.dev/docs/development/accessibility-and-localization/internationalization#specifying-supportedlocales).

Example:

```
<key>CFBundleLocalizations</key>
<array>
	<string>en</string>
	<string>nb</string>
</array>
```

#### Code generation

Run `flutter pub run easy_localization:generate -h` for help.

See [CODEGEN.md](CODEGEN.md) for usage.

## Screenshots

 Arbic RTL | English LTR
--- | ---
![](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_ar.png)|![](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_en.png)

## Donations

If you would like to support further development and ongoing maintenance, please consider donating.

**PayPal**

- **[Donate $5](https://paypal.me/aissatabdelwahab/5)**:
  Thank's for creating this project, here's a coffee for you!

- **[Donate $10](https://paypal.me/aissatabdelwahab/10)**:
  Wow, I am stunned. Let me take you to the movies!

- **[Donate $15](https://paypal.me/aissatabdelwahab/15)**:
  I really appreciate your work, let's grab some lunch!

- **[Donate $25](https://paypal.me/aissatabdelwahab/25)**:
  That's some awesome stuff you did right there, dinner is on me!

All donations are very much appreciated!

## Thanks to

![contributors](https://contributors-img.firebaseapp.com/image?repo=aissat/easy_localization)
<a href="https://github.com/aissat/easy_localization/graphs/contributors"></a>
