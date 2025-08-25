import 'dart:convert';

import 'package:easy_localization/src/file_loaders/file_loader.dart';

/// Resolves linked translation files by loading referenced files and merging them
/// into the base JSON structure. Handles the ':/filename.json' syntax used in linked files.

abstract class LinkedFileResolver {
  final int maxLinkedDepth = 32;
  final FileLoader fileLoader;

  const LinkedFileResolver({required this.fileLoader});

  Future<Map<String, dynamic>> resolveLinkedFiles({
    required String basePath,
    required String languageCode,
    required Map<String, dynamic> baseJson,
    Set<String>? visited,
    int depth = 0,
    String? countryCode,
  });

  String getLinkedLocalePath(String basePath, String filePath, String languageCode, {String? countryCode}) {
    if (countryCode != null) {
      return '$basePath/$languageCode-$countryCode/$filePath';
    }

    return '$basePath/$languageCode/$filePath';
  }
}

class JsonLinkedFileResolver extends LinkedFileResolver {
  const JsonLinkedFileResolver({required FileLoader fileLoader}) : super(fileLoader: fileLoader);

  @override
  Future<Map<String, dynamic>> resolveLinkedFiles({
    required String basePath,
    required String languageCode,
    required Map<String, dynamic> baseJson,
    Set<String>? visited,
    int depth = 0,
    String? countryCode,
  }) async {
    visited ??= <String>{};

    if (depth > maxLinkedDepth) {
      throw StateError('Maximum linked files depth ($maxLinkedDepth) exceeded for $languageCode at $basePath.');
    }

    final Map<String, dynamic> fullJson = Map<String, dynamic>.from(baseJson);

    for (final entry in baseJson.entries) {
      final key = entry.key;
      var value = entry.value;

      if (value is String && value.startsWith(':/')) {
        final rawPath = value.substring(2).trim();
        final linkedAssetPath = getLinkedLocalePath(basePath, rawPath, languageCode, countryCode: countryCode);

        if (visited.contains(linkedAssetPath)) {
          throw StateError('Cyclic linked files detected at "$linkedAssetPath" (key: "$key").');
        }

        try {
          final linkedContent = await fileLoader.loadString(linkedAssetPath);
          final Map<String, dynamic> linkedJson = json.decode(linkedContent) as Map<String, dynamic>;

          visited.add(linkedAssetPath);

          final resolved = await resolveLinkedFiles(
            basePath: basePath,
            languageCode: languageCode,
            baseJson: linkedJson,
            visited: visited,
            depth: depth + 1,
            countryCode: countryCode,
          );
          fullJson[key] = resolved;
        } catch (e) {
          throw StateError(
            'Error resolving linked file "$linkedAssetPath" for key "$key": $e',
          );
        }
      } else if (value is Map<String, dynamic>) {
        fullJson[key] = await resolveLinkedFiles(
          basePath: basePath,
          languageCode: languageCode,
          baseJson: value,
          visited: visited,
          depth: depth + 1,
          countryCode: countryCode,
        );
      }
    }

    return fullJson;
  }
}
