#### Code generation

Run `flutter pub run easy_localization:generate -h` for help.

Code generation supports json files. 

Steps:

1. Open your terminal in the folder's path containing your project
2. Run in terminal `flutter pub run easy_localization:generate`
3. Change asset loader and past import.

```dart
import 'generated/codegen_loader.g.dart';

void main(){
  runApp(EasyLocalization(
    child: MyApp(),
    supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
    path: 'resources/langs',
    assetLoader: CodegenLoader()
  ));
}
```

4. All done!

#### Generate keys

A code generation tool is helpful if you have many localization keys, as the code editor will automatically prompt keys.

Steps:
1. Open your terminal in the folder's path containing your project 
2. Run in terminal `flutter pub run easy_localization:generate -f keys -o locale_keys.g.dart`
3. Past import.

```dart
import 'generated/locale_keys.g.dart';
```
4. All done!

How to usage generated keys:

```dart
print(LocaleKeys.title.tr()); //String
//or
Text(LocaleKeys.title).tr(); //Widget
```