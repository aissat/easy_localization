import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EasyLocalizationProvider extends InheritedWidget {
  EasyLocalizationProvider({Key key, this.child, this.data})
      : super(key: key, child: child);
  final _EasyLocalizationState data;
  final Widget child;

  static EasyLocalizationProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(EasyLocalizationProvider)
        as EasyLocalizationProvider);
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
}

class _EasyLocalizationState extends State<EasyLocalization> {
  Locale _locale;
  Locale _savedLocale;

  Locale get locale => _locale;
  Locale get savedLocale => _savedLocale;
  @override
  void initState() {
    super.initState();
    saveLocale();
  }

  void changeLocale(Locale value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('codeC', value.countryCode);
    await preferences.setString('codeL', value.languageCode);
    var _codeLang = preferences.getString('codeL');
    var _codeCoun = preferences.getString('codeC');
    setState(() {
      _locale = Locale(_codeLang, _codeCoun);
      _savedLocale = Locale(_codeLang, _codeCoun);
    });
  }

  void saveLocale() async {
    final SharedPreferences _preferences =
        await SharedPreferences.getInstance();
    var _codeLang = _preferences.getString('codeL');
    var _codeCoun = _preferences.getString('codeC');
    if (_codeLang?.isNotEmpty == true) {
      setState(() {
        _savedLocale = Locale(_codeLang, _codeCoun);
      });
    }
  }

  @override
  Widget build(BuildContext context) => EasyLocalizationProvider(
        data: this,
        child: widget.child,
      );
}
