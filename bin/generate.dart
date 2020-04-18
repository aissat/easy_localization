import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> args) {
  if (_isHelpCommand(args)) {
    _printHelperDisplay();
  } else {
    handleLangFiles(_generateOption(args));
  }
}

bool _isHelpCommand(List<String> args) {
  return args.length == 1 && (args[0] == '--help' || args[0] == '-h');
}

void _printHelperDisplay() {
  var parser = _generateArgParser(null);
  print(parser.usage);
}

GenerateOptions _generateOption(List<String> args) {
  var generateOptions = GenerateOptions();
  var parser = _generateArgParser(generateOptions);
  parser.parse(args);
  return generateOptions;
}

ArgParser _generateArgParser(GenerateOptions generateOptions) {
  var parser = ArgParser();

  parser.addOption('source-dir',
      abbr: 's',
      defaultsTo: 'resources/langs',
      callback: (String x) => generateOptions.sourceDir = x,
      help: 'Source folder contains all string json files');

  parser.addOption('output-dir',
      abbr: 'O',
      defaultsTo: 'lib/generated',
      callback: (String x) => generateOptions.outputDir = x,
      help: 'Output folder stores generated file');

  parser.addOption('output-file',
      abbr: 'o',
      defaultsTo: 'codegen_loader.g.dart',
      callback: (String x) => generateOptions.outputFile = x,
      help: 'Output file name');

  parser.addOption('format',
      abbr: 'f',
      defaultsTo: 'json',
      callback: (String x) => generateOptions.format = x,
      help: 'Support json, dart formats',
      allowed: ['json', 'keys']);

  return parser;
}

class GenerateOptions {
  String sourceDir;
  String templateLocale;
  String outputDir;
  String outputFile;
  String format;

  @override
  String toString() {
    return 'format: $format sourceDir: $sourceDir outputDir: $outputDir outputFile: $outputFile';
  }
}

void handleLangFiles(GenerateOptions options) async {
  final current = Directory.current;
  final source = Directory.fromUri(Uri.parse(options.sourceDir));
  final output = Directory.fromUri(Uri.parse(options.outputDir));
  final sourcePath = Directory(path.join(current.path, source.path));
  final outputPath =
      Directory(path.join(current.path, output.path, options.outputFile));

  if (!await sourcePath.exists()) {
    printError('Source path does not exist');
    return;
  }

  var files = await dirContents(sourcePath);
  //filtering format
  files = files.where((f) => f.path.contains('.json')).toList();
  if (files.isNotEmpty) {
    generateFile(files, outputPath, options.format);
  } else {
    printError('Source path empty');
  }
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      onDone: () => completer.complete(files));
  return completer.future;
}

void generateFile(
    List<FileSystemEntity> files, Directory outputPath, String format) async {
  var generatedFile = File(outputPath.path);
  if (!generatedFile.existsSync()) {
    generatedFile.createSync(recursive: true);
  }

  var classBuilder = StringBuffer();

  switch (format) {
    case 'json':
      await _writeJson(classBuilder, files);
      break;
    case 'keys':
      await _writekeys(classBuilder, files);
      break;
    // case 'csv':
    //   await _writeCsv(classBuilder, files);
    // break;
    default:
      printError('Format not support');
  }

  classBuilder.writeln('}');
  generatedFile.writeAsStringSync(classBuilder.toString());

  printInfo('All done! File generated in ${outputPath.path}');
}

Future _writekeys(StringBuffer classBuilder, List<FileSystemEntity> files) async {
  var file = '''
// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

abstract class  LocaleKeys {
''';

  final fileData = File(files.first.path);

  Map<String, dynamic> translations =
      json.decode(await fileData.readAsString());

  file += _resolv(translations);

  classBuilder.writeln(file);
}

String _resolv(Map<String, dynamic> translations, [String hKey]) {
  var file = '';
  final l = ['few', 'many', 'one', 'other', 'two', 'zero', 'male', 'female'];

  final sortedKeys = translations.keys.toList();

  for (var key in sortedKeys) {
    if (translations[key] is Map) {
      file += _resolv(translations[key], key);
    }
    if (!l.contains(key)) {
      hKey!=null ?
      file +=  '  static const $hKey\_$key = \'$hKey.$key\';\n' :
      file +=  '  static const $key = \'$key\';\n';
    }
  }

  return file;
}

Future _writeJson(
    StringBuffer classBuilder, List<FileSystemEntity> files) async {
  var gFile = '''
// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart
import 'dart:ui';

import 'package:easy_localization/src/asset_loader.dart';

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {
    return Future.value(mapLocales[locale.toString()]);
  }

  ''';

  final listLocales = [];

  for (var file in files) {
    final localeName =
        path.basename(file.path).replaceFirst('.json', '').replaceAll('-', '_');
    listLocales.add('"$localeName": $localeName');
    final fileData = File(file.path);

    Map<String, dynamic> data = json.decode(await fileData.readAsString());

    final mapString = JsonEncoder.withIndent('  ').convert(data);
    gFile += '  static const Map<String,dynamic> $localeName = ${mapString};\n';
  }

  gFile +=
      '  static const Map<String, Map<String,dynamic>> mapLocales = \{${listLocales.join(', ')}\};';
  classBuilder.writeln(gFile);
}

// _writeCsv(StringBuffer classBuilder, List<FileSystemEntity> files) async {
//   List<String> listLocales = List();
//   final fileData = File(files.first.path);

//   // CSVParser csvParser = CSVParser(await fileData.readAsString());

//   // List listLangs = csvParser.getLanguages();
//   for(String localeName in listLangs){
//     listLocales.add('"$localeName": $localeName');
//     String mapString = JsonEncoder.withIndent("  ").convert(csvParser.getLanguageMap(localeName)) ;

//     classBuilder.writeln(
//       '  static const Map<String,dynamic> $localeName = ${mapString};\n');
//   }

//   classBuilder.writeln(
//       '  static const Map<String, Map<String,dynamic>> mapLocales = \{${listLocales.join(', ')}\};');

// }

void printInfo(String info) {
  print('\u001b[32measy localization: $info\u001b[0m');
}

void printError(String error) {
  print('\u001b[31m[ERROR] easy localization: $error\u001b[0m');
}
