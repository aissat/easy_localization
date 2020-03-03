import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "",
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
                "Language Menu",
                style: TextStyle(
                  color: Color.fromARGB(255, 166, 166, 166),
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 25),
              margin: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Text(
                "language",
              ),
            ),
            buildDivider(),
            buildSwitchListTileMenuItem(
                context: context,
                title: "عربي",
                subtitle: "عربي",
                locale: Locale("ar", "DZ")),
            buildDivider(),
            buildSwitchListTileMenuItem(
                context: context,
                title: "English",
                subtitle: "English",
                locale: Locale("en", "US")),
            buildDivider(),
          ],
        ),
      ),
    );
  }

  Container buildDivider() => Container(
        margin: EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Divider(
          color: Colors.grey,
        ),
      );

  Container buildSwitchListTileMenuItem(
      {BuildContext context, String title, String subtitle, Locale locale}) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
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
          onTap: () {
            EasyLocalization.of(context).locale = locale;
          }),
    );
  }
}
