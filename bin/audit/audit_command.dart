import 'dart:io';
import 'key_parser.dart';

class AuditCommand {
  Future<void> run({required String transDir, required String srcDir, required bool showWarnings}) async {
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

      final keyParser = KeyParser();
      final allTranslations = await keyParser.parseKeysInTranslationsDir(translationDir);
      final usedKeys = keyParser.parseKeysInSourceDir(sourceDir);

      _report(allTranslations, usedKeys, showWarnings: showWarnings);
    } catch (e) {
      stderr.writeln('Error during audit: $e');
    }
  }

  void _report(Map<String, Set<String>> allTranslations, Set<String> usedKeys, {required bool showWarnings}) {
    stderr.writeln('=== Keys Audit ===');

    for (var lang in allTranslations.keys) {
      final keysInFile = allTranslations[lang]!;
      final missing = usedKeys.difference(keysInFile);
      final missingWithVariables = missing.where((key) => key.contains('\$')).toList();
      final missingWithoutVariables = missing.where((key) => !key.contains('\$')).toList();

      stderr.writeln('\nLanguage: $lang');
      if ((missingWithVariables.isEmpty || !showWarnings) && missingWithoutVariables.isEmpty) {
        stderr.writeln('  ✅ all good!');
      }

      if (missingWithoutVariables.isNotEmpty) {
        stderr.writeln('  🔴 Missing (${missingWithoutVariables.length}):');
        for (var key in missingWithoutVariables) {
          stderr.writeln('    – $key');
        }

        stderr.writeln('\n');
        exit(1);
      }

      if (missingWithVariables.isNotEmpty && showWarnings) {
        stderr.writeln('  🟡 Missing with variables (${missingWithVariables.length}):');
        stderr.writeln('    These keys may not be missing as they contain variables that cannot be verified.');
        for (var key in missingWithVariables) {
          stderr.writeln('    – $key');
        }
      }
    }
  }
}
