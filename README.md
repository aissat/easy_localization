# easy_localization

Easy and Fast internationalizing your Flutter Apps,
this package simplify the internationalizing process using Json file 


### Why easy_localization?

simplify the internationalizing process in Flutter .

Internationalization by Using JSON Files .

## Changelog
### [1.2.1]
  - supported shared_preferences
  - Save selected localization
### [1.2.0]
  - Added property resolver for nested key translations
  - return translate key if the element or path not exist
  ```
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
    "other": "You clicked {} times!"
  }
}

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



you must create a folder in your project's root: the `path`. Some examples:

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
          EasylocaLizationDelegate(
              locale: data.locale,
              path: 'resources/langs'),
        ],
        supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
        locale: data.savedLocale,
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
          title: Text(AppLocalizations.of(context).tr('title')),
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
              new Text(AppLocalizations.of(context).plural('clicked', counter)),
              new FlatButton(
                onPressed: () async {
                  incrementCounter();
                },
                child: new Text(AppLocalizations.of(context).tr('clickMe')),
              ),
              new Text(
                AppLocalizations.of(context).tr('profile.reset_password.title'),
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

<td style="text-align: center">
<img alt="Arbic RTL" src="https://github.com/aissat/easy_localization/blob/master/screenshots/Screenshot_ar.png?raw=true" width="200" />
</td>

<td style="text-align: center">
<img alt="English LTR" src="https://github.com/aissat/easy_localization/blob/master/screenshots/Screenshot_en.png?raw=true" width="200" />
</td>


Donations
---------

This project needs you! If you would like to support this project's further development, the creator of this project or the continuous maintenance of this project, feel free to donate. Your donation is highly appreciated (and I love food, coffee and beer). Thank you!
**PayPal**

* **[Donate $5](https://paypal.me/aissatabdelwahab/5)**: Thank's for creating this project, here's a coffee for you!
* **[Donate $10](https://paypal.me/aissatabdelwahab/10)**: Wow, I am stunned. Let me take you to the movies!
* **[Donate $15](https://paypal.me/aissatabdelwahab/15)**: I really appreciate your work, let's grab some lunch!
* **[Donate $25](https://paypal.me/aissatabdelwahab/25)**: That's some awesome stuff you did right there, dinner is on me!
Of course, you can also choose what you want to donate, all donations are awesome!
## Contributors thanks!

  - [iwansugiarto](https://github.com/javico2609)
  - [javico2609](https://github.com/iwansugiarto)