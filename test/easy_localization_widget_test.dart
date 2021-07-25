import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/test_asset_loaders.dart';

late BuildContext _context;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: EasyLocalization.of(context)!.locale,
      supportedLocales: EasyLocalization.of(context)!.supportedLocales,
      localizationsDelegates: EasyLocalization.of(context)!.delegates,
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
          Text('test').tr(),
          Text('day').plural(1),
        ],
      ),
    );
  }
}

void main() async {
  SharedPreferences.setMockInitialValues({});
  EasyLocalization.logger.enableLevels = <LevelMessages>[
    LevelMessages.error,
    LevelMessages.warning,
  ];
  await EasyLocalization.ensureInitialized();

  testWidgets(
    '[EasyLocalization with  JsonAssetLoader]  test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'path',
          supportedLocales: [Locale('en', 'US')],
          assetLoader: JsonAssetLoader(),
          child: MyApp(),
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(Localization.of(_context), isInstanceOf<Localization>());
        expect(Localization.instance, isInstanceOf<Localization>());
        expect(Localization.instance, Localization.of(_context));
        expect(EasyLocalization.of(_context)!.supportedLocales,
            [Locale('en', 'US')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));

        final trFinder = find.text('test');
        expect(trFinder, findsOneWidget);
        final pluralFinder = find.text('1 day');
        expect(pluralFinder, findsOneWidget);

        expect(tr('test'), 'test');
        expect(plural('day', 1), '1 day');
        expect(plural('day', 2), '2 days');
        expect(plural('day', 3), '3 other days');

        expect('test'.tr(), 'test');
        expect('day'.plural(1), '1 day');
      });
    },
  );

  testWidgets(
    '[EasyLocalization with  RootBundleAssetLoader] test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18n',
          assetLoader: RootBundleAssetLoader(),
          supportedLocales: [Locale('en', 'US')],
          child: MyApp(),
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(EasyLocalization.of(_context)!.supportedLocales,
            [Locale('en', 'US')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));

        final trFinder = find.text('test');
        expect(trFinder, findsOneWidget);
        final pluralFinder = find.text('1 day');
        expect(pluralFinder, findsOneWidget);
        expect(tr('test'), 'test');
        expect(plural('day', 1), '1 day');
        expect(plural('day', 2), '2 days');
        expect(plural('day', 3), '3 other days');
      });
    },
  );

  testWidgets(
    '[EasyLocalization with  Default AssetLoader] test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18n',
          supportedLocales: [Locale('en', 'US')],
          child: MyApp(),
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(EasyLocalization.of(_context)!.supportedLocales,
            [Locale('en', 'US')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));

        final trFinder = find.text('test');
        expect(trFinder, findsOneWidget);
        final pluralFinder = find.text('1 day');
        expect(pluralFinder, findsOneWidget);

        expect(tr('test'), 'test');
        expect(plural('day', 1), '1 day');
        expect(plural('day', 2), '2 days');
        expect(plural('day', 3), '3 other days');
      });
    },
  );
  testWidgets(
    '[EasyLocalization with  Error path] test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18',
          supportedLocales: [Locale('en', 'US')],
          child: MyApp(),
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();
        final trFinder =
            find.byWidgetPredicate((widget) => widget is ErrorWidget);
        expect(trFinder, findsOneWidget);
        await tester.pump();
      });
    },
  );
  testWidgets(
    '[EasyLocalization] change loacle test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18n',
          supportedLocales: [Locale('en', 'US')],
          child: MyApp(),
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(EasyLocalization.of(_context)!.supportedLocales,
            [Locale('en', 'US')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));

        var l = Locale('en', 'US');
        await EasyLocalization.of(_context)!.setLocale(l);
        await tester.pump();
        expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));

        final trFinder = find.text('test');
        expect(trFinder, findsOneWidget);
        final pluralFinder = find.text('1 day');
        expect(pluralFinder, findsOneWidget);

        expect(tr('test'), 'test');
        expect(plural('day', 1), '1 day');
        expect(plural('day', 2), '2 days');
        expect(plural('day', 3), '3 other days');
        expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));

        l = Locale('ar', 'DZ');
        expect(() async {
          await EasyLocalization.of(_context)!.setLocale(l);
        }, throwsAssertionError);
        await tester.pump();
        expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));
      });
    },
  );

  testWidgets(
    '[EasyLocalization] change loacle test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18n',
          supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
          child: MyApp(),
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(Localization.of(_context), isInstanceOf<Localization>());
        expect(EasyLocalization.of(_context)!.supportedLocales,
            [Locale('en', 'US'), Locale('ar', 'DZ')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));

        var trFinder = find.text('test');
        expect(trFinder, findsOneWidget);
        var pluralFinder = find.text('1 day');
        expect(pluralFinder, findsOneWidget);

        expect(tr('test'), 'test');
        expect(plural('day', 1), '1 day');
        expect(plural('day', 2), '2 days');
        expect(plural('day', 3), '3 other days');

        var l = Locale('en', 'US');
        await EasyLocalization.of(_context)!.setLocale(l);
        await tester.pump();
        expect(EasyLocalization.of(_context)!.locale, l);

        l = Locale('ar', 'DZ');
        await EasyLocalization.of(_context)!.setLocale(l);
        // await tester.idle();
        await tester.pump();
        expect(EasyLocalization.of(_context)!.locale, l);

        l = Locale('en', 'US');
        await EasyLocalization.of(_context)!.setLocale(l);
        // await tester.idle();
        await tester.pump();
        expect(EasyLocalization.of(_context)!.locale, l);

        l = Locale('en', 'UK');
        expect(() async => {await EasyLocalization.of(_context)!.setLocale(l)},
            throwsAssertionError);

        l = Locale('ar', 'DZ');
        await EasyLocalization.of(_context)!.setLocale(l);
        // await tester.idle();
        await tester.pump();
        expect(EasyLocalization.of(_context)!.locale, l);
      });
    },
  );

  testWidgets(
    '[EasyLocalization] loacle ar_DZ test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18n',
          supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
          child: MyApp(),
        ));

        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        await EasyLocalization.of(_context)!.setLocale(Locale('ar', 'DZ'));

        await tester.pump();

        expect(EasyLocalization.of(_context)!.supportedLocales,
            [Locale('en', 'US'), Locale('ar', 'DZ')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('ar', 'DZ'));

        var trFinder = find.text('اختبار');
        expect(trFinder, findsOneWidget);
        var pluralFinder = find.text('1 يوم');
        expect(pluralFinder, findsOneWidget);

        expect(Localization.of(_context), isInstanceOf<Localization>());
        expect(tr('test'), 'اختبار');
        expect(plural('day', 1), '1 يوم');
        expect(plural('day', 2), '2 أيام');
        expect(plural('day', 3), '3 أيام');

        // var l = Locale('en', 'US');
        // EasyLocalization.of(_context).locale = l;
        // expect(EasyLocalization.of(_context).locale, l);
      });
    },
  );

  testWidgets(
    '[EasyLocalization] fallbackLocale with doesn\'t saveLocale test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18n',
          saveLocale: false,
          useOnlyLangCode: true,
          supportedLocales: [
            Locale('en'),
            Locale('ar')
          ],
          child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(EasyLocalization.of(_context)!.supportedLocales,
            [Locale('en'), Locale('ar')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('en'));

        var l = Locale('en');
        await EasyLocalization.of(_context)!.setLocale(l);
        expect(EasyLocalization.of(_context)!.locale, l);
      });
    },
  );

  testWidgets(
    '[EasyLocalization] fallbackLocale=null with doesn\'t saveLocale test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18n',
          saveLocale: false,
          useOnlyLangCode: true,
          supportedLocales: [
            Locale('en'),
            Locale('ar')
          ],
          child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(EasyLocalization.of(_context)!.supportedLocales,
            [Locale('en'), Locale('ar')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('en'));

        var l = Locale('en');
        await EasyLocalization.of(_context)!.setLocale(l);
        expect(EasyLocalization.of(_context)!.locale, l);
      });
    },
  );

  testWidgets(
    '[EasyLocalization] _getFallbackLocale() fallbackLocale!=null test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18n',
          saveLocale: false,
          useOnlyLangCode: true,
          supportedLocales: [Locale('ar')],
          fallbackLocale: Locale('ar'),
          child: MyApp(),
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(EasyLocalization.of(_context)!.supportedLocales, [Locale('ar')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('ar'));
        expect(EasyLocalization.of(_context)!.fallbackLocale, Locale('ar'));
      });
    },
  );

  testWidgets(
    '[EasyLocalization] _getFallbackLocale()  fallbackLocale==null test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          path: 'i18n',
          saveLocale: false,
          useOnlyLangCode: true,
          // fallbackLocale:Locale('en') ,
          supportedLocales: [
            Locale('ar')
          ],
          child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
        ));
        // await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(EasyLocalization.of(_context)!.supportedLocales, [Locale('ar')]);
        expect(EasyLocalization.of(_context)!.locale, Locale('ar'));
        expect(EasyLocalization.of(_context)!.fallbackLocale, null);
      });
    },
  );

  group('SharedPreferences SavedLocale NULL', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'locale': '',
      });
    });

    testWidgets(
      '[EasyLocalization] SavedLocale()  null locale without country code',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            // fallbackLocale:Locale('en') ,
            supportedLocales: [Locale('en'), Locale('ar')],
            child: MyApp(), //
          ));
          // await tester.idle();
          await tester.pump(Duration(seconds: 2));
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.supportedLocales,
              [Locale('en'), Locale('ar')]);
          expect(EasyLocalization.of(_context)!.locale, Locale('en'));
          expect(EasyLocalization.of(_context)!.fallbackLocale, null);
        });
      },
    );
    testWidgets(
      '[EasyLocalization] SavedLocale()  test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            // fallbackLocale:Locale('en') ,
            supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: MyApp(), //
          ));
          // await tester.idle();
          await tester.pump(Duration(seconds: 2));
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.supportedLocales,
              [Locale('en', 'US'), Locale('ar', 'DZ')]);
          expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));
          expect(EasyLocalization.of(_context)!.fallbackLocale, null);
        });
      },
    );
    testWidgets(
      '[EasyLocalization] startLocale  test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            startLocale: Locale('ar', 'DZ'),
            // fallbackLocale:Locale('en') ,
            supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: MyApp(), //
          ));
          // await tester.idle();
          await tester.pump(Duration(seconds: 2));
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.supportedLocales,
              [Locale('en', 'US'), Locale('ar', 'DZ')]);
          expect(EasyLocalization.of(_context)!.locale, Locale('ar', 'DZ'));
          expect(EasyLocalization.of(_context)!.fallbackLocale, null);
        });
      },
    );
  });

  group('SharedPreferences saveLocale', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({
        'locale': 'ar',
      });
      await EasyLocalization.ensureInitialized();
    });

    testWidgets(
      '[EasyLocalization] useOnlyLangCode true test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            saveLocale: true,
            // fallbackLocale:Locale('en') ,
            useOnlyLangCode: true,
            supportedLocales: [
              Locale('en'),
              Locale('ar')
            ],
            child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ));
          // await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.supportedLocales,
              [Locale('en'), Locale('ar')]);
          expect(EasyLocalization.of(_context)!.locale, Locale('ar'));
          expect(EasyLocalization.of(_context)!.fallbackLocale, null);
        });
      },
    );
  });

  group('SharedPreferences saveLocale', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({
        'locale': 'ar_DZ',
      });
      await EasyLocalization.ensureInitialized();
    });

    testWidgets(
      '[EasyLocalization] saveLocale true  test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            saveLocale: true,
            // fallbackLocale:Locale('en') ,
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ar', 'DZ')
            ],
            child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ));
          // await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.supportedLocales,
              [Locale('en', 'US'), Locale('ar', 'DZ')]);
          expect(EasyLocalization.of(_context)!.locale, Locale('ar', 'DZ'));
          expect(EasyLocalization.of(_context)!.fallbackLocale, null);
        });
      },
    );

    testWidgets(
      '[EasyLocalization] saveLocale false test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            saveLocale: false,
            // fallbackLocale:Locale('en') ,
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ar', 'DZ')
            ],
            child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ));
          // await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.supportedLocales,
              [Locale('en', 'US'), Locale('ar', 'DZ')]);
          expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));

          await EasyLocalization.of(_context)!.setLocale(Locale('en', 'US'));
        });
      },
    );
  });
  group('SharedPreferences deleteSaveLocale()', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({
        'locale': 'ar_DZ',
      });
      await EasyLocalization.ensureInitialized();
    });
    testWidgets(
      '[EasyLocalization] deleteSaveLocale  test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            // fallbackLocale:Locale('en') ,
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ar', 'DZ')
            ],
            child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ));
          // await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.locale, Locale('ar', 'DZ'));
          await EasyLocalization.of(_context)!.deleteSaveLocale();
        });
      },
    );

    testWidgets(
      '[EasyLocalization] after deleteSaveLocale test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            // fallbackLocale:Locale('en') ,
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ar', 'DZ')
            ],
            child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ));
          // await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));
        });
      },
    );

    testWidgets(
      '[EasyLocalization] device locale  test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ar', 'DZ')
            ],
            child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ));
          // await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.deviceLocale.toString(),
              Platform.localeName);
        });
      },
    );

    testWidgets(
      '[EasyLocalization] reset device locale  test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ar', 'DZ')
            ], // Locale('en', 'US'), Locale('ar','DZ')
            startLocale: Locale('ar', 'DZ'),
            child: MyApp(),
          ));
          // await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(EasyLocalization.of(_context)!.locale, Locale('ar', 'DZ'));
          // reset to device locale
          await _context.resetLocale();
          await tester.pump();
          expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));
        });
      },
    );

    testWidgets(
      '[EasyLocalization] device locale  test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ar', 'DZ')
            ],
            child: MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ));
          await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pumpAndSettle();

          expect(EasyLocalization.of(_context)!.deviceLocale.toString(),
              Platform.localeName);
        });
      },
    );

    testWidgets(
      '[EasyLocalization] reset device locale  test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            path: 'i18n',
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ar', 'DZ')
            ], // Locale('en', 'US'), Locale('ar','DZ')
            startLocale: Locale('ar', 'DZ'),
            child: MyApp(),
          ));
          await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pumpAndSettle();

          expect(EasyLocalization.of(_context)!.locale, Locale('ar', 'DZ'));
          // reset to device locale
          await _context.resetLocale();
          await tester.pumpAndSettle();
          expect(EasyLocalization.of(_context)!.locale, Locale('en', 'US'));
        });
      },
    );
  });
}
