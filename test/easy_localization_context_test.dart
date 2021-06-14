import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

late BuildContext _context;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
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
  EasyLocalization.logger.enableLevels = <LevelMessages>[
    LevelMessages.error,
    LevelMessages.warning,
  ];

  SharedPreferences.setMockInitialValues({});
  EasyLocalization.logger.enableLevels = <LevelMessages>[
    LevelMessages.error,
    LevelMessages.warning,
  ];

  await EasyLocalization.ensureInitialized();

  group('BuildContext', () {
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

          expect(_context.supportedLocales, [Locale('ar')]);
          expect(_context.locale, Locale('ar'));
          expect(_context.fallbackLocale, Locale('ar'));
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
            ], // Locale('en', 'US'), Locale('ar','DZ')
            child: MyApp(),
          ));
          // await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(_context.supportedLocales, [Locale('ar')]);
          expect(_context.locale, Locale('ar'));
          expect(_context.fallbackLocale, null);
        });
      },
    );

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
              ], // Locale('en', 'US'), Locale('ar','DZ')
              child: MyApp(),
            ));
            // await tester.idle();
            // The async delegator load will require build on the next frame. Thus, pump
            await tester.pump();

            expect(_context.locale, Locale('ar', 'DZ'));
            await _context.deleteSaveLocale();
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
              ], // Locale('en', 'US'), Locale('ar','DZ')
              child: MyApp(),
            ));
            // await tester.idle();
            // The async delegator load will require build on the next frame. Thus, pump
            await tester.pump();

            expect(_context.locale, Locale('en', 'US'));
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
              ], // Locale('en', 'US'), Locale('ar','DZ')
              child: MyApp(),
            ));
            // await tester.idle();
            // The async delegator load will require build on the next frame. Thus, pump
            await tester.pump();

            expect(_context.deviceLocale.toString(), Platform.localeName);
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

            expect(_context.locale, Locale('ar', 'DZ'));
            // reset to device locale
            await _context.resetLocale();
            await tester.pump();
            expect(_context.locale, Locale('en', 'US'));
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
              ], // Locale('en', 'US'), Locale('ar','DZ')
              child: MyApp(),
            ));
            await tester.idle();
            // The async delegator load will require build on the next frame. Thus, pump
            await tester.pumpAndSettle();

            expect(_context.deviceLocale.toString(), Platform.localeName);
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

            expect(_context.locale, Locale('ar', 'DZ'));
            // reset to device locale
            await _context.resetLocale();
            await tester.pumpAndSettle();
            expect(_context.locale, Locale('en', 'US'));
          });
        },
      );
    });
  });
}
