import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:easy_localization/src/widgets.dart';

import 'asset_loader.dart';
import 'localization.dart';

part 'bloc/easy_localization_bloc.dart';
part 'bloc/easy_localization_locale.dart';

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
