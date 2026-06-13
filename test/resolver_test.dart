// Pure Dart tests for resolver functions.
// No Flutter dependency — runs with `dart test`.
//
// Usage:
//   dart test test/resolver_test.dart

import 'package:easy_localization/src/resolver.dart';
import 'package:test/test.dart';

void main() {
  group('resolve()', () {
    final data = {
      'greeting': 'Hello',
      'name': 'World',
      'count': 42,
      'items': ['a', 'b'],
      'nested': {
        'deep': {
          'key': 'found it',
          'number': 99,
        },
      },
    };

    test('returns string for flat key', () {
      expect(resolve(data, 'greeting'), 'Hello');
    });

    test('returns null for non-existent flat key', () {
      expect(resolve(data, 'missing'), isNull);
    });

    test('returns null for non-string value (int)', () {
      expect(resolve(data, 'count'), isNull);
    });

    test('returns null for non-string value (list)', () {
      expect(resolve(data, 'items'), isNull);
    });

    test('resolves nested dotted key', () {
      expect(resolve(data, 'nested.deep.key'), 'found it');
    });

    test('returns null for nested path to non-string', () {
      expect(resolve(data, 'nested.deep.number'), isNull);
    });

    test('returns null for non-existent nested path', () {
      expect(resolve(data, 'nested.missing.key'), isNull);
    });

    test('returns null for non-existent deep path', () {
      expect(resolve(data, 'nested.deep.missing'), isNull);
    });

    test('handles empty data', () {
      expect(resolve(<String, dynamic>{}, 'key'), isNull);
    });

    test('uses cache for repeated nested lookups', () {
      final cache = <String, String>{};
      expect(resolve(data, 'nested.deep.key', cache), 'found it');
      expect(cache, containsPair('nested.deep.key', 'found it'));

      // Second call should use cache, not traversal
      expect(resolve(data, 'nested.deep.key', cache), 'found it');
    });
  });

  group('resolveNested()', () {
    test('traverses nested maps', () {
      final data = {
        'a': {
          'b': {
            'c': 'deep value',
          },
        },
      };
      expect(resolveNested(data, 'a.b.c'), 'deep value');
    });

    test('returns null when path hits non-map', () {
      final data = {
        'a': {
          'b': 'string_instead_of_map',
          'c': 'won\'t reach',
        },
      };
      expect(resolveNested(data, 'a.b.c'), isNull);
    });

    test('returns null when intermediate key missing', () {
      final data = {
        'a': {'b': 'value'}
      };
      expect(resolveNested(data, 'a.x.c'), isNull);
    });

    test('returns null for empty path segments', () {
      expect(resolveNested({'key': 'value'}, ''), isNull);
    });
  });

  group('resolveWithFallback()', () {
    final primary = {
      'greeting': 'Hello',
      'name': 'Alice',
    };
    final fallback = {
      'greeting': 'Bonjour',
      'title': 'My App',
      'welcome': 'Welcome',
    };

    test('returns primary value when key exists in primary', () {
      expect(
        resolveWithFallback(primary, fallback, 'greeting'),
        'Hello',
      );
    });

    test('returns fallback value when key missing from primary', () {
      expect(
        resolveWithFallback(primary, fallback, 'title'),
        'My App',
      );
    });

    test('returns null when key missing from both', () {
      expect(
        resolveWithFallback(primary, fallback, 'missing'),
        isNull,
      );
    });

    test('returns null when primary is null and key missing from fallback', () {
      expect(
        resolveWithFallback(null, fallback, 'missing'),
        isNull,
      );
    });

    test('returns null when fallback is null and key missing from primary', () {
      expect(
        resolveWithFallback(primary, null, 'missing'),
        isNull,
      );
    });

    test('returns null when both are null', () {
      expect(resolveWithFallback(null, null, 'key'), isNull);
    });

    test('returns fallback when primary is null', () {
      expect(
        resolveWithFallback(null, fallback, 'title'),
        'My App',
      );
    });
  });

  group('replaceArgs()', () {
    test('replaces positional args in order', () {
      expect(
        replaceArgs('Hello, {}!', ['World']),
        'Hello, World!',
      );
    });

    test('replaces multiple positional args', () {
      expect(
        replaceArgs('{} {} {}', ['a', 'b', 'c']),
        'a b c',
      );
    });

    test('returns original string when args is null', () {
      expect(replaceArgs('hello', null), 'hello');
    });

    test('returns original string when args is empty', () {
      expect(replaceArgs('hello', []), 'hello');
    });

    test('leaves extra {} when more placeholders than args', () {
      expect(
        replaceArgs('{} {} {}', ['a']),
        'a {} {}',
      );
    });
  });

  group('replaceNamedArgs()', () {
    test('replaces named placeholders', () {
      expect(
        replaceNamedArgs('Hello, {name}!', {'name': 'Alice'}),
        'Hello, Alice!',
      );
    });

    test('replaces multiple named placeholders', () {
      expect(
        replaceNamedArgs(
          '{name} — {email} — joined {date}',
          {'name': 'Bob', 'email': 'b@x.com', 'date': '2024'},
        ),
        'Bob — b@x.com — joined 2024',
      );
    });

    test('leaves unknown placeholders unchanged', () {
      expect(
        replaceNamedArgs('Hello {name}!', {'other': 'World'}),
        'Hello {name}!',
      );
    });

    test('returns original string when args is null', () {
      expect(replaceNamedArgs('hello', null), 'hello');
    });

    test('returns original string when args is empty', () {
      expect(replaceNamedArgs('hello', {}), 'hello');
    });
  });

  group('keyExists()', () {
    test('returns true when key exists in primary', () {
      expect(keyExists({'a': '1'}, null, 'a'), isTrue);
    });

    test('returns true when key exists in fallback', () {
      expect(keyExists(null, {'a': '1'}, 'a'), isTrue);
    });

    test('returns false when key missing from both', () {
      expect(keyExists({'a': '1'}, {'b': '2'}, 'c'), isFalse);
    });

    test('returns false when both are null', () {
      expect(keyExists(null, null, 'key'), isFalse);
    });

    test('returns true for nested key', () {
      expect(
        keyExists({
          'nested': {'key': 'val'}
        }, null, 'nested.key'),
        isTrue,
      );
    });

    test('returns false for non-existent nested key', () {
      expect(
        keyExists({
          'nested': {'key': 'val'}
        }, null, 'nested.missing'),
        isFalse,
      );
    });
  });

  group('resolveLinks()', () {
    final data = <String, dynamic>{
      'greeting': 'Hello',
      'name': 'World',
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
    };

    String? resolveKey(String key) => resolve(data, key);

    test('passes through string without @', () {
      expect(
        resolveLinks('plain text', resolveKey: resolveKey),
        'plain text',
      );
    });

    test('resolves simple link', () {
      expect(
        resolveLinks('@:greeting', resolveKey: resolveKey),
        'Hello',
      );
    });

    test('resolves link in sentence', () {
      expect(
        resolveLinks('Go to @:home page', resolveKey: resolveKey),
        'Go to Home page',
      );
    });

    test('applies upper modifier', () {
      expect(
        resolveLinks('@.upper:home', resolveKey: resolveKey),
        'HOME',
      );
    });

    test('applies lower modifier', () {
      expect(
        resolveLinks('@.lower:greeting', resolveKey: resolveKey),
        'hello',
      );
    });

    test('applies capitalize modifier', () {
      expect(
        resolveLinks('@.capitalize:greeting', resolveKey: resolveKey),
        'Hello',
      );
    });

    test('resolves multiple links', () {
      expect(
        resolveLinks('@:home @:profile @:settings', resolveKey: resolveKey),
        'Home Profile Settings',
      );
    });

    test('keeps unresolved link when key missing', () {
      expect(
        resolveLinks('@:missing_key', resolveKey: (_) => null),
        '@:missing_key',
      );
    });

    test('calls onWarning for unknown modifier', () {
      final warnings = <String>[];
      resolveLinks('@.xyz:greeting',
          resolveKey: resolveKey, onWarning: (w) => warnings.add(w));
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('Undefined modifier xyz'));
    });

    test('does not call onWarning when modifier exists', () {
      final warnings = <String>[];
      resolveLinks('@.upper:greeting',
          resolveKey: resolveKey, onWarning: (w) => warnings.add(w));
      expect(warnings, isEmpty);
    });

    test('empty string returns empty string', () {
      expect(resolveLinks('', resolveKey: resolveKey), '');
    });

    test('string with @ alone returns itself', () {
      expect(resolveLinks('@', resolveKey: resolveKey), '@');
      expect(resolveLinks('@@', resolveKey: resolveKey), '@@');
    });
  });
}
