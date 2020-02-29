import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'localization.dart';

class _EasyLocalizationProvider extends InheritedWidget {
  _EasyLocalizationProvider({Key key, this.child, this.data})
      : super(key: key, child: child);
  final _EasyLocalizationState data;
  final Widget child;

  static _EasyLocalizationProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_EasyLocalizationProvider>();
  }

  @override
  bool updateShouldNotify(_EasyLocalizationProvider oldWidget) => true;
}

class EasyLocalization extends StatefulWidget {
  final Widget child;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final _EasyLocalizationDelegate delegate;
  final bool useOnlyLangCode;
  final String path;
  final AssetLoader assetLoader;

  EasyLocalization({
    @required this.child,
    @required this.supportedLocales,
    @required this.fallbackLocale,
    @required this.path,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
  })  : assert(supportedLocales.contains(fallbackLocale)),
        delegate = _EasyLocalizationDelegate(
          path: path,
        );

  _EasyLocalizationState createState() => _EasyLocalizationState();

  static _EasyLocalizationState of(BuildContext context) =>
      _EasyLocalizationProvider.of(context).data;
}

class _EasyLocalizationState extends State<EasyLocalization> {
  Locale _locale;
  SharedPreferences _preferences;
  Locale get locale => _locale;
  List<Locale> get supportedLocales => widget.supportedLocales;
  _EasyLocalizationDelegate get delegate => widget.delegate;

  @override
  void initState() {
    super.initState();
    changeLocale();
  }

  // locale is either the deviceLocale or the MaterialApp widget locale.
  // This function is responsible for returning a locale that is supported by your app
  // if the app is opened for the first time and we only have the deviceLocale information.
  Locale localeResolutionCallback(
      Locale locale, Iterable<Locale> supportedLocales) {
    if (supportedLocales != widget.supportedLocales)
      throw new Exception(
          "You haven't given EasyLocalization.supportedLocales to MaterialApp ssupportedLocales property");

    if (supportedLocales.contains(locale)) return locale;

    return widget.fallbackLocale;
  }

  void changeLocale({Locale locale}) async {
    var _defaultLocal;
    print(
        "================== changeLocale ${locale?.toLanguageTag()}===================");
    try {
      _preferences = await SharedPreferences.getInstance();
      if (locale == null) {
        var _codeLang = _preferences.getString('codeLa');
        var _codeCoun = _preferences.getString('codeCa');
        if (_codeLang == null) {
          var currentLocale = Intl.getCurrentLocale().split("_");
          _defaultLocal = Locale(currentLocale[0], currentLocale[1]);
        } else {
          _defaultLocal = Locale(_codeLang, _codeCoun);
        }
      } else
        _defaultLocal = locale;
      await _preferences.setString('codeCa', _defaultLocal.countryCode);
      await _preferences.setString('codeLa', _defaultLocal.languageCode);

      print(_defaultLocal.toString());

      setState(() {
        _locale = _defaultLocal;
      });
    } catch (e) {
      print(e);
    }
    print("================== changeLocale //===================");
  }

  @override
  Widget build(BuildContext context) => _EasyLocalizationProvider(
        data: this,
        child: widget.child,
      );
}

class _EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final String path;
  final String loadPath;
  final AssetLoader assetLoader;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  _EasyLocalizationDelegate({
    this.path,
    this.loadPath,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
  });

  @override
  bool isSupported(Locale locale) => locale != null;

  @override
  Future<Localization> load(Locale value) async {
    await Localization.load(
      value,
      path: path,
      useOnlyLangCode: useOnlyLangCode,
      assetLoader: assetLoader,
    );
    return Localization.instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}
