import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _saveLocale();
  }

  void changeLocale(Locale value) async {
    _preferences = await SharedPreferences.getInstance();
    await _preferences.setString('codeC', value.countryCode);
    await _preferences.setString('codeL', value.languageCode);
    setState(() {
      _locale = value;
    });
  }

  void _saveLocale() async {
    _preferences = await SharedPreferences.getInstance();
    var _codeLang = _preferences.getString('codeL');
    var _codeCoun = _preferences.getString('codeC');
    if (_codeLang?.isNotEmpty == true) {
      setState(() {
        _locale = Locale(_codeLang, _codeCoun);
      });
    }
  }

  @override
  Widget build(BuildContext context) => EasyLocalizationProvider(
        data: this,
        child: widget.child,
      );
}
