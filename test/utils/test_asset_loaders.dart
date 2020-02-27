import 'package:easy_localization/asset_loader.dart';

class StringAssetLoader extends AssetLoader {
  @override
  Future<String> load(String localePath) {
    return Future.value('''
    {
      "test" : "test",
      "test_replace_one": "test replace {}",
      "test_replace_two": "test replace {} {}",
      "gender":{
        "male": "Hi man ;)",
        "female": "Hello girl :)"
      },
      "gender_and_replace":{
        "male": "Hi {} man ;)",
        "female": "Hello {} girl :)"
      },
      "day": {
        "zero":"{} days",
        "one": "{} day",
        "two": "{} days",
        "few": "{} few days",
        "many": "{} many days",
        "other": "{} other days"
      },
      "path" : "$localePath"
    }
    ''');
  }
}
