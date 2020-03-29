part of '../easy_localization_app.dart';

class EasyLocalizationBloc {
  //
  // Stream to handle the _easyLocalizationLocale
  //
  final StreamController<Locale> _controller = StreamController<Locale>();
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
  EasyLocalizationBloc() {
    _actionController.stream.listen(_handleLogic);
  }

  void dispose() {
    _actionController.close();
    _controller.close();
  }

  void _handleLogic(data) {
    if(!_actionController.isClosed) _inSink.add(data);
  }
}
