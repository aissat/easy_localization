class Translations {
  final Map<String, dynamic>? _translations;
  final Map<String?, dynamic> _nestedKeysCache;

  Translations(this._translations) : _nestedKeysCache = {};
  String? get(String key) {
    String? returnValue;

    /// Try to look it up as a nested key
    if (isNestedKey(key)) {
      returnValue = getNested(key);
    }

    /// If we failed to find the key as a nested key, then fall back
    /// to looking it up like normal.
    returnValue ??= _translations?[key];

    return returnValue;
  }

  String? getNested(String key) {
    if (isNestedCached(key)) return _nestedKeysCache[key];

    final keys = key.split('.');
    final kHead = keys.first;

    var value = _translations![kHead];

    // print(value);

    for (var i = 1; i < keys.length; i++) {
      if (value is Map<String, dynamic>) value = value[keys[i]];
    }

    /// If we found the value, cache it. If the value is null then
    /// we're not going to cache it, and returning null instead.
    if (value != null) {
      cacheNestedKey(key, value);
    }

    return value;
  }

  // bool has(String key) => isNestedKey(key)
  //     ? getNested(key) != null
  //     : _translations.containsKey(key);

  bool isNestedCached(String key) => _nestedKeysCache.containsKey(key);

  void cacheNestedKey(String key, String value) {
    if (!isNestedKey(key)) {
      throw Exception('Cannot cache a key that is not nested.');
    }

    _nestedKeysCache[key] = value;
  }

  bool isNestedKey(String key) =>
      !_translations!.containsKey(key) && key.contains('.');
}
