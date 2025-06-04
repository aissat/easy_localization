import 'package:easy_localization/easy_localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'easy_localization_context_test.dart';

Future<void> main() async {
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

  testWidgets(
    'Ensure that loading the translations will update its depending widgets',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('de')],
          path: '../../i18n',
          fallbackLocale: const Locale('en'),
          child: const I18nObserver(child: MyApp()),
        ));
        await tester.pump();
      });
    },
  );
}

class I18nObserver extends StatefulWidget {
  final Widget child;

  const I18nObserver({Key? key, required this.child}) : super(key: key);

  @override
  State<I18nObserver> createState() => _I18nObserverState();
}

class _I18nObserverState extends State<I18nObserver> {
  var _firstUpdate = true;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void didChangeDependencies() {
    // use the dependOnInheritedWidgetOfExactType pattern
    EasyLocalization.of(context);

    super.didChangeDependencies();

    if (_firstUpdate) {
      _firstUpdate = false;
      expect(
        'test'.tr(),
        'test',
        reason: 'The translation cannot be found yet',
      );
    } else {
      expect(
        'test'.tr(),
        'test_en',
        reason: 'The translation should be loaded on the second call '
            'of didChangeDependencies()',
      );
    }
  }
}
