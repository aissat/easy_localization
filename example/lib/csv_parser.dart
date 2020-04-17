import 'package:csv/csv.dart';

class CSVParser {
  final String fieldDelimiter;
  final String strings;
  final List<List<dynamic>> lines;

  CSVParser(this.strings, {this.fieldDelimiter = ','})
      : lines = CsvToListConverter()
            .convert(strings, fieldDelimiter: fieldDelimiter);

  List getLanguages() {
    return lines.first.sublist(1, lines.first.length);
  }

  Map<String, String> getLanguageMap(String localeName) {
    final indexLocale = lines.first.indexOf(localeName);

    final translations = {};
    for (var i = 1; i < lines.length; i++) {
      translations.addAll({lines[i][0]: lines[i][indexLocale]});
    }
    return translations;
  }
}
