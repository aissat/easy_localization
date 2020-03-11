import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'utils/test_asset_loaders.dart';

BuildContext _context;

class _EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final String path;
  final AssetLoader assetLoader;
  final List<Locale> supportedLocales;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  final bool useOnlyLangCode;

  const _EasyLocalizationDelegate({
    @required this.path,
    @required this.supportedLocales,
    this.useOnlyLangCode = false,
    this.assetLoader = const JsonAssetLoader(),
  });

  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);

  @override
  Future<Localization> load(Locale value) async {
    await Localization.load(
      value,
      path: path,
      useOnlyLangCode: useOnlyLangCode,
      assetLoader: assetLoader,
    );
    return Localization.instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale("en", "US"),
      localizationsDelegates: [
        _EasyLocalizationDelegate(
          path: "path",
          assetLoader: JsonAssetLoader(),
          supportedLocales: [Locale("en", "US")],
        )
      ],
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(context) {
    _context = context;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text('test').tr(context: _context),
          Text("day").plural( 1, context: _context),
        ],
      ),
    );
  }
}

void main() {
  testWidgets(
    '[Localization] of() test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(MyApp());
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();
        final trFinder = find.text('test');
        expect(trFinder, findsOneWidget);
        final pluralFinder = find.text('1 day');
        expect(pluralFinder, findsOneWidget);
        expect(Localization.of(_context), isInstanceOf<Localization>());
        expect(tr("test", context: _context), "test");
        expect(plural("day", 1, context: _context), "1 day");
        expect(plural("day", 2, context: _context), "2 days");
        expect(plural("day", 3, context: _context), "3 other days");
      });
    },
  );
}

