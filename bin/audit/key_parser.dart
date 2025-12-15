import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/src/linked_file_resolver.dart';
import 'package:path/path.dart';
import 'package:easy_localization/src/file_loaders/io_file_loader.dart';

enum KeyPatternType {
  trFunction(pattern: r"""\btr\s*\(\s*['"]([^'"]+)['"](?:(?!gender\s*:)[^)])*\)"""),
  contextTrFunction(pattern: r"""context\s*\.\s*tr\s*\(\s*['"]([^'"]+)['"](?:(?!gender\s*:)[^)])*\)"""),
  stringTrMethod(pattern: r""""([^'"]+)"\s*\.tr\s*\((?:(?!gender\s*:)[^)])*\)"""),
  localeKeys(pattern: r"""LocaleKeys\s*\.\s*([A-Za-z0-9_]+)"""),
  // plural
  pluralFunction(pattern: r"""\bplural\s*\(\s*['"]([^'"]+)['"](?:\s*,[^)]*)?\)""", keywords: ['other']),
  contextPluralFunction(
      pattern: r"""context\s*\.\s*plural\s*\(\s*['"]([^'"]+)['"](?:\s*,[^)]*)?\)""", keywords: ['other']),
  // gender
  trFunctionWithGender(
      pattern: r"""\btr\s*\(\s*['"]([^'"]+)['"]\s*,\s*gender\s*:\s*[^)]*\)""", keywords: ["male", "female"]),
  contextTrFunctionWithGender(
      pattern: r"""context\s*\.\s*tr\s*\(\s*['"]([^'"]+)['"]\s*,\s*gender\s*:\s*[^)]*\)""",
      keywords: ["male", "female"]),
  stringTrMethodWithGender(pattern: r""""([^'"]+)"\s*\.tr\s*\(\s*gender\s*:\s*[^)]*\)""", keywords: ["male", "female"]);

  const KeyPatternType({required this.pattern, this.keywords = const []});

  final String pattern;
  final List<String> keywords;
}

class KeyParser {
  /// Walks [translationsDir], reads every `.json`, flattens nested maps
  /// into dot‑separated keys, and returns a map:
  ///   { 'en': {'home.title', 'home.subtitle', …}, 'fr': { … } }
  /// Also handles linked translation files (those containing ':/file.json' references)
  Future<Map<String, Set<String>>> parseKeysInTranslationsDir(Directory translationsDir) async {
    final result = <String, Set<String>>{};
    const IOFileLoader fileLoader = IOFileLoader();
    const LinkedFileResolver linkedFileResolver = JsonLinkedFileResolver(fileLoader: fileLoader);

    for (var file in translationsDir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.json')) continue;

      final local = basenameWithoutExtension(file.path);
      final langCode = local.split('-').first;
      final hasCountryCode = local.split('-').length > 1;
      final countryCode = hasCountryCode ? local.split('-').last : null;
      final jsonMap = json.decode(file.readAsStringSync()) as Map<String, dynamic>;

      // Process linked files if present using the shared resolver
      final resolvedJson = await linkedFileResolver.resolveLinkedFiles(
        basePath: translationsDir.path,
        languageCode: langCode,
        baseJson: jsonMap,
        countryCode: countryCode,
      );
      result[local] = _flatten(resolvedJson);
    }
    return result;
  }

  Set<String> _flatten(Map<String, dynamic> json, [String parentKey = '']) {
    final keys = <String>{};
    for (var entry in json.entries) {
      final key = entry.key;
      final value = entry.value;

      final newKey = parentKey.isEmpty ? key : '$parentKey.$key';
      if (value is String) {
        keys.add(newKey);
        continue;
      }

      if (value is Map<String, dynamic>) {
        keys.addAll(_flatten(value, newKey));
        continue;
      }

      if (value is List || value is num || value is bool) {
        keys.add(newKey);
      }
    }
    return keys;
  }

  Set<String> parseKeysInSourceDir(Directory srcDir) {
    final used = <String>{};

    List<File> files =
        srcDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
    for (var file in files) {
      final content = file.readAsStringSync();

      // remove all comments to avoid false positives
      final commentPattern = RegExp(r'\/\/.*?$|\/\*.*?\*/', multiLine: true, dotAll: true);
      final commentRemovedContent = content.replaceAll(commentPattern, '');

      for (var patternType in KeyPatternType.values) {
        final pattern = RegExp(patternType.pattern);
        final matches = pattern.allMatches(commentRemovedContent);

        for (var match in matches) {
          if (match.groupCount > 0) {
            String key = match.group(1)!;
            if (pattern.pattern.contains('LocaleKeys')) {
              key = key.replaceAll('_', '.');
            }

            if (patternType.keywords.isNotEmpty) {
              for (var keyword in patternType.keywords) {
                String keyWithKeyword = '$key.$keyword';
                used.add(keyWithKeyword);
              }

              continue;
            }

            used.add(key);
          }
        }
      }
    }

    return used;
  }
}
