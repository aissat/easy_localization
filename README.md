# easy_localization

Easy and Fast internationalizing your Flutter Apps,
this package simplify the internationalizing process using Json file 


### Why easy_localization?

simplify the internationalizing process in Flutter .

Internationalization by Using JSON Files .

## Changelog
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

> `path`/{languageCode}.json

must declare the subtree in your **_pubspec.yaml_** as assets:

```yaml
flutter:
  assets:
    - {`path`/{languageCode}.json}
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
              locale: data.locale ?? Locale('en'), path: 'resources/langs'),
        ],
        supportedLocales: [Locale('en'), Locale('ar')],
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
          title: Text(AppLocalizations.of(context).tr('title')),
          actions: <Widget>[
            FlatButton(
              child: Text("English"),
              color: Localizations.localeOf(context).languageCode == "en"
                  ? Colors.lightBlueAccent
                  : Colors.blue,
              onPressed: () {
                this.setState(() {
                  data.changeLocale(Locale("en"));
                  print(Localizations.localeOf(context).languageCode);
                });
              },
            ),
            FlatButton(
              child: Text("عربى"),
              color: Localizations.localeOf(context).languageCode == "ar"
                  ? Colors.lightBlueAccent
                  : Colors.blue,
              onPressed: () {
                this.setState(() {
                  data.changeLocale(Locale("ar"));
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
              new Text(AppLocalizations.of(context).tr('msg',args: ['aissat','flutter'])),
              new Text(AppLocalizations.of(context).plural('clicked',counter)),
              new FlatButton(
                  onPressed: () async {
                    incrementCounter();
                  },
                  child: new Text(AppLocalizations.of(context).tr('clickMe')),)
            
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: incrementCounter,child: Text('+1'),),
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