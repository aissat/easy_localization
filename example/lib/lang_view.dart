import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 26),
              margin: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                'Choose language',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            _SwitchListTileMenuItem(title: 'عربي', subtitle: 'عربي', locale: context.supportedLocales[1] //BuildContext extension method
                ),
            _Divider(),
            _SwitchListTileMenuItem(title: 'English', subtitle: 'English', locale: context.supportedLocales[0]),
            _Divider(),
            _SwitchListTileMenuItem(title: 'German', subtitle: 'German', locale: context.supportedLocales[2]),
            _Divider(),
            _SwitchListTileMenuItem(title: 'Русский', subtitle: 'Русский', locale: context.supportedLocales[3]),
            _Divider(),
            SizedBox(
              height: 250,
            ),
            Container(
              padding: EdgeInsets.only(top: 26),
              margin: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                'Choose sub language',
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            _SwitchSubListTileMenuItem(title: 'عربي', subtitle: 'عربي', subLocale: context.supportedLocales[1] //BuildContext extension method
                ),
            _Divider(),
            _SwitchSubListTileMenuItem(title: 'English', subtitle: 'English', subLocale: context.supportedLocales[0]),
            _Divider(),
            _SwitchSubListTileMenuItem(title: 'German', subtitle: 'German', subLocale: context.supportedLocales[2]),
            _Divider(),
            _SwitchSubListTileMenuItem(title: 'Русский', subtitle: 'Русский', subLocale: context.supportedLocales[3]),
            _Divider(),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Divider(
        color: Colors.grey,
      ),
    );
  }
}

class _SwitchListTileMenuItem extends StatelessWidget {
  const _SwitchListTileMenuItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.locale,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Locale locale;

  bool isSelected(BuildContext context) => locale == context.locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(
        border: isSelected(context) ? Border.all(color: Colors.blueAccent) : null,
      ),
      child: ListTile(
          dense: true,
          // isThreeLine: true,
          title: Text(
            title,
          ),
          subtitle: Text(
            subtitle,
          ),
          onTap: () async {
            log(locale.toString(), name: toString());
            await context.setLocale(locale); //BuildContext extension method
            Navigator.pop(context);
          }),
    );
  }
}

class _SwitchSubListTileMenuItem extends StatelessWidget {
  const _SwitchSubListTileMenuItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.subLocale,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Locale subLocale;

  bool isSelected(BuildContext context) => subLocale == context.subLocale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(
        border: isSelected(context) ? Border.all(color: Colors.blueAccent) : null,
      ),
      child: ListTile(
          dense: true,
          // isThreeLine: true,
          title: Text(
            title,
          ),
          subtitle: Text(
            subtitle,
          ),
          onTap: () async {
            log(subLocale.toString(), name: toString());
            await context.setSubLocale(subLocale); //BuildContext extension method
            Navigator.pop(context);
          }),
    );
  }
}
