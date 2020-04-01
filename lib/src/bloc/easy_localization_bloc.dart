part of '../easy_localization_app.dart';
class EasyLocalizationBloc {
  Locale locale= Locale("ru");
  //
  // Constructor
  //
  EasyLocalizationBloc._internal(){
    _actionController.stream.listen(_onData, onError: _onError, cancelOnError: true);
  }
  factory EasyLocalizationBloc(){
    return EasyLocalizationBloc._internal();
  }
  //
  // Stream to handle the _easyLocalizationLocale
  //
  StreamController<Locale> _controller = StreamController<Locale>();
  StreamSink<Locale> get _inSink => _controller.sink;
  Stream<Locale> get outStream => _controller.stream.transform(validate);

  final validate = StreamTransformer<Locale, Locale>.fromHandlers(
    handleError: (error, stackTrace, sink) =>  sink.addError(error),
    handleData: (locale, sink) {
        //print("====::::==$locale");
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
  StreamController<Locale> _actionController = StreamController<Locale>();
  Function(Locale) get onChange => _actionController.sink.add;
  Function get onError => _actionController.sink.addError;

  // StreamController _localController = StreamController<Locale>();
  // Function(Locale) get onChangeLocale => _localController.sink.add;

  void dispose() {
    _actionController.close();
    _controller.close();
    // _localController.close();
  }

  void reassemble() async{
    //cloase and create new when hotreloaded or reloaded  
    await _controller.close();
   _controller = StreamController<Locale>();
  }
  
  void _onData(data) {
    if(!_actionController.isClosed) _inSink.add(data);
  }

  void _onError(data){
    if(!_actionController.isClosed) _inSink.addError(data);
  }
}