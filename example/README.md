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

### example/lib/main.dart

```dart
import 'package:example/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() => runApp(EasyLocalization(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          //app-specific localization
          EasyLocalizationDelegate(
            locale: data.locale,
            path: 'resources/langs',
            //useOnlyLangCode: true,
            // loadPath: 'https://raw.githubusercontent.com/aissat/easy_localization/master/example/resources/langs'
          ),
        ],
        supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
        locale: data.locale,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Easy localization'),
      ),
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
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(
        appBar: AppBar(
          title: Text('title').tr(),
          actions: <Widget>[
            FlatButton(
              child: Text("English"),
              color: Localizations.localeOf(context).languageCode == "en"
                  ? Colors.lightBlueAccent
                  : Colors.blue,
              onPressed: () {
                this.setState(() {
                  data.changeLocale(Locale("en", "US"));
                  print(Localizations.localeOf(context).languageCode);
                });
              },
            ),
            FlatButton(
              child: Text("عربي"),
              color: Localizations.localeOf(context).languageCode == "ar"
                  ? Colors.lightBlueAccent
                  : Colors.blue,
              onPressed: () {
                this.setState(() {
                  data.changeLocale(Locale("ar", "DZ"));
                  print(Localizations.localeOf(context).languageCode);
                });
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 1,
              ),
              Text('switch.with_arg',
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 19,
                    fontWeight: FontWeight.bold),
              ).tr(args: ["aissat"], gender:  _gender ? "female" : "male"),
              Text('switch',
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ).tr(gender:  _gender ? "female" : "male"),
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
              Text(
                'profile.reset_password.title',
              ).tr(),
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
      ),
    );
  }
}

```
