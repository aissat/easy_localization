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
  final List<Locale> supportedLocales;
  final bool useOnlyLangCode;
  final String path;
  final AssetLoader assetLoader;
  final Widget child;
  final bool saveLocale;
  final EasyLocalizationDelegate delegate;

  EasyLocalization({
    Key key,
    @required this.supportedLocales,
    @required this.path,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
    this.child,
  })  : delegate = EasyLocalizationDelegate(
          path: path,
          supportedLocales: supportedLocales,
          useOnlyLangCode: useOnlyLangCode,
          assetLoader: assetLoader,
        ),
        super(key: key);

  static EasyLocalizationProvider of(BuildContext context) =>
      EasyLocalizationProvider.of(context);

  @override
  _EasyLocalizationState createState() => _EasyLocalizationState(delegate);
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

  @override
  void initState() {
    if (widget.saveLocale) loadSavedLocale();
    delegate.onLocaleChanged = (locale) {
      if (this.locale == null)
        setState(() {
          this.locale = locale;
        });
    };
    super.initState();
  }

  loadSavedLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _strLocale = _preferences.getString('locale');
    if (_strLocale != null) {
      log('easy localization: Locale loaded from shared preferences ${_strLocale}');
      setState(() {
        locale = _localeFromString(_strLocale);
      });
    }
    // TODO reload delegate, set on Material Widget
  }

  @override
  Widget build(BuildContext context) {
    return EasyLocalizationProvider(
      widget,
      this.locale,
      child: widget.child,
      onLocaleChanged: _onLocaleChanged,
      delegate: delegate,
    );
  }
}

class EasyLocalizationProvider extends InheritedWidget {
  final EasyLocalization parent;
  final Locale _locale;
  final ValueChanged<Locale> onLocaleChanged;

  List<Locale> get supportedLocales => parent.supportedLocales;

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

class EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final String path;
  final AssetLoader assetLoader;
  final List<Locale> supportedLocales;
  ValueChanged<Locale> onLocaleChanged;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  Locale loadedLocale;

  EasyLocalizationDelegate({
    @required this.path,
    @required this.supportedLocales,
    this.useOnlyLangCode = false,
    this.assetLoader,
  });

  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);

  @override
  Future<Localization> load(Locale value) async {
    loadedLocale = value;
    await Localization.load(
      value,
      path: path,
      useOnlyLangCode: useOnlyLangCode,
      assetLoader: assetLoader,
    );
    onLocaleChanged(value);
    return Localization.instance;
  }

  @override
  bool shouldReload(EasyLocalizationDelegate old) {
    return loadedLocale != old.loadedLocale;
  }
}

Locale _localeFromString(String val) {
  var localeList = val.split("_");
  return (localeList.length > 1)
      ? Locale(localeList.first, localeList.last)
      : Locale(localeList.first);
}
