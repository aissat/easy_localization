import 'package:flutter/widgets.dart';

class LocaleProvider extends InheritedWidget {
  LocaleProvider({Key key, this.child, this.data})
      : super(key: key, child: child);
  final _LocaleInheritedState data;
  final Widget child;

  static LocaleProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(LocaleProvider)
        as LocaleProvider);
  }

  @override
  bool updateShouldNotify(LocaleProvider oldWidget) {
    return true;
  }
}

class LocaleInherited extends StatefulWidget {
  final Widget child;
  LocaleInherited({this.child});
  _LocaleInheritedState createState() => _LocaleInheritedState();
}



class _LocaleInheritedState extends State<LocaleInherited> {
  Locale _locale;

  Locale get locale => _locale;

  void changeLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LocaleProvider(
      data: this,
      child: widget.child,
    );
  }
}