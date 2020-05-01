<h1 align="center"> Easy localization </h1>

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

<p align="center"> 
Easy and Fast internationalization for your Flutter Apps,
this package simplifies the internationalizing process
</p>

## Why easy_localization

- [x] simplifies and makes the internationalizing process in Flutter much easier.
- [x] Uses [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) JSON, CSV, Yaml, Xml Files .
- [x] Error widget
- [x] Based on Bloc architecture.
- [x] Code generation for localization files.
- [x] Load locale from remote or backend.
- [x] Automatically saving App state (save/restor/reset the selected locale).
- [x] Supports `plural`
- [x] Supports `gender`
- [x] Supports Flutter extension.
- [x] Supports changing locale dynamically.
- [x] Supports RTL locales.
- [x] Supports nesting.
- [x] Customizable localizations AssetLoader.
- [x] Supports context.
- [x] Testable and maintainable.


## [Changelog](https://github.com/aissat/easy_localization/blob/master/CHANGELOG.md)

### [2.2.1]

- Added `startLocale` .

### [2.2.0]

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

### [2.1.0]

- Added Error widget.
- fixed many issues.
- Adopted Bloc architecture.

### [2.0.2]

- fixed many issues.
- optimized and clean code for more stability.

### [2.0.1]

- Added change locale dynamically `saveLocale` default value `true`.
- fixed many issues.

## Getting Started

### Configuration

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  # stable version install from https://pub.dev/packages
  easy_localization: <last_version>

  # Dev version install from git REPO
  easy_localization:
    git: https://github.com/aissat/easy_localization.git

```

#### Load translations from local assets

You must create a folder in your project's root: the `path`. Some examples:

> /assets/"langs" , "i18n", "locale" or anyname ...
>
> /resources/"langs" , "i18n", "locale" or anyname ...

Inside this folder, must put the _json_ or _csv_ files containing the translated keys:

> `path`/${languageCode}-${countryCode}.${formatFile}

[example:](https://github.com/aissat/easy_localization/tree/master/example)

- en.json or en-US.json
- ar.json or ar-DZ.json
- langs.csv

must declare the subtree in your **_pubspec.yaml_** as assets:

```yaml
flutter:
  assets:
    - {`path`/{languageCode}-{countryCode}.{formatFile}}
```

The next step :

```dart
import 'dart:developer';

import 'package:example/lang_view.dart';
import 'package:example/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

//import 'generated/codegen_loader.g.dart';

void main(){
  runApp(EasyLocalization(
    child: MyApp(),
    supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')], // [Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK')]
    path: 'resources/langs',
    // fallbackLocale: Locale('en', 'US'),
    // saveLocale: false,
    // useOnlyLangCode: true,
    // preloaderColor: Colors.black,

    // optional assetLoader default used is RootBundleAssetLoader which uses flutter's assetloader
    // install easy_localization_loader for enable custom loaders
    // assetLoader: RootBundleAssetLoader()
    // assetLoader: HttpAssetLoader()
    // assetLoader: FileAssetLoader()
    assetLoader: CsvAssetLoader()
    // assetLoader: YamlAssetLoader() //multiple files
    // assetLoader: YamlSingleAssetLoader() //single file
    // assetLoader: XmlAssetLoader() //multiple files
    // assetLoader: XmlSingleAssetLoader() //single file
    // assetLoader: CodegenLoader()
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: EasyLocalization.of(context).delegates,
      supportedLocales: EasyLocalization.of(context).supportedLocales,
      locale: EasyLocalization.of(context).locale,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Easy localization'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;
  bool _gender = true;

  incrementCounter() {
    setState(() {
      counter++;
    });
  }

  switchGender(bool val) {
    setState(() {
      _gender = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    log(tr("title"), name: this.toString() );
    return Scaffold(
      appBar: AppBar(
        title: Text("title").tr(context: context),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.language),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LanguageView(), fullscreenDialog: true),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 1,
            ),
            Text(
              'switch.with_arg',
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 19,
                  fontWeight: FontWeight.bold),
            ).tr(args: ["aissat"], gender: _gender ? "female" : "male"),
            Text(
              tr('switch', gender: _gender ? "female" : "male"),
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(MyFlutterApp.male_1),
                Switch(value: _gender, onChanged: switchGender),
                Icon(MyFlutterApp.female_1),
              ],
            ),
            Spacer(
              flex: 1,
            ),
            Text('msg').tr(args: ['aissat', 'Flutter']),
            Text('clicked').plural(counter),
            FlatButton(
              onPressed: () {
                incrementCounter();
              },
              child: Text('clickMe').tr(),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
                plural('amount', counter,
                    format: NumberFormat.currency(
                        locale: Intl.defaultLocale,
                        symbol: "€")),
                style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: 20,
            ),
            Text('profile.reset_password.title').tr(),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: incrementCounter,
        child: Text('+1'),
      ),
    );
  }
}
```

How to change Locale:

```dart
EasyLocalization.of(context).locale = locale;
```

#### Loading translations from other resources

You can use JSON,CSV,HTTP,XML,Yaml files, etc.

See [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) for more info.

#### Code generation of localization files

Code generation supports json and csv files, for more information run in terminal `flutter pub run easy_localization:generate -h`

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
    assetLoader: assetLoader: CodegenLoader()
  ));
}
...
```
4. All done!

## Screenshots

 Arbic RTL | English LTR
--- | ---
![alt text](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_ar.png "Arbic RTL")|![alt text](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_en.png "English LTR")

 Русский | Dutch
--- | ---
![alt text](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_ru.png "Русский ")|![alt text](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_de.png "Dutch")

 Error widget | Language widget
--- | ---
![alt text](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_err.png "Error")|![alt text](https://raw.githubusercontent.com/aissat/easy_localization/master/screenshots/Screenshot_lang.png "Language")

### Donations

---------

We need your support. Projects like this can not be successful without support from the community. If you find this project useful, and would like to support further development and ongoing maintenance, please consider donating. Devs gotta eat!
**PayPal**

- **[Donate $5](https://paypal.me/aissatabdelwahab/5)**:
  Thank's for creating this project, here's a coffee for you!

- **[Donate $10](https://paypal.me/aissatabdelwahab/10)**:
  Wow, I am stunned. Let me take you to the movies!

- **[Donate $15](https://paypal.me/aissatabdelwahab/15)**:
  I really appreciate your work, let's grab some lunch!

- **[Donate $25](https://paypal.me/aissatabdelwahab/25)**:
  That's some awesome stuff you did right there, dinner is on me!

Of course, you can also choose what you want to donate. All donations are very much appreciated!

## Contributors thanks

![contributors](https://contributors-img.firebaseapp.com/image?repo=aissat/easy_localization)
<a href="https://github.com/aissat/easy_localization/graphs/contributors"></a>
