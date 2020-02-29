import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'localization.dart';

// :( see line 55
Locale _savedLocale;

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
            path: path, supportedLocales: supportedLocales);

  _EasyLocalizationState createState() => _EasyLocalizationState();

  static _EasyLocalizationState of(BuildContext context) =>
      _EasyLocalizationProvider.of(context).data;

  // that is a hack :P
  // @TODO is there a better way to initialize the saved locale so that the app
  // initializes with the last choosen locale.
  // Right now developer needs to call this in main and if a saved locale is found
  // we save it on a global variable in this field.
  static loadSavedLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _codeLang = _preferences.getString('codeLa');
    var _codeCoun = _preferences.getString('codeCa');

    if (_codeLang != null) _savedLocale = Locale(_codeLang, _codeCoun);
  }
}

class _EasyLocalizationState extends State<EasyLocalization> {
  Locale _locale;
  Locale get locale => _locale;
  List<Locale> get supportedLocales => widget.supportedLocales;
  _EasyLocalizationDelegate get delegate => widget.delegate;

  _EasyLocalizationState() {
    _locale = _savedLocale ?? widget.fallbackLocale;
  }

  @override
  void initState() {
    super.initState();
    loadSavedAppLocale();
  }

  // if fallbackLocale is same as saved one the state won't rebuild.
  loadSavedAppLocale() async {
    Locale savedLocale = await getSavedLocale();
    if (savedLocale != null) {
      setState(() {
        _locale = savedLocale;
      });
    }
  }

  saveLocale(Locale locale) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('codeCa', locale.countryCode);
    await _preferences.setString('codeLa', locale.languageCode);
  }

  Future<Locale> getSavedLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _codeLang = _preferences.getString('codeLa');
    var _codeCoun = _preferences.getString('codeCa');

    if (_codeLang != null) return null;

    return Locale(_codeLang, _codeCoun);
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

    return _locale;
  }

  void changeLocale(Locale locale) async {
    if (!supportedLocales.contains(locale))
      throw new Exception("Locale $locale is not supported by this app.");
    _locale = locale;
    await saveLocale(locale);
    setState(() {});
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
  final List<Locale> supportedLocales;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  _EasyLocalizationDelegate({
    this.path,
    this.loadPath,
    this.useOnlyLangCode = false,
    this.supportedLocales,
    this.assetLoader = const RootBundleAssetLoader(),
  });

  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);

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
