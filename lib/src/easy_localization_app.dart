import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/src/widgets.dart';

import 'widgets.dart';
import 'asset_loader.dart';
import 'localization.dart';
import 'translations.dart';

//If web then import intl_browser else intl_standalone
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';

part 'bloc/easy_localization_bloc.dart';
part 'utils.dart';

class EasyLocalization extends StatefulWidget {
  final Widget child;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final Locale startLocale;
  final bool useOnlyLangCode;
  final String path;
  final assetLoader;
  final bool saveLocale;
  final Color preloaderColor;
  final Widget preloaderWidget;
  EasyLocalization({
    Key key,
    @required this.child,
    @required this.supportedLocales,
    @required this.path,
    this.fallbackLocale,
    this.startLocale,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
    this.preloaderColor = Colors.white,
    this.preloaderWidget = const EmptyPreloaderWidget(),
  })  : assert(child != null),
        assert(supportedLocales != null && supportedLocales.isNotEmpty),
        assert(path != null && path.isNotEmpty),
        assert(preloaderWidget != null),
        super(key: key) {
    log('Start', name: 'Easy Localization');
  }

  @override
  _EasyLocalizationState createState() => _EasyLocalizationState();

  static _EasyLocalizationProvider of(BuildContext context) =>
      _EasyLocalizationProvider.of(context);
}

class _EasyLocalizationState extends State<EasyLocalization> {
  ///Init EasyLocalizationBloc
  final bloc = _EasyLocalizationBloc();
  _EasyLocalizationDelegate delegate;
  Locale locale;

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    log('Init state', name: 'Easy Localization');
    _init();
    super.initState();
  }

  @override
  void reassemble() {
    bloc.reassemble();
    super.reassemble();
  }

  void _init() async {
    Locale _savedLocale;
    Locale _osLocale;
    if (widget.saveLocale) _savedLocale = await loadSavedLocale();
    if (_savedLocale == null && widget.startLocale != null) {
      locale = _getFallbackLocale(widget.supportedLocales, widget.startLocale);
      log('Start locale loaded ${locale.toString()}', name: 'Easy Localization');
    }
    // If saved locale then get
    else if (_savedLocale != null && widget.saveLocale) {
      log('Saved locale loaded ${_savedLocale.toString()}', name: 'Easy Localization');
      locale = _savedLocale;
    } else {
      // Get Device Locale
      _osLocale = await _getDeviceLocale();
      locale = widget.supportedLocales.firstWhere(
          (locale) => _checkInitLocale(locale, _osLocale),
          orElse: () => _getFallbackLocale(
              widget.supportedLocales, widget.fallbackLocale));
    }

    bloc.onChange(Resource(
        locale: locale,
        assetLoader: widget.assetLoader,
        path: widget.path,
        useOnlyLangCode: widget.useOnlyLangCode));
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
    final _deviceLocale = await findSystemLocale();
    log('Device locale $_deviceLocale', name: 'Easy Localization');
    return localeFromString(_deviceLocale);
  }

  Future<Locale> loadSavedLocale() async {
    final _preferences = await SharedPreferences.getInstance();
    final _strLocale = _preferences.getString('locale');
    final locale = _strLocale != null ? localeFromString(_strLocale) : null;

    return locale;
  }

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;
    log('Build', name: 'Easy Localization');
    return Container(
      color: widget.preloaderColor,
      child: StreamBuilder<Resource>(
          stream: bloc.outStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData &&
                !snapshot.hasError) {
              returnWidget = widget.preloaderWidget;
            } else if (snapshot.hasData && !snapshot.hasError) {
              returnWidget = _EasyLocalizationProvider(
                widget,
                snapshot.data.locale,
                bloc: bloc,
                delegate: _EasyLocalizationDelegate(
                    translations: snapshot.data.translations,
                    supportedLocales: widget.supportedLocales),
              );
            } else if (snapshot.hasError) {
              returnWidget = FutureErrorWidget(msg: snapshot.error);
            }
            return returnWidget;
          }),
    );
  }
}

class _EasyLocalizationProvider extends InheritedWidget {
  final EasyLocalization parent;
  final Locale _locale;
  final _EasyLocalizationBloc bloc;
  final _EasyLocalizationDelegate delegate;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get delegates => [
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  List<Locale> get supportedLocales => parent.supportedLocales;

  // _EasyLocalizationDelegate get delegate => parent.delegate;

  _EasyLocalizationProvider(this.parent, this._locale,
      {Key key, this.bloc, this.delegate})
      : super(key: key, child: parent.child) {
    log('Init provider', name: 'Easy Localization');
  }

  Locale get locale => _locale;
  Locale get fallbackLocale => parent.fallbackLocale;
  // Locale get startLocale => parent.startLocale;

  set locale(Locale locale) {
    // Check old locale
    if (locale != _locale) {
      assert(parent.supportedLocales.contains(locale));
      if (parent.saveLocale) _saveLocale(locale);
      log('Locale set ${locale.toString()}', name: 'Easy Localization');

      bloc.onChange(Resource(
          locale: locale,
          path: parent.path,
          assetLoader: parent.assetLoader,
          useOnlyLangCode: parent.useOnlyLangCode));
    }
  }

  void _saveLocale(Locale locale) async {
    final _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('locale', locale.toString());
    log('Locale saved ${locale.toString()}', name: 'Easy Localization');
  }

  void deleteSaveLocale() async {
    final _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('locale', null);
    log('Saved locale deleted', name: 'Easy Localization');
  }

  @override
  bool updateShouldNotify(_EasyLocalizationProvider oldWidget) {
    return oldWidget._locale != _locale;
  }

  static _EasyLocalizationProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_EasyLocalizationProvider>();
}

class _EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final List<Locale> supportedLocales;
  final Translations translations;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  // final bool useOnlyLangCode;

  _EasyLocalizationDelegate({this.translations, this.supportedLocales}) {
    log('Init Localization Delegate', name: 'Easy Localization');
    Localization.instance.translations = translations;
  }

  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);

  @override
  Future<Localization> load(Locale value) {
    log('Load Localization Delegate', name: 'Easy Localization');
    Localization.load(value, translations: translations);
    return Future.value(Localization.instance);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}
