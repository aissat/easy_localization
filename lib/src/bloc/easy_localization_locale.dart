part of '../easy_localization_app.dart';

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