import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
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

  EasyLocalization({
    @required this.child,
    @required this.supportedLocales,
    @required this.fallbackLocale,
    @required this.path,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
  })  : assert(supportedLocales.contains(fallbackLocale)),
        delegate = _EasyLocalizationDelegate(
          path: path,
          supportedLocales: supportedLocales,
          useOnlyLangCode: useOnlyLangCode,
        );

  _EasyLocalizationState createState() => _EasyLocalizationState();

  static _EasyLocalizationState of(BuildContext context) =>
      _EasyLocalizationProvider.of(context).data;

  /// ensureInitialized needs to be called in main
  /// so that savedLocale is loaded and used from the
  /// start.
  static ensureInitialized() async =>
      await _EasyLocalizationLocale.initSavedAppLocale();
}

class _EasyLocalizationLocale extends ChangeNotifier {
  Locale _locale;
  static Locale _savedLocale;

  // @TOGO maybe add assertion to ensure that ensureInitialized has been called and that
  // _savedLocale is set.
  _EasyLocalizationLocale(Locale fallbackLocale)
      : this._locale = _savedLocale ?? fallbackLocale;

  Locale get locale => _locale;
  set locale(Locale l) {
    _locale = l;

    if (_locale != null)
      Intl.defaultLocale = Intl.canonicalizedLocale(
          l.countryCode.isEmpty ? l.languageCode : l.toString());

    _saveLocale(_locale);

    notifyListeners();
  }

  _saveLocale(Locale locale) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('codeCa', locale.countryCode);
    await _preferences.setString('codeLa', locale.languageCode);
  }

  static initSavedAppLocale() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    final String _codeLang = _preferences.getString('codeLa');
    final String _codeCoun = _preferences.getString('codeCa');

    _savedLocale = _codeLang != null ? Locale(_codeLang, _codeCoun) : null;
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

  @override
  void initState() {
    _locale = _EasyLocalizationLocale(widget.fallbackLocale);
    _locale.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _locale.dispose();
    super.dispose();
  }

  // locale is either the deviceLocale or the MaterialApp widget locale.
  // This function is responsible for returning a locale that is supported by your app
  // if the app is opened for the first time and we only have the deviceLocale information.
  Locale localeResolutionCallback(
      Locale locale, Iterable<Locale> supportedLocales) {
    if (supportedLocales != widget.supportedLocales)
      throw new Exception(
          "You haven't given EasyLocalization.supportedLocales to MaterialApp supportedLocales property");

    if (supportedLocales.contains(locale)) return locale;

    return _locale.locale;
  }

  @override
  Widget build(BuildContext context) => _EasyLocalizationProvider(
        data: this,
        child: widget.child,
      );
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

  _EasyLocalizationDelegate({
    @required this.path,
    @required this.supportedLocales,
    this.useOnlyLangCode = false,
    this.assetLoader = const RootBundleAssetLoader(),
  });

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
