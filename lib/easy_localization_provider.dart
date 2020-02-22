import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
class EasyLocalizationProvider extends InheritedWidget {
  EasyLocalizationProvider({Key key, this.child, this.data})
      : super(key: key, child: child);
  final _EasyLocalizationState data;
  final Widget child;

  static EasyLocalizationProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<EasyLocalizationProvider>();
  }

  @override
  bool updateShouldNotify(EasyLocalizationProvider oldWidget) {
    return true;
  }
}

class EasyLocalization extends StatefulWidget {
  final Widget child;
  EasyLocalization({this.child});
  _EasyLocalizationState createState() => _EasyLocalizationState();
  static EasyLocalization of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<EasyLocalization>();
}

class _EasyLocalizationState extends State<EasyLocalization> {
  Locale _locale;
  SharedPreferences _preferences;
  Locale get locale => _locale;

  @override
  void initState() {
    super.initState();
    // SharedPreferences.setMockInitialValues({});
    changeLocale();
  }

  void changeLocale({Locale locale}) async {
    var _defaultLocal ;
    print("================== changeLocale ===================");
    try {
      _preferences = await SharedPreferences.getInstance();
      if (locale == null) {
        var _codeLang = _preferences.getString('codeLa');
        var _codeCoun = _preferences.getString('codeCa');
        if (_codeLang == null) {
          var currentLocale= Intl.getCurrentLocale().split("_");
          _defaultLocal = Locale(currentLocale[0],currentLocale[1]);
        } else {
          _defaultLocal = Locale(_codeLang,_codeCoun);
        }
      } else _defaultLocal = locale;
      await _preferences.setString('codeCa', _defaultLocal.countryCode);
      await _preferences.setString('codeLa', _defaultLocal.languageCode);

      print(_defaultLocal.toString());

      setState(() {
          _locale = _defaultLocal;
        });
    } catch (e) {
      print(e);
    }
    print("================== changeLocale //===================");
  }

  @override
  Widget build(BuildContext context) => EasyLocalizationProvider(
        data: this,
        child: widget.child,
      );
}
