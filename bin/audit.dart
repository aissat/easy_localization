import 'package:args/args.dart';
import 'audit/audit_command.dart';

void main(List<String> args) {
  final actual = args.isEmpty ? ['audit'] : args;
  var parser = ArgParser();

  parser.addOption('translations-dir', abbr: 't', defaultsTo: 'assets/translations');
  parser.addOption('source-dir', abbr: 's', defaultsTo: 'lib');

  var argResults = parser.parse(actual);
  AuditCommand().run(
    transDir: argResults['translations-dir'],
    srcDir: argResults['source-dir'],
  );
}
