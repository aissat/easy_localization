import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'asset_loader.dart';
import 'localization.dart';

class EasyLocalization extends StatefulWidget {
  final Widget child;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final _EasyLocalizationDelegate delegate;
  final bool useOnlyLangCode;
  final String path;
  final AssetLoader assetLoader;
  EasyLocalization({
    Key key,
    @required this.child,
    @required this.supportedLocales,
    @required this.path,
    this.fallbackLocale,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
  })  : //assert(supportedLocales.contains(fallbackLocale)),

        delegate = _EasyLocalizationDelegate(
            path: path,
            supportedLocales: supportedLocales,
            useOnlyLangCode: useOnlyLangCode,
            assetLoader: assetLoader),
        super(key: key);
  _EasyLocalizationState createState() => _EasyLocalizationState();

  static _EasyLocalizationState of(BuildContext context) =>
      _EasyLocalizationProvider.of(context).data;
}

class _EasyLocalizationLocale extends ChangeNotifier {
  Locale _locale;
  static Locale _savedLocale;
  // Get default OS Locale
  static final _osCurrentLocale = Intl.getCurrentLocale().split("_");
  static Locale _osLocal = Locale(_osCurrentLocale[0], _osCurrentLocale[1]);

  // @TOGO maybe add assertion to ensure that ensureInitialized has been called and that
  // _savedLocale is set.
  _EasyLocalizationLocale(Locale fallbackLocale, List<Locale> supportedLocales)
      // if fallbackLocale null and default OS Locale in supportedLocales
      // init by default OS Locale else init by supportedLocales[0]
      : this._locale = (_savedLocale ?? fallbackLocale) ??
            supportedLocales.firstWhere((local) => local == _osLocal,
                orElse: () => supportedLocales.first) {
    locale = this._locale;
  }
  Locale get locale => _locale;
  set locale(Locale l) {
    _locale = l;

    if (_locale != null)
      Intl.defaultLocale = Intl.canonicalizedLocale(
          l.countryCode == null || l.countryCode.isEmpty
              ? l.languageCode
              : l.toString());

    _saveLocale(_locale);

    notifyListeners();
  }

  _saveLocale(Locale locale) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('codeCa', locale.countryCode);
    await _preferences.setString('codeLa', locale.languageCode);
  }

  static Future<_EasyLocalizationLocale> initSavedAppLocale(
      Locale fallbackLocale, List<Locale> supportedLocales) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _codeLang = _preferences.getString('codeLa');
    var _codeCoun = _preferences.getString('codeCa');

    _savedLocale = _codeLang != null ? Locale(_codeLang, _codeCoun) : null;
    log(_savedLocale.toString(), name: "initSavedAppLocale");
    return _EasyLocalizationLocale(fallbackLocale, supportedLocales);
  }
}

class _EasyLocalizationState extends State<EasyLocalization> {
  _EasyLocalizationLocale _locale;
  Locale get locale => _locale.locale;

  set locale(Locale l) {
    if (!supportedLocales.contains(l))
      throw new Exception("Locale $l is not supported by this app.");
    _locale.locale = l;
  }

  List<Locale> get supportedLocales => widget.supportedLocales;
  _EasyLocalizationDelegate get delegate => widget.delegate;

  Locale get fallbackLocale => widget.fallbackLocale;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // locale is either the deviceLocale or the MaterialApp widget locale.
  // This function is responsible for returning a locale that is supported by your app
  // if the app is opened for the first time and we only have the deviceLocale information.
  Locale localeResolutionCallback(
      Locale locale, Iterable<Locale> supportedLocales) {
    if (supportedLocales != widget.supportedLocales)
      throw new Exception(
          "You haven't given EasyLocalization.supportedLocales to MaterialApp supportedLocales property");

    if (supportedLocales.contains(locale)) return locale;

    return _locale.locale;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EasyLocalizationLocale>(
      future: _EasyLocalizationLocale.initSavedAppLocale(
          fallbackLocale, supportedLocales),
      builder: (BuildContext context,
          AsyncSnapshot<_EasyLocalizationLocale> snapshot) {
        if (snapshot.hasData) {
          if (this._locale == null) this._locale = snapshot.data;
          snapshot.data.addListener(() {
            if (mounted) setState(() {});
          });
          return _EasyLocalizationProvider(
            data: this,
            child: widget.child,
          );
        } else {
          // TODO implement [load, error] widget when init locale
          return Container();
        }
      },
    );
  }
}

class _EasyLocalizationProvider extends InheritedWidget {
  _EasyLocalizationProvider({Key key, this.child, this.data})
      : super(key: key, child: child);
  final _EasyLocalizationState data;
  final Widget child;

  static _EasyLocalizationProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_EasyLocalizationProvider>();

  @override
  bool updateShouldNotify(_EasyLocalizationProvider oldWidget) => true;
}

class _EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final String path;
  final AssetLoader assetLoader;
  final List<Locale> supportedLocales;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  _EasyLocalizationDelegate(
      {@required this.path,
      @required this.supportedLocales,
      this.useOnlyLangCode = false,
      this.assetLoader});

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
