# example

## example/resources/langs/ar-DZ.json

```json
{
  "title": "السلام",
  "msg":"السلام عليكم يا {} في عالم {}",
  "clickMe":"إضغط هنا",
  "profile": {
    "reset_password": {
      "title": "اعادة تعين كلمة السر",
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
  "switch":{
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
      "title": "Reset Password",
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
  "switch":{
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
import 'dart:developer';

import 'package:example/lang_view.dart';
import 'package:example/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main(){
  
  // WidgetsFlutterBinding.ensureInitialized();
  //await EasyLocalization.ensureInitialized();

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
    log( EasyLocalization.of(context).locale.toString(), name: this.toString()+"# locale" );
    log( Intl.defaultLocale.toString(), name: this.toString()+"# Intl.defaultLocale" );
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
        //Text(AppLocalizations.of(context).tr('title')),
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

### [example/lib/lang_view.dart](https://github.com/aissat/easy_localization/blob/master/example/lib/lang_view.dart)

```dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
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
                "Language Menu",
                style: TextStyle(
                  color: Color.fromARGB(255, 166, 166, 166),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 25),
              margin: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                "language",
              ),
            ),
            buildDivider(),
            buildSwitchListTileMenuItem(
                context: context,
                title: "عربي",
                subtitle: "عربي",
                locale: Locale("ar", "DZ")),
            buildDivider(),
            buildSwitchListTileMenuItem(
                context: context,
                title: "English",
                subtitle: "English",
                locale: Locale("en", "US")),
            buildDivider(),
          ],
        ),
      ),
    );
  }

  Container buildDivider() => Container(
        margin: EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Divider(
          color: Colors.grey,
        ),
      );

  Container buildSwitchListTileMenuItem(
      {BuildContext context, String title, String subtitle, Locale locale}) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
      ),
      child: ListTile(
          dense: true,
          // isThreeLine: true,
          title: Text(
            title,
          ),
          subtitle: Text(
            subtitle,
          ),
          onTap: () {
            log(locale.toString(), name: this.toString());
            EasyLocalization.of(context).locale = locale;
          }),
    );
  }
}
```
