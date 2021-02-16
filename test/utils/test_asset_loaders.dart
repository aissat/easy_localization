import 'dart:ui';

import 'package:easy_localization/src/asset_loader.dart';

class JsonAssetLoader extends AssetLoader {
  const JsonAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) {
    return Future.value({
      'test': 'test',
      'test_replace_one': 'test replace {}',
      'test_replace_two': 'test replace {} {}',
      'test_replace_named': 'test named replace {arg1} {arg2}',
      'gender': {'male': 'Hi man ;)', 'female': 'Hello girl :)'},
      'gender_and_replace': {
        'male': 'Hi {} man ;)',
        'female': 'Hello {} girl :)'
      },
      'day': {
        'zero': '{} days',
        'one': '{} day',
        'two': '{} days',
        'few': '{} few days',
        'many': '{} many days',
        'other': '{} other days'
      },
      'money': {
        'zero': '{} has no money',
        'one': '{} has {} dollar',
        'other': '{} has {} dollars',
      },
      'nested.but.not.nested': 'nested but not nested',
      'linked': 'this @:isLinked',
      'isLinked': 'is linked',
      'linkAndModify': 'this is linked and @.upper:modified',
      'modified': 'modified',
      'linkMany': '@:many @.capitalize:locale @:messages',
      'many': 'many',
      'locale': 'locale',
      'messages': 'messages',
      'linkedWithBrackets': 'linked with @.lower:(brackets).',
      'brackets': 'Brackets',
      'nestedArguments': 'this is {} @.undefiend:nestedArg',
      'nestedArg': 'nested {}{}',
      'nestedNamedArguments': '{firstArg} is a @:nestedNamedArg',
      'nestedNamedArg': 'nested {secondArg}{thirdArg}',
      'nested': {
        'super': {
          'duper': {
            'nested': 'nested.super.duper.nested',
            'nested_with_arg': 'nested.super.duper.nested_with_arg {}',
            'nested_with_named_arg':
                'nested.super.duper.nested_with_named_arg {arg}'
          }
        }
      },
      'path': '$fullPath',
      'test_missing_fallback':
          (locale.languageCode == 'fb' ? 'fallback!' : null),
    });
  }
}
