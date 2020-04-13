import 'dart:ui';

import 'package:easy_localization/src/asset_loader.dart';

class JsonAssetLoader extends AssetLoader {
  const JsonAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {
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
      'nested.but.not.nested': 'nested but not nested',
      'nested': {
        'super': {
          'duper': {
            'nested': 'nested.super.duper.nested',
            'nested_with_arg': 'nested.super.duper.nested_with_arg {}',
            'nested_with_named_arg': 'nested.super.duper.nested_with_named_arg {arg}'
          }
        }
      },
      'path': '$fullPath'
    });
  }

}
