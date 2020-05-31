part of '../easy_localization_app.dart';

class Resource {
  final Locale locale;
  final assetLoader;
  final String path;
  final bool useOnlyLangCode;
  Translations _translations;
  Translations get translations => _translations;
  Resource({this.locale, this.assetLoader, this.path, this.useOnlyLangCode});

  Future loadTranslations() async {
    Map<String, dynamic> data;
    useOnlyLangCode
        ? data = await assetLoader.load(path, Locale(locale.languageCode))
        : data = await assetLoader.load(path, locale);
    _translations = Translations(data);
  }
}

class _EasyLocalizationBloc {
  //
  // Constructor
  //
  _EasyLocalizationBloc._internal() {
    _actionController.stream
        .listen(_onData, onError: _onError, cancelOnError: true);
  }
  factory _EasyLocalizationBloc() {
    return _EasyLocalizationBloc._internal();
  }
  //
  // Stream to handle the _easyLocalizationLocale
  //
  StreamController<Resource> _controller = StreamController<Resource>.broadcast();
  StreamSink<Resource> get _inSink => _controller.sink;
  Stream<Resource> get outStream => _controller.stream.transform(validate);

  final validate = StreamTransformer<Resource, Resource>.fromHandlers(
      handleError: (error, stackTrace, sink) => sink.addError(error),
      handleData: (resource, sink) => sink.add(resource));

  //
  // Stream to handle the action on the _easyLocalizationLocale
  //
  final StreamController<Resource> _actionController =
      StreamController<Resource>();
  Function(Resource) get onChange => _actionController.sink.add;
  // Function get onError => _actionController.sink.addError;

  void dispose() {
    _actionController.close();
    _controller.close();
  }

  void reassemble() async {
    //recreate StreamController when hotreloaded or reloaded
    await _controller.close();
    _controller = StreamController<Resource>.broadcast();
  }

  Future _onData(Resource data) async {
    // Catch error from json parse/load
    try {
      await data.loadTranslations();
      if (!_actionController.isClosed) _inSink.add(data);
    } catch (e) {
      debugPrint(e.toString());
      _onError(e.toString());
    }
  }

  void _onError(data) {
    if (!_actionController.isClosed) _inSink.addError(data);
  }
}
