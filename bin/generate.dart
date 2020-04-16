import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

main(List<String> args) async {
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
  GenerateOptions generateOptions = GenerateOptions();
  var parser = _generateArgParser(generateOptions);
  parser.parse(args);
  return generateOptions;
}

ArgParser _generateArgParser(GenerateOptions generateOptions) {
  var parser = ArgParser();

  parser.addOption('source-dir',
      defaultsTo: 'resources/langs',
      callback: (String x) => generateOptions.sourceDir = x,
      help: 'Source folder contains all string json files');

  parser.addOption('output-dir',
      defaultsTo: 'lib/generated',
      callback: (String x) => generateOptions.outputDir = x,
      help: 'Output folder stores all generated files');

  return parser;
}

class GenerateOptions {
  String sourceDir;
  String templateLocale;
  String outputDir;

  @override
  String toString() {
    return 'sourceDir: $sourceDir outputDir: $outputDir';
  }
}

void handleLangFiles(GenerateOptions options) async {
  final Directory current = Directory.current;
  final Directory source = Directory.fromUri(Uri.parse(options.sourceDir));
  final Directory output = Directory.fromUri(Uri.parse(options.outputDir));
  final Directory sourcePath = Directory(path.join(current.path, source.path));
  final Directory outputPath = Directory(path.join(current.path, output.path, 'codegen_loager.g.dart'));

  if (!await sourcePath.exists()) {
    print('easy localization: Source path does not exist');
    return;
  }

  List<FileSystemEntity> files = await dirContents(sourcePath);
  //filtering only json
  files = files.where((f) => f.path.contains('.json')).toList();
  if (files.isNotEmpty){
    generateFile(files, outputPath);
  }else{
    print('easy localization: Source path empty');
  }
  //final Map<String, FileSystemEntity> validFilesMap = getValidStringFileMap(files);
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  List<FileSystemEntity> files = [];
  var completer = Completer<List<FileSystemEntity>>();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      // should also register onError
      onDone: () => completer.complete(files));
  return completer.future;
}

void generateFile(List<FileSystemEntity> files, Directory outputPath) async{

  File generatedFile = File(outputPath.path);
  if (!generatedFile.existsSync()) {
    generatedFile.createSync(recursive: true);
  }

  StringBuffer classBuilder = StringBuffer();

  classBuilder.writeln(
  '''// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart
import 'dart:ui';

import 'package:easy_localization/src/asset_loader.dart';

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {

    return Future.value(mapLocales[locale.toString()]);
  }

  ''');
  List<String> listLocales = List();
  for (FileSystemEntity file in files){
    String localeName = path.basename(file.path).replaceFirst('.json', '').replaceAll('-', '_');
    listLocales.add('"$localeName": $localeName');
    final fileData = File(file.path);

    Map<String, dynamic> data = json.decode(await fileData.readAsString());

    String mapString = JsonEncoder.withIndent("    ").convert(data);
    
    classBuilder.writeln('  static const Map<String,dynamic> $localeName = ${mapString};');
  }
  classBuilder.writeln('  static const Map<String, Map<String,dynamic>> mapLocales = \{${listLocales.join(' , ')}\};');
  classBuilder.writeln('}');
  generatedFile.writeAsStringSync(classBuilder.toString());
}


































/*
Map<String, FileSystemEntity> getValidStringFileMap(files) {
  Map<String, FileSystemEntity> validMap;
  for (FileSystemEntity file in files) {

    String fileName = path.basename(file.path);
    String locale = fileName.replaceAll('.json', '');
    validMap[locale] = file;
  }

  return validMap;
}
*/

/*
void handleGenerateI18nFiles(I18nOption option) async {
  Directory current = Directory.current;

  var sourcePath = Directory(path.join(current.path, option.sourceDir));
  if (!await sourcePath.exists()) {
    print('Source path does not exist');
    return;
  }

  List<FileSystemEntity> files =
      await dirContents(Directory(path.join(current.path, option.sourceDir)));
  Map<String, FileSystemEntity> validFilesMap = getValidStringFileMap(files);
  FileSystemEntity defaultTemplateLang =
      getDefaultTemplateLang(validFilesMap, option.templateLocale);
  if (null != defaultTemplateLang) {
    Map<String, Message> defaultJsonKeyMessageMap =
        await generateJsonKeyMessageMap(File(defaultTemplateLang.path));
//    printInfo(defaultJsonKeyMessageMap.toString());
//    printInfo('outputDir: ${option.outputDir}');

    String defaultLang = path.basename(getLocale(defaultTemplateLang.path));

    // Generate messages_all.dart
    _handleGenerateMessageAllDart(
        path.join(current.path, option.outputDir, 'messages_all.dart'),
        defaultLang,
        defaultJsonKeyMessageMap,
        validFilesMap);

    // Generate i18n.dart
    _handleGenerateI18nDart(
        path.join(current.path, option.outputDir, 'i18n.dart'),
        defaultLang,
        defaultJsonKeyMessageMap,
        validFilesMap);

    printInfo('Finished to generate 2 files.');
  }
}*/