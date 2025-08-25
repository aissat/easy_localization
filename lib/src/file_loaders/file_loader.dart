/// Abstract file loader interface to allow different implementations
/// for Flutter runtime (using rootBundle) and CLI (using dart:io)
abstract class FileLoader {
  Future<String> loadString(String path);
}
