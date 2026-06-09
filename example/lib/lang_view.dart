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
        // backgroundColor: Colors.white,
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
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            _SwitchListTileMenuItem(
                title: 'عربي',
                subtitle: 'عربي',
                locale:
                    context.supportedLocales[1] //BuildContext extension method
                ),
            _Divider(),
            _SwitchListTileMenuItem(
                title: 'English',
                subtitle: 'English',
                locale: context.supportedLocales[0]),
            _Divider(),
            _SwitchListTileMenuItem(
                title: 'German',
                subtitle: 'German',
                locale: context.supportedLocales[2]),
            _Divider(),
            _SwitchListTileMenuItem(
                title: 'Русский',
                subtitle: 'Русский',
                locale: context.supportedLocales[3]),
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
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 24),
        decoration: BoxDecoration(
          border: isSelected(context)
              ? Border.all(color: Theme.of(context).primaryColor)
              : null,
        ),
        child: ListTile(
            dense: true,
            title: Text(
              title,
            ),
            subtitle: Text(
              subtitle,
            ),
            onTap: () async {
              log(locale.toString(), name: toString());
              final sw = Stopwatch()..start();
              await context.setLocale(locale); //BuildContext extension method
              sw.stop();
              final ms = sw.elapsedMicroseconds / 1000;
              debugPrint('BENCH\tswitch (interactive: ${locale.toString().padRight(8)})\t${ms.toStringAsFixed(2)} ms');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Switch time: ${ms.toStringAsFixed(2)} ms'),
                    duration: const Duration(seconds: 1),
                  ),
                );
                Navigator.pop(context);
              }
            }),
      ),
    );
  }
}
