part of '../easy_localization_app.dart';

class EasyLocalizationBloc {
  _EasyLocalizationLocale _easyLocalizationLocale;

  //
  // Stream to handle the _easyLocalizationLocale
  //
  StreamController<Locale> _controller = StreamController<Locale>();
  StreamSink<Locale> get _inSink => _controller.sink;
  Stream<Locale> get outStream => _controller.stream;

  //
  // Stream to handle the action on the _easyLocalizationLocale
  //
  StreamController _actionController = StreamController();
  StreamSink get onChangeLocal => _actionController.sink;

  //
  // Constructor
  //
  EasyLocalizationBloc(this._easyLocalizationLocale) {
    _actionController.stream.listen(_handleLogic);
  }

  void dispose() {
    _actionController.close();
    _controller.close();
  }

  void _handleLogic(data) async {
    if (data == null)
      await _easyLocalizationLocale._init();
    else
      _easyLocalizationLocale.locale = data;
    _inSink.add(_easyLocalizationLocale._locale);
  }
}
