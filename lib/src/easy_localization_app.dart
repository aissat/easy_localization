import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:intl/intl_standalone.dart";
import 'package:shared_preferences/shared_preferences.dart';

import 'asset_loader.dart';
import 'localization.dart';
import 'widgets.dart';

class EasyLocalization extends StatefulWidget {
  final Widget child;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final _EasyLocalizationDelegate delegate;
  final bool useOnlyLangCode;
  final String path;
  final AssetLoader assetLoader;
  final bool saveLocale;
  final Widget preloaderWidget;
  final Color preloaderColor;
  final VoidCallback onLocaleChange;
  EasyLocalization({
    Key key,
    @required this.child,
    @required this.supportedLocales,
    @required this.path,
    this.fallbackLocale,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
    this.preloaderWidget = const EmptyPreloaderWidget(),
    this.preloaderColor = Colors.white,
    this.onLocaleChange,
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
  VoidCallback onLocaleChange;

  // @TOGO maybe add assertion to ensure that ensureInitialized has been called and that
  // _savedLocale is set.
  _EasyLocalizationLocale(
      Locale fallbackLocale, List<Locale> supportedLocales, bool saveLocale, VoidCallback onLocaleChange)
      : this.saveLocale = saveLocale,
        this.onLocaleChange = onLocaleChange {
    _init(fallbackLocale, supportedLocales);
  }

  //Initialize _EasyLocalizationLocale
  _init(Locale fallbackLocale, List<Locale> supportedLocales){
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
  static Future initDeviceLocale() async {
    final String _deviceLocale = await findSystemLocale();
    final _deviceLocaleList = _deviceLocale.split("_");
    
    _osLocale = (_deviceLocaleList.length > 1)
        ? Locale(_deviceLocaleList[0], _deviceLocaleList[1])
        : Locale(_deviceLocaleList[0]);

  log('easy localization: Device locale ${_osLocale.toString()}');
  }

  Locale get locale => _locale;
  set locale(Locale l) {
    
    if (_locale != l){
      Locale _oldLocale = _locale;
      _locale = l;

      if (_locale != null)
        Intl.defaultLocale = Intl.canonicalizedLocale(
            l.countryCode == null || l.countryCode.isEmpty
                ? l.languageCode
                : l.toString());

      if (this.saveLocale) _saveLocale(_locale);
      log('easy localization: Set locale ${this.locale.toString()}');
      
      notifyListeners();

      if (onLocaleChange != null && _oldLocale != null) onLocaleChange();
    }
  }

  Locale get deviceLocale => _osLocale;

  _saveLocale(Locale locale) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('codeCa', locale.countryCode);
    await _preferences.setString('codeLa', locale.languageCode);
    log('easy localization: Locale saved ${locale.toString()}');
  }

  deleteSaveLocale() async{
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('codeCa', null);
    await _preferences.setString('codeLa', null);
    log('easy localization: Saved locale deleted');
  }
  
  static Future initSavedAppLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    var _codeLang = _preferences.getString('codeLa');
    var _codeCoun = _preferences.getString('codeCa');

    _savedLocale = _codeLang != null ? Locale(_codeLang, _codeCoun) : null;
  }
}

class _EasyLocalizationState extends State<EasyLocalization> {
  _EasyLocalizationLocale _locale;
  Future _futureSavedAppLocale;
  Future _futureInitDeviceLocale; 

  Locale get locale => _locale.locale;
  Locale get deviceLocale => _locale.deviceLocale;

  set locale(Locale l) {
    if (!supportedLocales.contains(l))
      throw new Exception("Locale $l is not supported by this app.");
    _locale.locale = l;
  }

  List<Locale> get supportedLocales => widget.supportedLocales;
  _EasyLocalizationDelegate get delegate => widget.delegate;
  Locale get fallbackLocale => widget.fallbackLocale;
  bool get saveLocale => widget.saveLocale;
  VoidCallback get onLocaleChange => widget.onLocaleChange;


  @override
  void dispose() {
    _locale.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //init _EasyLocalizationLocale only once
    //if saveLocale false then return blank future
    _futureSavedAppLocale = saveLocale
        ? _EasyLocalizationLocale.initSavedAppLocale()
        : Future.value();

    //init device locale once
    _futureInitDeviceLocale = _EasyLocalizationLocale.initDeviceLocale();

    //Init locale engine
    _locale =
        _EasyLocalizationLocale(fallbackLocale, supportedLocales, saveLocale, onLocaleChange);
    this._locale.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }
  //delete saved locale
  void deleteSaveLocale() => _locale.deleteSaveLocale(); 

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.preloaderColor,
      child: FutureBuilder<List>(
        //init saved locale and device locale
        future: Future.wait([_futureSavedAppLocale, _futureInitDeviceLocale]),
        builder: (BuildContext context,
            AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            return _EasyLocalizationProvider(
              data: this,
              child: widget.child,
            );
          } else if (snapshot.hasError){
            //Show error message       
            return const FutureErrorWidget();
          } else {
            //Show preloader widget
            return widget.preloaderWidget;
          }
        },
      ),
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
