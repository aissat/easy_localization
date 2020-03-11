import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/test_asset_loaders.dart';

BuildContext _context;
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: EasyLocalization.of(context).locale,
      supportedLocales: EasyLocalization.of(context).supportedLocales,
      localizationsDelegates: [
        EasyLocalization.of(context).delegate,
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
          Text('test').tr(context: context),
          Text("day").plural(1, context: context),
        ],
      ),
    );
  }
}

void main() {
  SharedPreferences.setMockInitialValues({});
  testWidgets(
    '[EasyLocalization with  JsonAssetLoader]  test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          child: MyApp(),
          path: "path",
          supportedLocales: [Locale("en","US")],
          assetLoader: JsonAssetLoader(),
        ));
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pumpAndSettle();
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

  testWidgets(
    '[EasyLocalization with  RootBundleAssetLoader] test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          child: MyApp(),
          path: "i18n",
          assetLoader: RootBundleAssetLoader(),
          supportedLocales: [Locale("en","US")],
        ));
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pumpAndSettle();
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

testWidgets(
    '[EasyLocalization with  Default AssetLoader] test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          child: MyApp(),
          path: "i18n",
          supportedLocales: [Locale("en","US")],
        ));
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pumpAndSettle();
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
