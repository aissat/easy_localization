# example

### example/resources/langs/ar.json

```json
{
  "title": "السلام",
  "msg":"السلام عليكم يا {}",
  "clickMe":"إضغط هنا",
  "clicked": {
    "zero": "{} نقرة!",
    "one": "{} نقرة!",
    "other": "{} نقرة!"
  }
}
```
### example/resources/langs/ar.json
```json
{
  "title": "Hello",
  "msg":"Hello {}",
  "clickMe":"Click me",
  "clicked": {
    "zero": "You clicked {} times!",
    "one": "You clicked {} time!",
    "other": "You clicked {} times!"
  }
}
```

### example/lib/main.dart
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
 int clicked = 0;
  incrementCounter() {
    setState(() {
      clicked++;
    });
  }
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).trans('title')),
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
              new Text(AppLocalizations.of(context).trans('msg',arg: 'aissat')),
              new Text(AppLocalizations.of(context).plural('clicked',clicked)),
              new FlatButton(
                  onPressed: () async {
                    incrementCounter();
                  },
                  child: new Text(AppLocalizations.of(context).trans('clickMe')),)
            
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: incrementCounter,child: Text('+1'),),
      ),
    );
  }
}

```
