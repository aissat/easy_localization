import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            _SwitchListTileMenuItem(
              title: 'عربي',
              subtitle: 'عربي',
              locale: context.supportedLocales[1],
            ),
            _Divider(),
            _SwitchListTileMenuItem(
              title: 'English',
              subtitle: 'English',
              locale: context.supportedLocales[0],
            ),
            _Divider(),
            _SwitchListTileMenuItem(
              title: 'German',
              subtitle: 'German',
              locale: context.supportedLocales[2],
            ),
            _Divider(),
            _SwitchListTileMenuItem(
              title: 'Русский',
              subtitle: 'Русский',
              locale: context.supportedLocales[3],
            ),
            _Divider(),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Divider(color: Colors.grey),
    );
  }
}

class _SwitchListTileMenuItem extends StatelessWidget {
  final String title;

  final String subtitle;

  final Locale locale;

  const _SwitchListTileMenuItem({
    required this.title,
    required this.subtitle,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(
        border: locale == context.locale
            ? Border.all(color: Colors.blueAccent)
            : null,
      ),
      child: ListTile(
        dense: true,
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () async {
          log(locale.toString(), name: toString());

          await context.setLocale(locale);

          Navigator.pop(context);
        },
      ),
    );
  }
}
