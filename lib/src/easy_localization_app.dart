import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:intl/intl_standalone.dart";
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
  final bool saveLocale;
  EasyLocalization({
    Key key,
    @required this.child,
    @required this.supportedLocales,
    @required this.path,
    this.fallbackLocale,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
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
  static Locale _osLocale;
  bool saveLocale;

  // @TOGO maybe add assertion to ensure that ensureInitialized has been called and that
  // _savedLocale is set.
  _EasyLocalizationLocale(
      Locale fallbackLocale, List<Locale> supportedLocales, bool saveLocale)
      : this.saveLocale = saveLocale {
    _init(fallbackLocale, supportedLocales);
  }

  //Initialize _EasyLocalizationLocale
  _init(Locale fallbackLocale, List<Locale> supportedLocales) async {
    // Get Device Locale
    _osLocale = await _getDeviceLocale();
    log('easy localization: Device locale ${_osLocale.toString()}');
    // If saved locale then get
    if (_savedLocale != null && this.saveLocale) {
      locale = _savedLocale;
      log('easy localization: Load saved locale ${_savedLocale.toString()}');
    } else {
      locale = supportedLocales.firstWhere((locale) => _checkInitLocale(locale),
          orElse: () => _getFallbackLocale(supportedLocales, fallbackLocale));
    }
    //Set locale
    if (Intl.defaultLocale == null) locale = _locale;
    log('easy localization: Set locale ${this._locale.toString()}');
  }

  bool _checkInitLocale(Locale locale) {
    // If suported locale not contain countryCode then check only languageCode
    if (locale.countryCode == null) {
      return (locale == _osLocale);
    } else {
      return (locale.languageCode == _osLocale.languageCode);
    }
  }

  //Get fallback Locale
  Locale _getFallbackLocale(
      List<Locale> supportedLocales, Locale fallbackLocale) {
    //If fallbackLocale not set then return first from supportedLocales
    if (fallbackLocale != null) {
      return fallbackLocale;
    } else {
      return supportedLocales.first;
    }
  }

  // Get Device Locale
  Future<Locale> _getDeviceLocale() async {
    final String _deviceLocale = await findSystemLocale();
    print(_deviceLocale);
    final _deviceLocaleList = _deviceLocale.split("_");
    return (_deviceLocaleList.length > 1)
        ? Locale(_deviceLocaleList[0], _deviceLocaleList[1])
        : Locale(_deviceLocaleList[0]);

    //;
  }

  Locale get locale => _locale;
  set locale(Locale l) {
    _locale = l;

    if (_locale != null)
      Intl.defaultLocale = Intl.canonicalizedLocale(
          l.countryCode == null || l.countryCode.isEmpty
              ? l.languageCode
              : l.toString());

    if (this.saveLocale) _saveLocale(_locale);
  }

  _saveLocale(Locale locale) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('codeCa', locale.countryCode);
    await _preferences.setString('codeLa', locale.languageCode);
    log(locale.toString(), name: this.toString() + "_saveLocale");
  }

  static Future<_EasyLocalizationLocale> initSavedAppLocale(
      Locale fallbackLocale,
      List<Locale> supportedLocales,
      bool saveLocale) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _codeLang = _preferences.getString('codeLa');
    var _codeCoun = _preferences.getString('codeCa');

    _savedLocale = _codeLang != null ? Locale(_codeLang, _codeCoun) : null;
    return _EasyLocalizationLocale(
        fallbackLocale, supportedLocales, saveLocale);
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
  bool get saveLocale => widget.saveLocale;


  @override
  void dispose() {
    _locale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EasyLocalizationLocale>(
      future: _EasyLocalizationLocale.initSavedAppLocale(
          fallbackLocale, supportedLocales, saveLocale),
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
