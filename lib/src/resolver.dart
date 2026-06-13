/// Pure resolver functions for easy_localization.
///
/// Data-Oriented Programming approach: translation data is just
/// `Map<String, dynamic>`, and resolution is done by pure functions.
/// No state, no side effects, no class instances needed.
///
/// These functions are the core of the library's translation resolution
/// and can be tested with plain `dart test` (no Flutter dependency).

// ── Regex (compiled once at library level) ──────────────────────────────────

final _namedArgRegex = RegExp(r'\{(\w+)\}');
final _positionalArgRegex = RegExp(r'\{\}');
final _linkMatcher =
    RegExp(r'(?:@(?:\.[a-z]+)?:(?:[\w\-_|.]+|\([\w\-_|.]+\)))');
final _linkPrefixMatcher = RegExp(r'^@(?:\.([a-z]+))?:');
final _bracketsMatcher = RegExp('[()]');

// ── Default modifiers ──────────────────────────────────────────────────────

const _modifiers = <String, String Function(String)>{
  'upper': _upper,
  'lower': _lower,
  'capitalize': _capitalize,
};

String _upper(String val) => val.toUpperCase();
String _lower(String val) => val.toLowerCase();
String _capitalize(String val) => '${val[0].toUpperCase()}${val.substring(1)}';

// ── Public API ─────────────────────────────────────────────────────────────

/// Resolve a translation key from [data].
///
/// Supports both flat keys (`"greeting"`) and dotted nested keys
/// (`"nav.home.title"`). An optional [cache] can be provided to
/// speed up repeated nested key lookups.
///
/// Returns the string value, or `null` if the key is not found or
/// the resolved value is not a string (e.g., a nested map).
String? resolve(Map<String, dynamic> data, String key,
    [Map<String, String>? cache]) {
  if (!key.contains('.')) {
    final value = data[key];
    return value is String ? value : null;
  }

  if (data.containsKey(key)) {
    final value = data[key];
    return value is String ? value : null;
  }

  return resolveNested(data, key, cache);
}

/// Resolve a dotted nested key like `"nav.home.title"` by traversing
/// the map hierarchy.
///
/// An optional [cache] stores successfully resolved keys so subsequent
/// lookups of the same key bypass the traversal.
String? resolveNested(Map<String, dynamic> data, String key,
    [Map<String, String>? cache]) {
  if (cache != null && cache.containsKey(key)) return cache[key];

  final keys = key.split('.');
  Object? value = data[keys.first];

  for (var i = 1; i < keys.length; i++) {
    if (value is Map<String, dynamic>) {
      value = value[keys[i]];
    } else {
      return null;
    }
  }

  if (value is String) {
    cache?[key] = value;
    return value;
  }

  return null;
}

/// Resolve a key from [primary] with optional [fallback].
///
/// The [cache] is shared across primary and fallback lookups to avoid
/// redundant traversal. Returns the value as `String?`, where `null`
/// means the key was not found in either source.
String? resolveWithFallback(
  Map<String, dynamic>? primary,
  Map<String, dynamic>? fallback,
  String key, [
  Map<String, String>? cache,
]) {
  if (primary != null) {
    final result = resolve(primary, key, cache);
    if (result != null) return result;
  }
  if (fallback != null) {
    return resolve(fallback, key, cache);
  }
  return null;
}

/// Callback type for resolving a link target key inside [resolveLinks].
typedef LinkKeyResolver = String? Function(String key);

/// Resolve `@:key`, `@.modifier:key`, and `@:(key)` link references
/// in [value].
///
/// [resolveKey] is called for each link target to get its translated value.
/// Use [modifiers] to provide custom string transforms for `@.modifier:key`
/// syntax. Unknown modifiers are silently ignored (the link is still resolved,
/// but without transformation).
/// Use [onWarning] to capture diagnostics for unknown modifiers.
///
/// Returns the string with all links resolved. Links whose target resolves
/// to `null` are left in place.
///
/// Example:
/// ```dart
/// resolveLinks('@:greeting', resolveKey: (k) => data[k] as String?)
/// // → "Hello"
/// ```
String resolveLinks(
  String value, {
  required LinkKeyResolver resolveKey,
  Map<String, String Function(String)> modifiers = _modifiers,
  void Function(String warning)? onWarning,
}) {
  if (!value.contains('@')) return value;

  final matches = _linkMatcher.allMatches(value).toList();
  if (matches.isEmpty) return value;

  final buffer = StringBuffer();
  var lastEnd = 0;

  for (final match in matches) {
    buffer.write(value.substring(lastEnd, match.start));

    final link = match[0]!;
    final prefixMatches = _linkPrefixMatcher.allMatches(link);
    final prefix = prefixMatches.first[0]!;
    final modifierName = prefixMatches.first[1];

    final linkPlaceholder =
        link.replaceAll(prefix, '').replaceAll(_bracketsMatcher, '');

    final resolved = resolveKey(linkPlaceholder);
    var translated = resolved ?? '';

    if (modifierName != null && translated.isNotEmpty) {
      final modifier = modifiers[modifierName];
      if (modifier != null) {
        translated = modifier(translated);
      } else {
        onWarning?.call('Undefined modifier $modifierName');
      }
    }

    buffer.write(translated.isEmpty ? link : translated);
    lastEnd = match.end;
  }

  buffer.write(value.substring(lastEnd));
  return buffer.toString();
}

/// Replace positional argument placeholders (`{}`) in [value] with
/// the strings from [args], in order.
///
/// Uses a single regex pass (`replaceAllMapped`) instead of N
/// individual `replaceFirst` calls.
String replaceArgs(String value, List<String>? args) {
  if (args == null || args.isEmpty) return value;
  var i = 0;
  return value.replaceAllMapped(_positionalArgRegex, (_) {
    if (i >= args.length) return '{}';
    return args[i++];
  });
}

/// Replace named argument placeholders (`{name}`, `{field}`, etc.)
/// in [value] with the corresponding entries from [args].
///
/// Uses a single regex pass (`replaceAllMapped`) instead of N
/// individual `replaceAll` calls. Unknown placeholders are left
/// unchanged.
String replaceNamedArgs(String value, Map<String, String>? args) {
  if (args == null || args.isEmpty) return value;
  return value.replaceAllMapped(_namedArgRegex, (m) {
    return args[m[1]!] ?? m[0]!;
  });
}

/// Check if a key exists in [primary] or [fallback] translations.
bool keyExists(
  Map<String, dynamic>? primary,
  Map<String, dynamic>? fallback,
  String key,
) {
  if (primary != null && resolve(primary, key) != null) return true;
  if (fallback != null && resolve(fallback, key) != null) return true;
  return false;
}
