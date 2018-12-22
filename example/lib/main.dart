import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() => runApp(LocaleInherited(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = LocaleProvider.of(context).data;
    return LocaleProvider(
      data: data,
      child: MaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          //app-specific localization
          EasylocalizationDelegate(
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
  @override
  Widget build(BuildContext context) {
    var data = LocaleProvider.of(context).data;
    return LocaleProvider(
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
          child: Text(AppLocalizations.of(context).trans('msg')),
        ),
      ),
    );
  }
}
