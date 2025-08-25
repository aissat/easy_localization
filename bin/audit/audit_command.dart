import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/src/linked_file_resolver.dart';
import 'package:path/path.dart';
import '../../lib/src/file_loaders/io_file_loader.dart';

class AuditCommand {
  void run({required String transDir, required String srcDir}) async {
    try {
      final translationDir = Directory(transDir);
      final sourceDir = Directory(srcDir);

      if (!translationDir.existsSync()) {
        stderr.writeln('Error: Translation directory "$transDir" does not exist.');
        return;
      }

      if (!sourceDir.existsSync()) {
        stderr.writeln('Error: Source directory "$srcDir" does not exist.');
        return;
      }

      final allTranslations = await _loadTranslations(translationDir);
      final usedKeys = _scanSourceForKeys(sourceDir);

      _report(allTranslations, usedKeys);
    } catch (e) {
      stderr.writeln('Error during audit: $e');
    }
  }

  /// Walks [translationsDir], reads every `.json`, flattens nested maps
  /// into dot‑separated keys, and returns a map:
  ///   { 'en': {'home.title', 'home.subtitle', …}, 'fr': { … } }
  /// Also handles linked translation files (those containing ':/file.json' references)
  Future<Map<String, Set<String>>> _loadTranslations(Directory translationsDir) async {
    final result = <String, Set<String>>{};
    const IOFileLoader fileLoader = IOFileLoader();
    const LinkedFileResolver linkedFileResolver = JsonLinkedFileResolver(fileLoader: fileLoader);

    for (var file in translationsDir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.json')) continue;

      try {
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
      } catch (e) {
        stderr.writeln('Error reading ${file.path}: $e');
      }
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

  Set<String> _scanSourceForKeys(Directory srcDir) {
    List<RegExp> keyPatterns = [
      // 1) tr('foo.bar') or tr("foo.bar"), with optional args/comma before the )
      RegExp(r"""\btr\s*\(\s*['"]([^'"]+)['"](?:\s*,[^)]*)?\)"""),

      // 2) context.tr('foo.bar') same as above but with the context qualifier
      RegExp(r"""context\s*\.\s*tr\s*\(\s*['"]([^'"]+)['"](?:\s*,[^)]*)?\)"""),

      // 3) 'foo.bar'.tr() or "foo.bar".tr(), allowing whitespace/newlines
      RegExp(r"""['"]([^'"]+)['"]\s*\.\s*tr\s*\(\s*[^)]*\)"""),

      // 4) generated keys: LocaleKeys.foo_bar (whitespace around the dot ok)
      RegExp(r"""LocaleKeys\s*\.\s*([A-Za-z0-9_]+)"""),

      // 5) plural() calls
      RegExp(r"""\bplural\s*\(\s*['"]([^'"]+)['"](?:\s*,[^)]*)?\)"""),

      // 6) context.plural() calls
      RegExp(r"""context\s*\.\s*plural\s*\(\s*['"]([^'"]+)['"](?:\s*,[^)]*)?\)"""),
    ];

    final used = <String>{};

    for (var file in srcDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      try {
        final content = file.readAsStringSync();
        for (var pattern in keyPatterns) {
          final matches = pattern.allMatches(content);
          for (var match in matches) {
            if (match.groupCount > 0) {
              String key = match.group(1)!;
              if (pattern.pattern.contains('LocaleKeys')) {
                key = key.replaceAll('_', '.');
              }
              used.add(key);
            }
          }
        }
      } catch (e) {
        stderr.writeln('Error reading ${file.path}: $e');
      }
    }

    return used;
  }

  void _report(Map<String, Set<String>> allTranslations, Set<String> usedKeys) {
    stderr.writeln('=== Keys Audit ===');

    for (var lang in allTranslations.keys) {
      final keysInFile = allTranslations[lang]!;
      final missing = usedKeys.difference(keysInFile);
      final missingWithVariables = missing.where((key) => key.contains('\$')).toList();
      final missingWithoutVariables = missing.where((key) => !key.contains('\$')).toList();

      stderr.writeln('\nLanguage: $lang');
      if (missingWithVariables.isEmpty && missingWithoutVariables.isEmpty) {
        stderr.writeln('  ✅ all good!');
      }

      if (missingWithoutVariables.isNotEmpty) {
        stderr.writeln('  🔴 Missing (${missingWithoutVariables.length}):');
        for (var key in missingWithoutVariables) {
          stderr.writeln('    – $key');
        }

        stderr.writeln('\n');
      }

      if (missingWithVariables.isNotEmpty) {
        stderr.writeln('  🟡 Missing with variables (${missingWithVariables.length}):');
        stderr.writeln('    These keys may not be missing as they contain variables that cannot be verified.');
        for (var key in missingWithVariables) {
          stderr.writeln('    – $key');
        }
      }
    }
  }
}
