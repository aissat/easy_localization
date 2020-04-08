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
Easy and Fast internationalizing your Flutter Apps,
this package simplify the internationalizing process using Json file
</p>

## Why easy_localization

- [x] simplifying and making easy the internationalizing process in Flutter.
- [x] Using JSON Files .
- [x] Error widget
- [x] Based on Bloc Archi
- [x] Load locale from remote or backend.
- [x] Automatically saving App state (save/restor the selected locale).
- [x] Supports `plural`
- [x] Supports `gender`
- [x] Supports Flutter extension.
- [x] Supports change locale dynamically .
- [x] Supports for RTL locales
- [x] Supports for nesting
- [x] Customization AssetLoader localizations
- [x] Support for context
- [x] Testable and easy maintenence

## [Changelog](https://github.com/aissat/easy_localization/blob/master/CHANGELOG.md)

### [2.1.0]

- Added Error widget.
- fixed many issues.
- Based on Bloc.

### [2.0.2]

- fixed many issues
- optimized and clean code more stability

### [2.0.1]

- Added change locale dynamically `saveLocale` default value `true`
- fixed many issues

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

Inside this folder, must put the _json_ files containing the translated keys :

> `path`/${languageCode}-${countryCode}.json

[example:](https://github.com/aissat/easy_localization/tree/master/example)

- en.json to en-US.json
- ar.json to ar-DZ.json
- zh.json to zh-CN.json
- zh.json to zh-TW.json

must declare the subtree in your **_pubspec.yaml_** as assets:

```yaml
flutter:
  assets:
    - {`path`/{languageCode}-{countryCode}.json}
```

The next step :

```dart
import 'dart:developer';

import 'package:example/lang_view.dart';
import 'package:example/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main(){
  runApp(EasyLocalization(
    child: MyApp(),
    supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
    path: 'resources/langs',
    // fallbackLocale: Locale('en', 'US'),
    // useOnlyLangCode: true,
    // optional assetLoader default used is RootBundleAssetLoader which uses flutter's assetloader
    // assetLoader: RootBundleAssetLoader()
    // assetLoader: NetworkAssetLoader()
    // assetLoader: TestsAssetLoader()
    // assetLoader: FileAssetLoader()
    // assetLoader: StringAssetLoader()
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        EasyLocalization.of(context).delegate,
      ],
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

to change Locale

```dart
EasyLocalization.of(context).locale = locale;
```

#### Load translations from Customization AssetLoader

for example You need to have backend endpoint (`loadPath`) where resources get loaded from and your endpoint must containing the translated keys.

example:

```dart
class NetworkAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String localePath) async {
    return http
        .get(localePath)
        .then((response) => json.decode(response.body.toString()));
  }
```

The next step :

```dart
...
void main(){
  runApp(EasyLocalization(
    child: MyApp(),
    supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
    path: 'https://raw.githubusercontent.com/aissat/easy_localization/master/example/resources/langs',
    assetLoader: NetworkAssetLoader()
    // fallbackLocale: Locale('en', 'US'),
    // useOnlyLangCode: true,
    // optional assetLoader default used is RootBundleAssetLoader which uses flutter's assetloader
    // assetLoader: RootBundleAssetLoader()
    // assetLoader: TestsAssetLoader()
    // assetLoader: FileAssetLoader()
    // assetLoader: StringAssetLoader()
  ));
}
...
```

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
