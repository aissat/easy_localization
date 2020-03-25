import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl_standalone.dart';

import 'asset_loader.dart';
import 'localization.dart';

class EasyLocalization extends StatefulWidget {
  final List<Locale> supportedLocales;
  final bool useOnlyLangCode;
  final String path;
  final AssetLoader assetLoader;
  final Widget child;
  final bool saveLocale;
  final EasyLocalizationDelegate delegate;
  final Color preloaderColor;

  EasyLocalization({
    Key key,
    @required this.supportedLocales,
    @required this.path,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
    this.child,
    this.preloaderColor = Colors.white
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

class _EasyLocalizationState extends State<EasyLocalization> {
  Locale locale;
  final EasyLocalizationDelegate delegate;

  _EasyLocalizationState(this.delegate);

  _onLocaleChanged(Locale locale) {
    setState(() {
      this.locale = locale;
    });
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
      log('easy localization: Locale loaded from shared preferences ${_strLocale.toString()}');
      setState(() {
        locale = _localeFromString(_strLocale);
      });
    }else{
      setState(()  {
        findSystemLocale().then((sysLocale){
          locale = _localeFromString(sysLocale);
        });        
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

  final EasyLocalizationDelegate delegate;

  EasyLocalizationProvider(this.parent, this._locale,
      {Key key, Widget child, this.onLocaleChanged, this.delegate})
      : super(key: key, child: child);

  @override
  Widget get child {
    if(_locale == null){
      return PreloaderWidget(null, parent.preloaderColor);
    }
    else{
      return PreloaderWidget(super.child, parent.preloaderColor);
    } 
  }

  Locale get locale => _locale;

  set locale(Locale locale) {
    assert(parent.supportedLocales.contains(locale));
    if (parent.saveLocale) _saveLocale(locale);
    log('easy localization: Locale set ${locale.toString()}');
    onLocaleChanged(locale);
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
  bool updateShouldNotify(EasyLocalizationProvider oldWidget) {
    return oldWidget._locale != this._locale;
  }

  static EasyLocalizationProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EasyLocalizationProvider>();
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

class PreloaderWidget extends StatelessWidget{
  final Widget children;
  final Color preloaderColor;
  PreloaderWidget(this.children, this.preloaderColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: preloaderColor,
      child: children,
    );
  }
}