import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

const _preservedKeywords = [
  'few',
  'many',
  'one',
  'other',
  'two',
  'zero',
  'male',
  'female',
];

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
  stdout.writeln(parser.usage);
}

GenerateOptions _generateOption(List<String> args) {
  var generateOptions = GenerateOptions();
  var parser = _generateArgParser(generateOptions);
  parser.parse(args);
  return generateOptions;
}

ArgParser _generateArgParser(GenerateOptions? generateOptions) {
  var parser = ArgParser();

  parser.addOption('source-dir',
      abbr: 'S',
      defaultsTo: 'resources/langs',
      callback: (String? x) => generateOptions!.sourceDir = x,
      help: 'Folder containing localization files');

  parser.addOption('source-file',
      abbr: 's',
      callback: (String? x) => generateOptions!.sourceFile = x,
      help: 'File to use for localization');

  parser.addOption('output-dir',
      abbr: 'O',
      defaultsTo: 'lib/generated',
      callback: (String? x) => generateOptions!.outputDir = x,
      help: 'Output folder stores for the generated file');

  parser.addOption('output-file',
      abbr: 'o',
      defaultsTo: 'codegen_loader.g.dart',
      callback: (String? x) => generateOptions!.outputFile = x,
      help: 'Output file name');

  parser.addOption('format',
      abbr: 'f',
      defaultsTo: 'json',
      callback: (String? x) => generateOptions!.format = x,
      help: 'Support json or keys formats',
      allowed: ['json', 'keys']);

  parser.addFlag(
    'skip-unnecessary-keys',
    abbr: 'u',
    defaultsTo: false,
    callback: (bool? x) => generateOptions!.skipUnnecessaryKeys = x,
    help: 'If true - Skip unnecessary keys of nested objects.',
  );

  return parser;
}

class GenerateOptions {
  String? sourceDir;
  String? sourceFile;
  String? templateLocale;
  String? outputDir;
  String? outputFile;
  String? format;
  bool? skipUnnecessaryKeys;

  @override
  String toString() {
    return 'format: $format sourceDir: $sourceDir sourceFile: $sourceFile outputDir: $outputDir outputFile: $outputFile skipUnnecessaryKeys: $skipUnnecessaryKeys';
  }
}

void handleLangFiles(GenerateOptions options) async {
  final current = Directory.current;
  final source = Directory.fromUri(Uri.parse(options.sourceDir!));
  final output = Directory.fromUri(Uri.parse(options.outputDir!));
  final sourcePath = Directory(path.join(current.path, source.path));
  final outputPath =
      Directory(path.join(current.path, output.path, options.outputFile));

  if (!await sourcePath.exists()) {
    printError('Source path does not exist');
    return;
  }

  var files = await dirContents(sourcePath);
  if (options.sourceFile != null) {
    final sourceFile = File(path.join(source.path, options.sourceFile));
    if (!await sourceFile.exists()) {
      printError('Source file does not exist (${sourceFile.toString()})');
      return;
    }
    files = [sourceFile];
  } else {
    //filtering format
    files = files.where((f) => f.path.contains('.json')).toList();
  }

  if (files.isNotEmpty) {
    generateFile(files, outputPath, options);
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

void generateFile(List<FileSystemEntity> files, Directory outputPath,
    GenerateOptions options) async {
  var generatedFile = File(outputPath.path);
  if (!generatedFile.existsSync()) {
    generatedFile.createSync(recursive: true);
  }

  var classBuilder = StringBuffer();

  switch (options.format) {
    case 'json':
      await _writeJson(classBuilder, files);
      break;
    case 'keys':
      await _writeKeys(classBuilder, files, options.skipUnnecessaryKeys);
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

Future _writeKeys(StringBuffer classBuilder, List<FileSystemEntity> files,
    bool? skipUnnecessaryKeys) async {
  var file = '''
// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

abstract class  LocaleKeys {
''';

  final fileData = File(files.first.path);

  Map<String, dynamic> translations =
      json.decode(await fileData.readAsString());

  file += _resolve(translations, skipUnnecessaryKeys);

  classBuilder.writeln(file);
}

String _resolve(Map<String, dynamic> translations, bool? skipUnnecessaryKeys,
    [String? accKey]) {
  var fileContent = '';

  final sortedKeys = translations.keys.toList();

  final canIgnoreKeys = skipUnnecessaryKeys == true && accKey != null;

  bool containsPreservedKeywords(Map<String, dynamic> map) =>
      map.keys.any((element) => _preservedKeywords.contains(element));

  for (var key in sortedKeys) {
    var ignoreKey = canIgnoreKeys;

    if (translations[key] is Map) {
      ignoreKey &=
          !containsPreservedKeywords(translations[key] as Map<String, dynamic>);

      var nextAccKey = (accKey == null ? key : '$accKey.$key');

      fileContent +=
          _resolve(translations[key], skipUnnecessaryKeys, nextAccKey);
    } else {
      ignoreKey &= !_preservedKeywords.contains(key);
    }

    //ignoreKey = skipUnnecessaryKeys (by default is false, true only when "--skip-unnecessary-keys" or "-u")
    //            AND accKey != null (true when the key is nested)
    //            AND key is not a preserved keyword (_preservedKeywords)

    // If "--skip-unnecessary-keys" -> ignore every nestested key that is not inside _preservedKeywords
    if (!ignoreKey) {
      accKey != null
          ? fileContent +=
              '  static const ${accKey.replaceAll('.', '_')}_$key = \'$accKey.$key\';\n'
          : fileContent += '  static const $key = \'$key\';\n';
    }
  }

  return fileContent;
}

Future _writeJson(
    StringBuffer classBuilder, List<FileSystemEntity> files) async {
  var gFile = '''
// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

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

    Map<String, dynamic>? data = json.decode(await fileData.readAsString());

    final mapString = const JsonEncoder.withIndent('  ').convert(data);
    gFile += 'static const Map<String,dynamic> $localeName = $mapString;\n';
  }

  gFile +=
      'static const Map<String, Map<String,dynamic>> mapLocales = {${listLocales.join(', ')}};';
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
  stdout.writeln('\u001b[32measy localization: $info\u001b[0m');
}

void printError(String error) {
  stderr.writeln('\u001b[31m[ERROR] easy localization: $error\u001b[0m');
}
