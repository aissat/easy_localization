# easy_localization v3 vs v4 — API comparison

## 1. Basic setup (main.dart)

### v3.0.8
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      assetLoader: const RootBundleAssetLoader(),
    ),
  );
}
```

### v4
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized(
    assetLoader: const RootBundleAssetLoader(path: 'assets/translations'),
  );
  runApp(
    EasyLocalization(
      child: MyApp(),
    ),
  );
}
```

---

## 2. Asset loader — custom implementation

### v3.0.8
```dart
class FileAssetLoader extends AssetLoader {
  const FileAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final file = File('$path/${locale.languageCode}.json');
    return json.decode(await file.readAsString());
  }
}

// Usage:
EasyLocalization(
  path: 'assets/translations',
  assetLoader: const FileAssetLoader(),
)
```

### v4
```dart
class FileAssetLoader extends AssetLoader {
  const FileAssetLoader({required String path})
      : super(path: path);

  @override
  Future<Map<String, dynamic>> load({Locale? locale}) async {
    final file = File('$path/${locale!.languageCode}.json');
    return json.decode(await file.readAsString());
  }
}

// Usage:
await EasyLocalization.ensureInitialized(
  assetLoader: const FileAssetLoader(path: 'assets/translations'),
);
```

---

## 3. Using translations in widgets

Both versions share the same `tr()`, `plural()`, `trExists()` API:

```dart
Text('greeting').tr()

Text('greeting').tr(args: ['World'])

Text('welcome').tr(namedArgs: {'name': 'Alice'})

Text('counter').plural(5)

context.tr('greeting')

context.plural('items', 5)
```

---

## 4. Changing locale

Both versions:

```dart
context.setLocale(const Locale('ar'));
context.resetLocale();
```

---

## 5. Asset file structure

Both expect the same JSON structure:

```
assets/translations/
├── en.json     { "greeting": "Hello", ... }
└── ar.json     { "greeting": "مرحبا", ... }
```

Or with country codes (when `useOnlyLangCode: false`, default):

```
assets/translations/
├── en-US.json
└── ar-DZ.json
```

---

## 6. Key API changes summary

| Aspect | v3.0.8 | v4 |
|---|---|---|
| `supportedLocales` | Required in widget | Removed from widget |
| `path` | Required in widget | Moved to `AssetLoader` constructor |
| `assetLoader` | Widget constructor param | `ensureInitialized()` param |
| `RootBundleAssetLoader` | `const RootBundleAssetLoader()` | `const RootBundleAssetLoader(path: '...')` |
| `AssetLoader.load()` | `load(String path, Locale locale)` | `load({Locale? locale})` |
| `useFallbackTranslationsForEmptyResources` | Supported | Removed |
| `ignorePluralRules` | Supported | Removed |
| `extraAssetLoaders` | Supported | Removed |
| `ensureInitialized()` | No params | Takes `assetLoader` + optional `storage` |
| `storage` | Hardcoded `SharedPreferences` | `IEasyLocalizationStorage` interface (`SharedPreferencesStorage` / `InMemoryStorage`) |
| `CachedAssetLoader` | Not available | New (built-in caching) |
| `OptimizedAssetLoader` | Not available | New (extends RootBundleAssetLoader with caching) |
