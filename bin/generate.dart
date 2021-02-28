import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:intl/intl.dart';
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
  print(parser.usage);
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

  parser.addFlag('separated-keys',
      defaultsTo: true,
      callback: (bool? x) => generateOptions!.separatedKeys = x,
      help: 'Load separated files');

  return parser;
}

class GenerateOptions {
  String? sourceDir;
  String? sourceFile;
  String? templateLocale;
  String? outputDir;
  String? outputFile;
  String? format;
  bool? separatedKeys;

  @override
  String toString() {
    return 'format: $format sourceDir: $sourceDir sourceFile: $sourceFile outputDir: $outputDir outputFile: $outputFile separatedKeys: $separatedKeys';
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
      await _writeJson(classBuilder, files, options);
      break;
    case 'keys':
      await _writeKeys(classBuilder, files, options);
      break;
    default:
      printError('Format not support');
  }

  classBuilder.writeln('}');
  generatedFile.writeAsStringSync(classBuilder.toString());

  printInfo('All done! File generated in ${outputPath.path}');
}

final RegExp regExpParentheses = RegExp(r'\(([^\)]+)\)', multiLine: false);

Future<Map<String, dynamic>?> loadData(String path) async {
  final fileData = File(path);

  return json.decode(await fileData.readAsString());
}

Future<Map<String, dynamic>?> loadSeparatedData(
    Map<String, dynamic>? loadedData) async {
  //check locales tree on separated file
  Future<MapEntry<String, dynamic>> _checkAndLoad(
      String key, dynamic value) async {
    if (value is String) {
      if (value.startsWith('@file')) {
        var math = regExpParentheses.firstMatch(value)?.group(1);
        if (math != null) {
          var fileData = await loadData(math);
          // check again loaded data to separated data
          fileData = await loadSeparatedData(fileData);
          printInfo('Separated key $key loaded from $math');
          return MapEntry(key, fileData);
        }
      }
    } else if (value is Map<String, dynamic>) {
      var fileData = await loadSeparatedData(value);
      return MapEntry(key, fileData);
    }
    return MapEntry(key, value);
  }

  var newEntries = <MapEntry<String, dynamic>>[];
  var newMap = <String, dynamic>{};
  for (var entry in loadedData!.entries) {
    newEntries.add(await _checkAndLoad(entry.key, entry.value));
  }
  newMap.addEntries(newEntries);
  return newMap;
}

Future _writeKeys(StringBuffer classBuilder, List<FileSystemEntity> files,
    GenerateOptions options) async {
  var file = '''
// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

abstract class  LocaleKeys {
''';

  var data = await loadData(files.first.path);
  if (options.separatedKeys == true) {
    data = await loadSeparatedData(data);
  }

  file += _resolve(data);

  classBuilder.writeln(file);
}

String _resolve(Map<String, dynamic>? translations, [String? accKey]) {
  if (translations == null) {
    return '';
  }
  var fileContent = '';

  final sortedKeys = translations.keys.toList();

  for (var key in sortedKeys) {
    if (translations[key] is Map) {
      var nextAccKey = key;
      if (accKey != null) {
        nextAccKey = '$accKey.$key';
      }

      fileContent += _resolve(translations[key], nextAccKey);
    }

    if (!_preservedKeywords.contains(key)) {
      accKey != null
          ? fileContent +=
              '  static const ${accKey.replaceAll('.', '_')}\_$key = \'$accKey.$key\';\n'
          : fileContent += '  static const $key = \'$key\';\n';
    }
  }

  return fileContent;
}

Future _writeJson(StringBuffer classBuilder, List<FileSystemEntity> files,
    GenerateOptions options) async {
  var gFile = '''
// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader implements AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String fullPath, Locale locale ) {
    return Future.value(mapLocales[locale.toString()]);
  }

  @override
  Future<Map<String, dynamic>?> loadFromPath(String path) async {}

  ''';

  final listLocales = [];

  for (var file in files) {
    final localeName =
        path.basename(file.path).replaceFirst('.json', '').replaceAll('-', '_');

    var localeCheckExists = Intl.verifiedLocale(
        localeName, NumberFormat.localeExists,
        onFailure: (_) => null);

    if (localeCheckExists != null) {
      listLocales.add('"$localeName": $localeName');

      var data = await loadData(file.path);
      if (options.separatedKeys == true) {
        data = await loadSeparatedData(data);
      }

      final mapString = JsonEncoder.withIndent('  ').convert(data);
      gFile += 'static const Map<String,dynamic> $localeName = $mapString;\n';
    }
  }

  gFile +=
      'static const Map<String, Map<String,dynamic>> mapLocales = \{${listLocales.join(', ')}\};';
  classBuilder.writeln(gFile);
}

void printInfo(String info) {
  print('\u001b[32measy localization: $info\u001b[0m');
}

void printError(String error) {
  print('\u001b[31m[ERROR] easy localization: $error\u001b[0m');
}
