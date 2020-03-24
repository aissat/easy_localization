import 'dart:developer';

import 'package:easy_localization/src/widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'asset_loader.dart';
import 'localization.dart';

class EasyLocalization extends StatefulWidget {
  final List<Locale> supportedLocales;
  final bool useOnlyLangCode;
  final String path;
  final AssetLoader assetLoader;
  final Widget child;
  final bool saveLocale;

  EasyLocalization({
    Key key,
    @required this.supportedLocales,
    @required this.path,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
    this.child,
  }) : super(key: key);

  static EasyLocalizationProvider of(BuildContext context) =>
      EasyLocalizationProvider.of(context);

  @override
  _EasyLocalizationState createState() => _EasyLocalizationState();
}

class _EasyLocalizationState extends State<EasyLocalization> {
  Locale locale;
  EasyLocalizationDelegate delegate;

  _onLocaleChanged(Locale locale) {
    setState(() {
      this.locale = locale;
    });
  }

  @override
  void initState() {
    loadSavedLocale();
    delegate = EasyLocalizationDelegate(
        path: widget.path,
        supportedLocales: widget.supportedLocales,
        useOnlyLangCode: widget.useOnlyLangCode,
        assetLoader: widget.assetLoader,
        onLocaleChanged: _onLocaleChanged);
  }

  loadSavedLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _codeLang = _preferences.getString('codeLa');
    var _codeCoun = _preferences.getString('codeCa');
    if (_codeLang != null) {
      log('easy localization: Locale loaded from shared preferences ${Locale(_codeLang, _codeCoun)}');
      setState(() {
        locale = Locale(_codeLang, _codeCoun);
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
  EasyLocalization parent;
  final Locale _locale;
  final ValueChanged<Locale> onLocaleChanged;

  List<Locale> get supportedLocales => parent.supportedLocales;

  final EasyLocalizationDelegate delegate;

  EasyLocalizationProvider(this.parent, this._locale,
      {Key key, Widget child, this.onLocaleChanged, this.delegate})
      : super(key: key, child: child);

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
  final ValueChanged<Locale> onLocaleChanged;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  Locale loadedLocale;

  EasyLocalizationDelegate(
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
    loadedLocale = value;
    if (onLocaleChanged != null) {
      onLocaleChanged(value);
    }
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
