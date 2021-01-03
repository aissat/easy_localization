import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'asset_loader.dart';
import 'localization.dart';

part 'utils.dart';

///  EasyLocalization
///  example:
///  ```
///  void main(){
///    runApp(EasyLocalization(
///      child: MyApp(),
///      supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
///      path: 'resources/langs/langs.csv',
///      assetLoader: CsvAssetLoader()
///    ));
///  }
///  ```
class EasyLocalization extends StatefulWidget {
  /// Place for your main page widget.
  final Widget child;

  /// List of supported locales.
  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  final List<Locale> supportedLocales;

  /// Locale when the locale is not in the list
  final Locale fallbackLocale;

  /// Overrides device locale.
  final Locale startLocale;

  /// Trigger for using only language code for reading localization files.
  /// @Default value false
  /// Example:
  /// ```
  /// en.json //useOnlyLangCode: true
  /// en-US.json //useOnlyLangCode: false
  /// ```
  final bool useOnlyLangCode;

  /// Path to your folder with localization files.
  /// Example:
  /// ```dart
  /// path: 'assets/translations',
  /// path: 'assets/translations/lang.csv',
  /// ```
  final String path;

  /// Class loader for localization files.
  /// You can use custom loaders from [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) or create your own class.
  /// @Default value `const RootBundleAssetLoader()`
  final assetLoader;

  /// Save locale in device storage.
  /// @Default value false
  final bool saveLocale;

  /// Shows a custom error widget when an error is encountered instead of the default error widget.
  /// @Default value `errorWidget = ErrorWidget()`
  final Widget Function(FlutterError message) errorWidget;

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
    this.errorWidget,
  })  : assert(child != null),
        assert(supportedLocales != null && supportedLocales.isNotEmpty),
        assert(path != null && path.isNotEmpty),
        super(key: key) {
    log('Start', name: 'Easy Localization');
  }

  @override
  _EasyLocalizationState createState() => _EasyLocalizationState();

  static _EasyLocalizationProvider of(BuildContext context) =>
      _EasyLocalizationProvider.of(context);

  /// ensureInitialized needs to be called in main
  /// so that savedLocale is loaded and used from the
  /// start.
  static void ensureInitialized() async =>
      EasyLocalizationController.initEasyLocation();
}

class _EasyLocalizationState extends State<EasyLocalization> {
  _EasyLocalizationDelegate delegate;
  EasyLocalizationController localizationController;
  FlutterError translationsLoadError;

  @override
  void initState() {
    log('Init state', name: 'Easy Localization');
    localizationController = EasyLocalizationController(
      saveLocale: widget.saveLocale,
      fallbackLocale: widget.fallbackLocale,
      supportedLocales: widget.supportedLocales,
      startLocale: widget.startLocale,
      assetLoader: widget.assetLoader,
      useOnlyLangCode: widget.useOnlyLangCode,
      path: widget.path,
      onLoadError: (FlutterError e) {
        setState(() {
          translationsLoadError = e;
        });
      },
    );
    // causes localization to rebuild with new language
    localizationController.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    localizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('Build', name: 'Easy Localization');
    if (translationsLoadError != null) {
      return widget.errorWidget != null
          ? widget.errorWidget(translationsLoadError)
          : ErrorWidget(translationsLoadError);
    }
    return _EasyLocalizationProvider(
      widget,
      localizationController,
      delegate: _EasyLocalizationDelegate(
        localizationController: localizationController,
        supportedLocales: widget.supportedLocales,
      ),
    );
  }
}

class _EasyLocalizationProvider extends InheritedWidget {
  final EasyLocalization parent;
  final EasyLocalizationController _localeState;
  final Locale currentLocale;
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

  /// Get List of supported locales
  List<Locale> get supportedLocales => parent.supportedLocales;

  // _EasyLocalizationDelegate get delegate => parent.delegate;

  _EasyLocalizationProvider(this.parent, this._localeState,
      {Key key, this.delegate})
      : currentLocale = _localeState.locale,
        super(key: key, child: parent.child) {
    log('Init provider', name: 'Easy Localization');
  }

  /// Get current locale
  Locale get locale => _localeState.locale;

  /// Get fallback locale
  Locale get fallbackLocale => parent.fallbackLocale;
  // Locale get startLocale => parent.startLocale;

  /// Change app locale
  void setLocale(Locale _locale) async {
    // Check old locale
    if (_locale != _localeState.locale) {
      assert(parent.supportedLocales.contains(_locale));
      await _localeState.setLocale(_locale);
    }
  }

  /// Clears a saved locale from device storage
  void deleteSaveLocale() async {
    await _localeState.deleteSaveLocale();
  }

  @override
  bool updateShouldNotify(_EasyLocalizationProvider oldWidget) {
    return oldWidget.currentLocale != locale;
  }

  static _EasyLocalizationProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_EasyLocalizationProvider>();
}

class _EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final List<Locale> supportedLocales;
  final EasyLocalizationController localizationController;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  // final bool useOnlyLangCode;

  _EasyLocalizationDelegate(
      {this.localizationController, this.supportedLocales}) {
    log('Init Localization Delegate', name: 'Easy Localization');
  }

  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);

  @override
  Future<Localization> load(Locale value) async {
    log('Load Localization Delegate', name: 'Easy Localization');
    if (localizationController.translations == null) {
      await localizationController.loadTranslations();
    }

    Localization.load(value, translations: localizationController.translations);
    return Future.value(Localization.instance);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}
