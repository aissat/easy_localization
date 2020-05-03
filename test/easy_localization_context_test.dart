import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

BuildContext _context;

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
          Text('test').tr(context: context),
          Text('day').plural(1, context: context),
        ],
      ),
    );
  }
}

void main() {
  SharedPreferences.setMockInitialValues({});
  group('BuildContext', () {

    testWidgets(
      '[EasyLocalization] locale test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            child: MyApp(),
            path: 'i18n',
            supportedLocales: [Locale('en', 'US')],
          ));
          await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pumpAndSettle();

          expect(_context.supportedLocales, [Locale('en', 'US')]);
          expect(_context.locale, Locale('en', 'US'));

          var l = Locale('en', 'US');
          _context.locale = l;
          await tester.pumpAndSettle();
          expect(_context.locale, Locale('en', 'US'));

          final trFinder = find.text('test');
          expect(trFinder, findsOneWidget);
          final pluralFinder = find.text('1 day');
          expect(pluralFinder, findsOneWidget);

          expect(tr('test', context: _context), 'test');
          expect(plural('day', 1, context: _context), '1 day');
          expect(plural('day', 2, context: _context), '2 days');
          expect(plural('day', 3, context: _context), '3 other days');
          expect(_context.locale, Locale('en', 'US'));

          l = Locale('ar', 'DZ');
          expect(() {
            _context.locale = l;
          }, throwsAssertionError);
          await tester.pumpAndSettle();
          expect(_context.locale, Locale('en', 'US'));
        });
      },
    );

    testWidgets(
      '[EasyLocalization] change loacle test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            child: MyApp(),
            path: 'i18n',
            supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
          ));
          await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pumpAndSettle();

          expect(Localization.of(_context), isInstanceOf<Localization>());
          expect(_context.supportedLocales,
              [Locale('en', 'US'), Locale('ar', 'DZ')]);
          expect(_context.locale, Locale('en', 'US'));

          var trFinder = find.text('test');
          expect(trFinder, findsOneWidget);
          var pluralFinder = find.text('1 day');
          expect(pluralFinder, findsOneWidget);

          expect(tr('test', context: _context), 'test');
          expect(plural('day', 1, context: _context), '1 day');
          expect(plural('day', 2, context: _context), '2 days');
          expect(plural('day', 3, context: _context), '3 other days');

          var l = Locale('en', 'US');
          _context.locale = l;
          await tester.pumpAndSettle();
          expect(_context.locale, l);

          l = Locale('ar', 'DZ');
          _context.locale = l;
          await tester.idle();
          await tester.pumpAndSettle();
          expect(_context.locale, l);

          l = Locale('en', 'US');
          _context.locale = l;
          await tester.idle();
          await tester.pumpAndSettle();
          expect(_context.locale, l);

          l = Locale('en', 'UK');
          expect(() => {_context.locale = l}, throwsAssertionError);

          l = Locale('ar', 'DZ');
          _context.locale = l;
          await tester.idle();
          await tester.pumpAndSettle();
          expect(_context.locale, l);
        });
      },
    );

    testWidgets(
      '[EasyLocalization] loacle ar_DZ test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            child: MyApp(),
            path: 'i18n',
            supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
          ));

          await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pumpAndSettle();

          _context.locale = Locale('ar', 'DZ');

          await tester.pumpAndSettle();

          expect(_context.supportedLocales,
              [Locale('en', 'US'), Locale('ar', 'DZ')]);
          expect(_context.locale, Locale('ar', 'DZ'));

          var trFinder = find.text('اختبار');
          expect(trFinder, findsOneWidget);
          var pluralFinder = find.text('1 يوم');
          expect(pluralFinder, findsOneWidget);

          expect(Localization.of(_context), isInstanceOf<Localization>());
          expect(tr('test', context: _context), 'اختبار');
          expect(plural('day', 1, context: _context), '1 يوم');
          expect(plural('day', 2, context: _context), '2 أيام');
          expect(plural('day', 3, context: _context), '3 أيام');

          // var l = Locale('en', 'US');
          // _context.locale = l;
          // expect(_context.locale, l);
        });
      },
    );

    testWidgets(
      '[EasyLocalization] _getFallbackLocale() fallbackLocale!=null test',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            child: MyApp(),
            path: 'i18n',
            saveLocale: false,
            useOnlyLangCode: true,
            supportedLocales: [Locale('ar')],
            fallbackLocale: Locale('ar'),
          ));
          await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pumpAndSettle();

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
            child: MyApp(),
            path: 'i18n',
            saveLocale: false,
            useOnlyLangCode: true,
            // fallbackLocale:Locale('en') ,
            supportedLocales: [
              Locale('ar')
            ], // Locale('en', 'US'), Locale('ar','DZ')
          ));
          await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pumpAndSettle();

          expect(_context.supportedLocales, [Locale('ar')]);
          expect(_context.locale, Locale('ar'));
          expect(_context.fallbackLocale, null);
        });
      },
    );

    group('SharedPreferences deleteSaveLocale()', () {
      setUpAll(() {
        SharedPreferences.setMockInitialValues({
          'locale': 'ar_DZ',
        });
      });
      testWidgets(
        '[EasyLocalization] deleteSaveLocale  test',
        (WidgetTester tester) async {
          await tester.runAsync(() async {
            await tester.pumpWidget(EasyLocalization(
              child: MyApp(),
              path: 'i18n',
              // fallbackLocale:Locale('en') ,
              supportedLocales: [
                Locale('en', 'US'),
                Locale('ar', 'DZ')
              ], // Locale('en', 'US'), Locale('ar','DZ')
            ));
            await tester.idle();
            // The async delegator load will require build on the next frame. Thus, pump
            await tester.pumpAndSettle();

            expect(_context.locale, Locale('ar', 'DZ'));
            _context.deleteSaveLocale();
          });
        },
      );

      testWidgets(
        '[EasyLocalization] after deleteSaveLocale test',
        (WidgetTester tester) async {
          await tester.runAsync(() async {
            await tester.pumpWidget(EasyLocalization(
              child: MyApp(),
              path: 'i18n',
              // fallbackLocale:Locale('en') ,
              supportedLocales: [
                Locale('en', 'US'),
                Locale('ar', 'DZ')
              ], // Locale('en', 'US'), Locale('ar','DZ')
            ));
            await tester.idle();
            // The async delegator load will require build on the next frame. Thus, pump
            await tester.pumpAndSettle();

            expect(_context.locale, Locale('en', 'US'));
          });
        },
      );
    });
  });
}
