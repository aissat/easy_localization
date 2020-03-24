part of '../easy_localization_app.dart';

class EasyLocalizationBloc {
  _EasyLocalizationLocale _easyLocalizationLocale;

  //
  // Stream to handle the _easyLocalizationLocale
  //
  StreamController<Locale> _controller = StreamController<Locale>.broadcast();
  StreamSink<Locale> get _inSink => _controller.sink;
  Stream<Locale> get outStream => _controller.stream.transform(validate);

  final validate = StreamTransformer<Locale, Locale>.fromHandlers(
      handleData: (locale, sink) {
    if (locale != null) {
      log('easy localization: validate locale ${locale.toString()}');
      sink.add(locale);
    } else {
      sink.addError("error");
      log('easy localization: error locale ');
    }
  });

  //
  // Stream to handle the action on the _easyLocalizationLocale
  //
  StreamController _actionController = StreamController();
  Function(Locale) get onChangeLocal => _actionController.sink.add;

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
    // onChangeLocal(_easyLocalizationLocale._locale);
  }
}
