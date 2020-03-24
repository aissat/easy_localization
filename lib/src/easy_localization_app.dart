import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/src/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'asset_loader.dart';
import 'localization.dart';

part 'bloc/easy_localization_bloc.dart';

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

class _EasyLocalizationLocale {
  Locale _locale;
  Locale _savedLocale;
  Locale _osLocale;
  bool saveLocale;

  Locale fallbackLocale;
  List<Locale> supportedLocales;

  // @TOGO maybe add assertion to ensure that ensureInitialized has been called and that
  // _savedLocale is set.
  _EasyLocalizationLocale(
      this.fallbackLocale, this.supportedLocales, this.saveLocale);

  //Initialize _EasyLocalizationLocale
  _init() async {
    _savedLocale = await initSavedAppLocale();
    // Get Device Locale
    _osLocale = await _getDeviceLocale();
    log('easy localization: Device locale ${_osLocale.toString()}');
    // If saved locale then get
    if (_savedLocale != null && this.saveLocale) {
      log('easy localization: Saved locale loaded ${_savedLocale.toString()}');
      locale = _savedLocale;
    } else {
      locale = supportedLocales.firstWhere((locale) => _checkInitLocale(locale),
          orElse: () => _getFallbackLocale(supportedLocales, fallbackLocale));
    }
    //Set locale
    if (Intl.defaultLocale == null) locale = _locale;
  }

  bool _checkInitLocale(Locale locale) {
    // If suported locale not contain countryCode then check only languageCode
    if (locale.countryCode == null) {
      return (locale.languageCode == _osLocale.languageCode);
    } else {
      return (locale == _osLocale);
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
    return _localeFromString(_deviceLocale);
  }

  Locale get locale => _locale;
  set locale(Locale l) {
    if (_locale != l) {
      _locale = l;

      if (_locale != null)
        Intl.defaultLocale = Intl.canonicalizedLocale(
            l.countryCode == null || l.countryCode.isEmpty
                ? l.languageCode
                : l.toString());

      if (this.saveLocale) _saveLocale(_locale);
      log('easy localization: Set locale ${this.locale.toString()}');
    }
  }

  _saveLocale(Locale locale) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('locale', locale.toString());
    log('easy localization: Locale saved ${locale.toString()}');
  }

  deleteSaveLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('locale', null);
    log('easy localization: Saved locale deleted');
  }

  Future<Locale> initSavedAppLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _strLocale = _preferences.getString('locale');

    log('easy localization: initSavedAppLocale ${_strLocale.toString()}');
    return _savedLocale =
        _strLocale != null ? _localeFromString(_strLocale) : null;
  }
}

class _EasyLocalizationState extends State<EasyLocalization> {
  _EasyLocalizationLocale _ezlocale;
  Locale _locale;
  // var _streamSavedAppLocale;
  EasyLocalizationBloc bloc;

  Locale get locale => _locale;

  set locale(Locale l) {
    if (!supportedLocales.contains(l))
      throw new Exception("Locale $l is not supported by this app.");
    print(l);
    _locale = l;
    bloc.onChangeLocal.add(l);
  }

  List<Locale> get supportedLocales => widget.supportedLocales;
  _EasyLocalizationDelegate get delegate => widget.delegate;
  Locale get fallbackLocale => widget.fallbackLocale;
  bool get saveLocale => widget.saveLocale;
  //delete saved locale
  void deleteSaveLocale() => _ezlocale.deleteSaveLocale();

  @override
  void dispose() {
    //_locale.dispose();
    bloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _ezlocale =
        _EasyLocalizationLocale(fallbackLocale, supportedLocales, saveLocale);
    bloc = EasyLocalizationBloc(_ezlocale);
    // bloc.initSavedAppLocale();
    bloc.onChangeLocal.add(null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _EasyLocalizationProvider.of(context).bloc;
    _ezlocale =
        _EasyLocalizationLocale(fallbackLocale, supportedLocales, saveLocale);
    return StreamBuilder(
        stream: bloc.outStream,
        initialData: _ezlocale._savedLocale,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _locale = snapshot.data;
            return _EasyLocalizationProvider(
              data: this,
              child: widget.child,
            );
          } else
            return FutureErrorWidget();
        });
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

Locale _localeFromString(String val) {
  var localeList = val.split("_");
  return (localeList.length > 1)
      ? Locale(localeList.first, localeList.last)
      : Locale(localeList.first);
}
