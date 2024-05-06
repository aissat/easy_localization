# example

## example/resources/langs/ar-DZ.json

```json
{
  "title": "السلام",
  "msg":"السلام عليكم يا {} في عالم {}",
  "clickMe":"إضغط هنا",
  "profile": {
    "reset_password": {
      "label":  "اعادة تعين كلمة السر",
      "username": "المستخدم",
      "password": "كلمة السر"
    }
  },
    "clicked": {
    "zero": "{} نقرة!",
    "one": "{} نقرة!",
    "two":"{} نقرات!",
    "few":"{} نقرات!",
    "many":"{} نقرة!",
    "other": "{} نقرة!"
  },
  "gender":{
    "male": " مرحبا يا رجل",
    "female": " مرحبا بك يا فتاة",
    "with_arg":{
      "male": "{} مرحبا يا رجل",
      "female": "{} مرحبا بك يا فتاة"
    }
  }
}
```

## example/resources/langs/en-US.json

```json
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
    "two":"You clicked {} times!",
    "few":"You clicked {} times!",
    "many":"You clicked {} times!",
    "other": "You clicked {} times!"
  },
  "gender":{
    "male": "Hi man ;) ",
    "female": "Hello girl :)",
    "with_arg":{
      "male": "Hi man ;) {}",
      "female": "Hello girl :) {}"
    }
  }
}

```

### [example/lib/main.dart](https://github.com/aissat/easy_localization/blob/master/example/lib/main.dart)

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'generated/locale_keys.g.dart';
import 'language_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: [
      Locale('en', 'US'),
      Locale('ar', 'DZ'),
      Locale('de', 'DE'),
      Locale('ru', 'RU')
    ],
    path: 'resources/langs',
    child: _MyApp(),
    // fallbackLocale: Locale('en', 'US'),
    // startLocale: Locale('de', 'DE'),
    // saveLocale: false,
    // useOnlyLangCode: true,

    // optional assetLoader default used is RootBundleAssetLoader which uses flutter's assetloader
    // install easy_localization_loader for enable custom loaders
    // assetLoader: RootBundleAssetLoader()
    // assetLoader: HttpAssetLoader()
    // assetLoader: FileAssetLoader()
    // assetLoader: CsvAssetLoader()
    // assetLoader: YamlAssetLoader() //multiple files
    // assetLoader: YamlSingleAssetLoader() //single file
    // assetLoader: XmlAssetLoader() //multiple files
    // assetLoader: XmlSingleAssetLoader() //single file
    // assetLoader: CodegenLoader()
  ));
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  int counter = 0;

  bool _gender = true;

  void _incrementCounter() => setState(() => counter++);

  void _switchGender(bool value) => setState(() => _gender = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.title).tr(),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LanguageView(),
                  fullscreenDialog: true,
                ),
              );
            },
            child: Icon(
              Icons.language,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(flex: 1),
            Text(
              LocaleKeys.gender_with_arg,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ).tr(args: ['aissat'], gender: _gender ? 'female' : 'male'),
            Text(
              tr(LocaleKeys.gender, gender: _gender ? 'female' : 'male'),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.male),
                Switch(value: _gender, onChanged: _switchGender),
                Icon(Icons.female),
              ],
            ),
            Spacer(flex: 1),
            Text(LocaleKeys.msg).tr(args: ['aissat', 'Flutter']),
            Text(LocaleKeys.msg_named).tr(
              namedArgs: {'lang': 'Dart'},
              args: ['Easy localization'],
            ),
            Text(LocaleKeys.clicked).plural(counter),
            TextButton(
              onPressed: () => _incrementCounter(),
              child: Text(LocaleKeys.clickMe).tr(),
            ),
            SizedBox(height: 15),
            Text(
              plural(
                LocaleKeys.amount,
                counter,
                format: NumberFormat.currency(
                  locale: Intl.defaultLocale,
                  symbol: '€',
                ),
              ),
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.resetLocale(),
              child: Text(LocaleKeys.reset_locale).tr(),
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: Text('+1'),
      ),
    );
  }
}

```

### [example/lib/lang_view.dart](https://github.com/aissat/easy_localization/blob/master/example/lib/language_view.dart)

```dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 26),
              margin: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                'Choose language',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            _SwitchListTileMenuItem(
              title: 'عربي',
              subtitle: 'عربي',
              locale: context.supportedLocales[1],
            ),
            _Divider(),
            _SwitchListTileMenuItem(
              title: 'English',
              subtitle: 'English',
              locale: context.supportedLocales[0],
            ),
            _Divider(),
            _SwitchListTileMenuItem(
              title: 'German',
              subtitle: 'German',
              locale: context.supportedLocales[2],
            ),
            _Divider(),
            _SwitchListTileMenuItem(
              title: 'Русский',
              subtitle: 'Русский',
              locale: context.supportedLocales[3],
            ),
            _Divider(),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Divider(color: Colors.grey),
    );
  }
}

class _SwitchListTileMenuItem extends StatelessWidget {
  final String title;

  final String subtitle;

  final Locale locale;

  const _SwitchListTileMenuItem({
    required this.title,
    required this.subtitle,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(
        border: locale == context.locale
            ? Border.all(color: Colors.blueAccent)
            : null,
      ),
      child: ListTile(
        dense: true,
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () async {
          log(locale.toString(), name: toString());

          await context.setLocale(locale);

          Navigator.pop(context);
        },
      ),
    );
  }
}
```
