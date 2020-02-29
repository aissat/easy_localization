import 'package:example/my_flutter_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() => runApp(EasyLocalization(
      child: MyApp(),
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
      fallbackLocale: Locale('en', 'US'),
      path: 'resources/langs',
      // useOnlyLangCode: true,
      // optional assetLoader default used is RootBundleAssetLoader which uses flutter's assetloader
      // assetLoader: RootBundleAssetLoader()
      // assetLoader: NetworkAssetLoader()
      // assetLoader: TestsAssetLoader()
      // assetLoader: FileAssetLoader()
      // assetLoader: StringAssetLoader()
    ));

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
      // locale is either the deviceLocale or the MaterialApp widget locale.
      // This function is responsible for returning a locale that is supported by your app
      // if the app is opened for the first time and we only have the deviceLocale information.
      localeResolutionCallback:
          EasyLocalization.of(context).localeResolutionCallback,
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
    return Scaffold(
      appBar: AppBar(
        title: Text("title").tr(),
        //Text(AppLocalizations.of(context).tr('title')),
        actions: <Widget>[
          FlatButton(
            child: Text("English"),
            color: Localizations.localeOf(context).languageCode == "en"
                ? Colors.lightBlueAccent
                : Colors.blue,
            onPressed: () {
              this.setState(() {
                EasyLocalization.of(context)
                    .changeLocale(locale: Locale("en", "US"));
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
                EasyLocalization.of(context)
                    .changeLocale(locale: Locale("ar", "DZ"));
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
                        locale: Localizations.localeOf(context).toString(),
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
