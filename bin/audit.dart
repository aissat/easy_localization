import 'dart:io';

import 'package:args/args.dart';
import 'audit/audit_command.dart';

void main(List<String> args) {
  final actual = args.isEmpty ? ['audit'] : args;
  var parser = ArgParser();

  parser.addOption('translations-dir', abbr: 't', defaultsTo: 'assets/translations');
  parser.addOption('source-dir', abbr: 's', defaultsTo: 'lib');

  try {
    var argResults = parser.parse(actual);
    final transDir = argResults['translations-dir'] as String;
    final srcDir = argResults['source-dir'] as String;

    if (!Directory(transDir).existsSync()) {
      stderr.writeln('Error: Translation directory "$transDir" does not exist.');
      exit(1);
    }

    if (!Directory(srcDir).existsSync()) {
      stderr.writeln('Error: Source directory "$srcDir" does not exist.');
      exit(1);
    }

    AuditCommand().run(transDir: transDir, srcDir: srcDir);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}
