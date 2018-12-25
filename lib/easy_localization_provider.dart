import 'package:flutter/widgets.dart';

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

  Locale get locale => _locale;

  void changeLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return EasyLocalizationProvider(
      data: this,
      child: widget.child,
    );
  }
}