## Custom assets loaders for [Easy Localization](https://github.com/aissat/easy_localization) package 

![Pub Version](https://img.shields.io/pub/v/easy_localization_loader?style=flat-square)
![Code Climate issues](https://img.shields.io/github/issues/aissat/easy_localization_loader?style=flat-square)
![GitHub closed issues](https://img.shields.io/github/issues-closed/aissat/easy_localization_loader?style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/aissat/easy_localization_loader?style=flat-square)
![GitHub repo size](https://img.shields.io/github/repo-size/aissat/easy_localization_loader?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/aissat/easy_localization_loader?style=flat-square)
![GitHub stars](https://img.shields.io/github/stars/aissat/easy_localization_loader?style=flat-square)
<!-- ![Coveralls github branch](https://img.shields.io/coveralls/github/aissat/easy_localization/dev?style=flat-square) -->
<!-- ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/aissat/easy_localization/Flutter%20Tester?longCache=true&style=flat-square&logo=github) -->
![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/aissat/easy_localization_loader?style=flat-square)
![GitHub license](https://img.shields.io/github/license/aissat/easy_localization_loader?style=flat-square)

### Supported formats

- [x] JSON (JsonAssetLoader)
- [x] CSV (CsvAssetLoader)
- [x] HTTP (HttpAssetLoader)
- [x] XML (XmlAssetLoader, XmlSingleAssetLoader)
- [x] Yaml (YamlAssetLoader, YamlSingleAssetLoader)
- [x] FILE (FileAssetLoader)

### Configuration

1. Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  #Easy Localization main package
  easy_localization: <last_version>

    # stable version install from https://pub.dev/packages
  easy_localization_loader: <last_version>

  # Dev version install from git REPO
  easy_localization_loader:
    git: https://github.com/aissat/easy_localization_loader.git

```

2. Change assetLoader and patch

```dart
...
void main(){
  runApp(EasyLocalization(
    child: MyApp(),
    supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
    path: 'resources/langs/langs.csv',
    assetLoader: CsvAssetLoader()
  ));
}
...
```

3. All done!.