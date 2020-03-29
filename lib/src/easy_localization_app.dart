import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl_standalone.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easy_localization/src/widgets.dart';

import 'asset_loader.dart';
import 'localization.dart';

part 'bloc/easy_localization_bloc.dart';

class EasyLocalization extends StatefulWidget {
  final Widget child;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final bool useOnlyLangCode;
  final String path;
  final AssetLoader assetLoader;
  final bool saveLocale;
  final Color preloaderColor;
  EasyLocalization({
    Key key,
    @required this.child,
    @required this.supportedLocales,
    @required this.path,
    this.fallbackLocale,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
    this.preloaderColor = Colors.white,
  })  : assert(child != null),
        assert(supportedLocales != null && supportedLocales.isNotEmpty),
        assert(path != null && path.isNotEmpty),
        super(key: key);

  _EasyLocalizationState createState() => _EasyLocalizationState();

  static _EasyLocalizationProvider of(BuildContext context) =>
      _EasyLocalizationProvider.of(context);
}

class _EasyLocalizationState extends State<EasyLocalization> {
  Locale locale;
  _EasyLocalizationDelegate delegate;
  final EasyLocalizationBloc bloc = EasyLocalizationBloc();

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _init();
    delegate = _EasyLocalizationDelegate(
        path: widget.path,
        supportedLocales: widget.supportedLocales,
        useOnlyLangCode: widget.useOnlyLangCode,
        assetLoader: widget.assetLoader,
        onLocaleChanged: bloc.onChangeLocal);

    super.initState();
  }

  _init() async {
    Locale _savedLocale;
    Locale _osLocale;

    if(widget.saveLocale) _savedLocale = await loadSavedLocale();
    // Get Device Locale
    _osLocale = await _getDeviceLocale();
    // If saved locale then get
    if (_savedLocale != null && widget.saveLocale) {
      log('easy localization: Saved locale loaded ${_savedLocale.toString()}');
      locale = _savedLocale;
    } else {
      locale = widget.supportedLocales.firstWhere(
          (locale) => _checkInitLocale(locale, _osLocale),
          orElse: () => _getFallbackLocale(
              widget.supportedLocales, widget.fallbackLocale));
    }
    bloc.onChangeLocal(locale);
  }

  bool _checkInitLocale(Locale locale, Locale _osLocale) {
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
    log('easy localization: Device locale $_deviceLocale');
    return _localeFromString(_deviceLocale);
  }

  Future<Locale> loadSavedLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _strLocale = _preferences.getString('locale');
    return locale = _strLocale != null ? _localeFromString(_strLocale) : null;
    // TODO reload delegate, set on Material Widget
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.preloaderColor,
      child: StreamBuilder(
          stream: bloc.outStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError) {
              return _EasyLocalizationProvider(
                widget,
                snapshot.data,
                child: widget.child,
                onLocaleChanged: bloc.onChangeLocal,
                delegate: delegate,
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return EmptyPreloaderWidget();
            } else {
              return FutureErrorWidget(msg: snapshot.error);
            }
          }),
    );
  }
}

class _EasyLocalizationProvider extends InheritedWidget {
  final EasyLocalization parent;
  final Locale _locale;
  final ValueChanged<Locale> onLocaleChanged;

  List<Locale> get supportedLocales => parent.supportedLocales;

  final _EasyLocalizationDelegate delegate;

  _EasyLocalizationProvider(this.parent, this._locale,
      {Key key, Widget child, this.onLocaleChanged, this.delegate})
      : super(key: key, child: child);

  Locale get locale => _locale;
  Locale get fallbackLocale => parent.fallbackLocale;

  set locale(Locale locale) {
    // Check old locale    
    if (locale != _locale){
      assert(parent.supportedLocales.contains(locale));
      if (parent.saveLocale) _saveLocale(locale);
      log('easy localization: Locale set ${locale.toString()}');
      onLocaleChanged(locale);
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

  @override
  bool updateShouldNotify(_EasyLocalizationProvider oldWidget) {
    return oldWidget._locale != this._locale;
  }

  static _EasyLocalizationProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_EasyLocalizationProvider>();
}

class _EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final String path;
  final AssetLoader assetLoader;
  final List<Locale> supportedLocales;
  final ValueChanged<Locale> onLocaleChanged;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  _EasyLocalizationDelegate(
      {@required this.path,
      @required this.supportedLocales,
      this.useOnlyLangCode = false,
      this.assetLoader,
      this.onLocaleChanged});

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
