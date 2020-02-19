# easy_localization

Easy and Fast internationalizing your Flutter Apps,
this package simplify the internationalizing process using Json file

## Why easy_localization

- simplify and easy the internationalizing process in Flutter.
- Using JSON Files .
- Load translations from remote or backend.
- save App state.
- Supported `plural`
- Supported `gender`
- Supported Flutter extension.

## Changelog

### [1.4.0]

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

### [1.3.5]

- merge  `gender()`  and `tr()`  .

  ``` json
  {
    "switch":{
      "male": "Hi man ;)",
      "female": "Hello girl :)"
    }
  }
  ```

  ``` dart
  Text(
    AppLocalizations.of(context).tr('switch', gender: _gender ? "female" : "male"),
  ),
  ```

- use parameters `args` for gender.
  
  ``` json
  {
    "switch":{
      "male": "Hi man ;) {}",
      "female": "Hello girl :) {}"
    }
  }
  ```

  ``` dart
  Text(
    AppLocalizations.of(context).tr('switch', args:["Naama"] gender: _gender ? "female" : "male"),
  ),

### [1.3.4]

- adeed Gender [female,male]  `gender()`  .

  ``` json
  {
    "switch":{
      "male": "Hi man ;)",
      "female": "Hello girl :)"
    }
  }
  ```

  ``` dart
  Text(
    AppLocalizations.of(context).gender('switch', _gender ? "female" : "male"),
  ),
  ```

### [1.3.3+1]

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

### [1.3.3]

- removed  `data.savedLocale`.
- optimized and clean code
- fixed many issues

### [1.3.2]

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

### [1.3.1]

- add useOnlyLangCode flag

### [1.3.0]

- Load translations from remote or backend
- fixed many issues

### [1.2.1]

- supported shared_preferences
- Save selected localization

### [1.2.0]

- Added property resolver for nested key translations
- return translate key if the element or path not exist

``` json
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
  }
}
```

``` dart
new Text(
  AppLocalizations.of(context).tr('profile.reset_password.title'),
 ),
```

### [1.0.4]

- Added Support country codes

### [1.0.3]

- Updated `tr()` function added Multi Argument

### [1.0.2]

- Added string pluralisation .
- Added Argument to `tr()` function.

## Getting Started

### Configuration

add

```yaml

easy_localization: <last_version>

```

#### Load translations from local assets

You must create a folder in your project's root: the `path`. Some examples:

> /assets/"langs" , "i18n", "locale" or anyname ...
>
> /resources/"langs" , "i18n", "locale" or anyname ...

Inside this folder, must put the _json_ files containing the translated keys :

> `path`/${languageCode}-${countryCode}.json

example:

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
          title: Text(tr("title")),
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
              Text(
                'switch.with_arg',
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 19,
                    fontWeight: FontWeight.bold),
              ).tr(args: ["aissat"], gender:  _gender ? "female" : "male"),
              Text(
                tr('switch', gender:  _gender ? "female" : "male"),
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
              Text(tr('msg', args: ['aissat', 'Flutter'])),
              // Text(plural('clicked', counter)),
              Text('clicked').plural(counter),
              FlatButton(
                onPressed: () {
                  incrementCounter();
                },
                child: Text('clickMe').tr(),
              ),
              // Text(
              //   AppLocalizations.of(context).tr('profile.reset_password.title'),
              // ),
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

#### Load translations from backend

You need to have backend endpoint (`loadPath`) where resources get loaded from and your endpoint must containing the translated keys.

example:

```dart
String loadPath = 'https://raw.githubusercontent.com/aissat/easy_localization/master/example/resources/langs'

```

> '${`loadPath`}/${languageCode}-${countryCode}.json'

- '<https://raw.githubusercontent.com/aissat/easy_localization/master/example/resources/langs/en-US.json'>
- '<https://raw.githubusercontent.com/aissat/easy_localization/master/example/resources/langs/ar-DZ.json'>

The next step :

```dart
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
              loadPath: 'https://raw.githubusercontent.com/aissat/easy_localization/master/example/resources/langs'),
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
  incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('title')),
          actions: <Widget>[
            FlatButton(
              child: Text("English"),
              color: Localizations.localeOf(context).languageCode == "en"
                  ? Colors.lightBlueAccent
                  : Colors.blue,
              onPressed: () {
                this.setState(() {
                  data.changeLocale(Locale("en","US"));
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
                  data.changeLocale(Locale("ar","DZ"));
                  print(Localizations.localeOf(context).languageCode);
                });
              },
            )
          ],
        ),
        body: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(AppLocalizations.of(context)
                  .tr('msg', args: ['aissat', 'Flutter'])),
              new Text(plural('clicked', counter)),
              new FlatButton(
                onPressed: () async {
                  incrementCounter();
                },
                child: new Text(tr('clickMe')),
              ),
              new Text(
                tr('profile.reset_password.title'),
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

## Screenshots

 Arbic RTL | English LTR
--- | ---
![alt text](https://github.com/aissat/easy_localization/blob/master/screenshots/Screenshot_ar.png?raw=true "Arbic RTL") | ![alt text](https://github.com/aissat/easy_localization/blob/master/screenshots/Screenshot_en.png?raw=true "English LTR")

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

- [iwansugiarto](https://github.com/javico2609)
- [javico2609](https://github.com/iwansugiarto)
- [Taym95](https://github.com/Taym95)
