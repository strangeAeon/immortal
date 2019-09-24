import 'package:optional/optional.dart';
import 'package:tuple/tuple.dart';

import '../immortal.dart';

/// An immutable collection of key/value pairs, from which you retrieve a value
/// using its associated key.
///
/// Operations on this map never modify the original instance but instead return
/// new instances created from mutable maps where the operations are applied to.
///
/// Internally a [LinkedHashMap] is used, regardless of what type of map is
/// passed to the constructor.
class ImmortalMap<K, V> {
  /// Creates an [ImmortalMap] instance that contains all key/value pairs of
  /// [map].
  ///
  /// The keys must all be instances of [K] and the values of [V].
  /// The [map] itself can have any type.
  ///
  /// It iterates over the entries of [map], which must therefore not change
  /// during the iteration.
  ///
  /// All keys are required to implement compatible `operator==` and `hashCode`.
  /// It is allowed although not advised to use `null` as a key and/or value.
  ImmortalMap([Map<K, V> map]) : _map = Map.from(map ?? <K, V>{});

  ImmortalMap._internal(this._map);

  /// Creates an empty [ImmortalMap].
  factory ImmortalMap.empty() => ImmortalMap<K, V>();

  /// Creates an [ImmortalMap] as copy of [other].
  ///
  /// See [ImmortalMap.of].
  factory ImmortalMap.from(ImmortalMap<K, V> other) => ImmortalMap.of(other);

  /// Creates an [ImmortalMap] instance that contains all [entries].
  ///
  /// The keys must all be instances of [K] and the values of [V].
  ///
  /// All keys are required to implement compatible `operator==` and `hashCode`.
  /// It is allowed although not advised to use `null` as a key and/or value.
  ///
  /// If multiple [entries] have the same key, later occurrences overwrite the
  /// earlier ones.
  factory ImmortalMap.fromEntries(ImmortalList<MapEntry<K, V>> entries) =>
      ImmortalMap.fromEntriesIterable(entries.toMutableList());

  /// Creates an [ImmortalMap] instance that contains all [entries].
  ///
  /// See [ImmortalMap.fromEntries].
  /// It iterates over [entries], which must therefore not change during the
  /// iteration.
  factory ImmortalMap.fromEntriesIterable(Iterable<MapEntry<K, V>> entries) =>
      ImmortalMap._internal(Map.fromEntries(entries));

  /// Creates an [ImmortalMap] by associating the given [keys] to [values].
  ///
  /// This constructor iterates over [keys] and [values] and maps each element
  /// of [keys] to the corresponding element of [values].
  ///
  /// If the two lists have different lengths, the iteration will stop at the
  /// length of the shorter one, so that there are always complete key/value
  /// pairs.
  ///
  /// If [keys] contains the same object multiple times, later occurrences
  /// overwrite the previous ones.
  ///
  /// All [keys] are required to implement compatible `operator==` and
  /// `hashCode`.
  /// It is allowed although not advised to use `null` as a key and/or value.
  factory ImmortalMap.fromLists(ImmortalList<K> keys, ImmortalList<V> values) =>
      ImmortalMap.fromIterables(
        keys.toMutableList(),
        values.toMutableList(),
      );

  /// Creates an [ImmortalMap] by associating the given [keys] to [values].
  ///
  /// See [ImmortalMap.fromLists].
  /// It iterates over [keys] and [values], which must therefore not change
  /// during the iteration.
  factory ImmortalMap.fromIterables(Iterable<K> keys, Iterable<V> values) =>
      ImmortalMap._internal(Map.fromIterables(
        keys.take(values.length),
        values.take(keys.length),
      ));

  /// Creates an [ImmortalMap] instance that contains all [pairs] as entries.
  ///
  /// The keys must all be instances of [K] and the values of [V].
  ///
  /// All keys are required to implement compatible `operator==` and `hashCode`.
  /// It is allowed although not advised to use `null` as a key and/or value.
  ///
  /// If multiple [pairs] have the same key, later occurrences overwrite the
  /// earlier ones.
  factory ImmortalMap.fromPairs(ImmortalList<Tuple2<K, V>> pairs) =>
      ImmortalMap.fromPairsIterable(pairs.toMutableList());

  /// Creates an [ImmortalMap] instance that contains all [pairs] as entries.
  ///
  /// See [ImmortalMap.fromPairs].
  /// It iterates over [pairs], which must therefore not change during the
  /// iteration.
  factory ImmortalMap.fromPairsIterable(Iterable<Tuple2<K, V>> pairs) =>
      ImmortalMap<K, V>().addPairsIterable(pairs);

  /// Creates an [ImmortalMap] containing all entries of [other].
  ///
  /// See [ImmortalMap.ofMutable].
  factory ImmortalMap.fromMutable(Map<K, V> other) => ImmortalMap(other);

  /// Creates an [ImmortalMap] as copy of [other].
  ///
  /// See [copy].
  factory ImmortalMap.of(ImmortalMap<K, V> other) => other.copy();

  /// Creates an [ImmortalMap] instance that contains all key/value pairs of
  /// [other].
  ///
  /// The keys must all be instances of [K] and the values of [V].
  /// The [other] itself can have any type.
  ///
  /// It iterates over the entries of [other], which must therefore not change
  /// during the iteration.
  ///
  /// All keys are required to implement compatible `operator==` and `hashCode`.
  /// It is allowed although not advised to use `null` as a key and/or value.
  factory ImmortalMap.ofMutable(Map<K, V> other) => ImmortalMap(other);

  /// Returns a copy of [other] casting all keys to instances of [K2] and all
  /// values to instances of [V2].
  ///
  /// See [cast].
  static ImmortalMap<K2, V2> castFrom<K, V, K2, V2>(ImmortalMap<K, V> other) =>
      other.cast<K2, V2>();

  /// Creates an [ImmortalMap] from [other] by casting all keys to instances of
  /// [K2] and all values to instances of [V2].
  ///
  /// If [other] contains only keys of type [K2] and values of type [V2], the
  /// map will be created correctly, otherwise an exception will be thrown.
  ///
  /// It iterates over the entries of [other], which must therefore not change
  /// during the iteration.
  static ImmortalMap<K2, V2> castFromMutable<K, V, K2, V2>(Map<K, V> other) =>
      ImmortalMap(other.cast<K2, V2>());

  /// Creates an [ImmortalMap] by computing the keys and values from [list].
  ///
  /// For each element of [list] this constructor computes a key/value pair by
  /// applying [keyGenerator] and [valueGenerator] respectively.
  /// If no values are specified for [keyGenerator] and [valueGenerator] the
  /// default is the identity function.
  ///
  /// The keys computed by the source [list] do not need to be unique. The last
  /// occurrence of a key will simply overwrite any previous value.
  ///
  /// All keys are required to implement compatible `operator==` and `hashCode`.
  /// It is allowed although not advised to use `null` as a key and/or value.
  static ImmortalMap<K, V> fromList<T, K, V>(
    ImmortalList<T> list, {
    K Function(T value) keyGenerator,
    V Function(T value) valueGenerator,
  }) =>
      ImmortalMap.fromIterable(
        list.toMutableList(),
        keyGenerator: keyGenerator,
        valueGenerator: valueGenerator,
      );

  /// Creates an [ImmortalMap] by computing the keys and values from [iterable].
  ///
  /// See [ImmortalMap.fromList].
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  static ImmortalMap<K, V> fromIterable<T, K, V>(
    Iterable<T> iterable, {
    K Function(T value) keyGenerator,
    V Function(T value) valueGenerator,
  }) =>
      ImmortalMap._internal(Map.fromIterable(
        iterable,
        key: keyGenerator,
        value: valueGenerator,
      ));

  final Map<K, V> _map;

  /// Returns a copy of this map where all key/value pairs of [other] are added.
  ///
  /// See [addAll].
  ImmortalMap<K, V> operator +(ImmortalMap<K, V> other) => addAll(other);

  /// Returns an [Optional] containing the value for the given [key] or
  /// [Optional.empty] if [key] is not in the map.
  ///
  /// See [lookup].
  Optional<V> operator [](Object key) => lookup(key);

  /// Returns a copy of this map where the value of [key] is set to [value].
  ///
  /// Overwrites the previous value in the copied map if [key] was already
  /// present, otherwise a new key/value pair is added.
  ImmortalMap<K, V> add(K key, V value) => addEntry(MapEntry(key, value));

  /// Returns a copy of this map where all key/value pairs of [other] are added.
  ///
  /// If a key of [other] is already in this map, its value is overwritten in
  /// the copy.
  ///
  /// If [other] is empty, the map is returned unchanged.
  ImmortalMap<K, V> addAll(ImmortalMap<K, V> other) =>
      addMap(other.toMutableMap());

  /// Returns a copy of this map where all key/value pairs of [entries] are
  /// added.
  ///
  /// If a key of [entries] is already present in the copy, the corresponding
  /// value is overwritten.
  ///
  /// If [entries] is empty, the map is returned unchanged.
  ImmortalMap<K, V> addEntries(ImmortalList<MapEntry<K, V>> entries) =>
      addEntriesIterable(entries.toMutableList());

  /// Returns a copy of this map where all key/value pairs of the iterable
  /// [entries] are added.
  ///
  /// See [addEntries].
  /// It iterates over [entries], which must therefore not change during the
  /// iteration.
  ImmortalMap<K, V> addEntriesIterable(Iterable<MapEntry<K, V>> entries) {
    if (entries.isEmpty) {
      return this;
    }
    return ImmortalMap._internal(toMutableMap()..addEntries(entries));
  }

  /// Returns a copy of this map where the key/value pair [entry] is added.
  ///
  /// If the key of [entry] is already present in the copy, the corresponding
  /// value is overwritten.
  ImmortalMap<K, V> addEntry(MapEntry<K, V> entry) =>
      addEntriesIterable([entry]);

  /// Returns a copy of this map where the key/value pair [entry] is added if no
  /// entry for [entry.key] is already present.
  ///
  /// Otherwise the map is returned unchanged.
  ImmortalMap<K, V> addEntryIfAbsent(MapEntry<K, V> entry) =>
      lookup(entry.key).map((_) => this).orElse(addEntry(entry));

  /// Returns a copy of this map setting the value of [key] if it isn't there.
  ///
  /// See [putIfAbsent].
  ImmortalMap<K, V> addIfAbsent(K key, V Function() ifAbsent) =>
      putIfAbsent(key, ifAbsent);

  /// Returns a copy of this map where all key/value pairs of [other] are added.
  ///
  /// See [addAll].
  /// It iterates over [other], which must therefore not change during the
  /// iteration.
  ImmortalMap<K, V> addMap(Map<K, V> other) {
    if (other.isEmpty) {
      return this;
    }
    return ImmortalMap._internal(toMutableMap()..addAll(other));
  }

  /// Returns a copy of this map where the elements of [pair] are added as a new
  /// map entry.
  ///
  /// The first element will be used as key and the second one as value.
  /// If the key is already present in the copy, the corresponding value is
  /// overwritten.
  ImmortalMap<K, V> addPair(Tuple2<K, V> pair) =>
      addEntry(MapEntry(pair.item1, pair.item2));

  /// Returns a copy of this map where all elements of [pairs] are added as new
  /// map entries.
  ///
  /// The first element of each pair is used as key and the second one as value.
  /// If a key is already present in the copy, the corresponding value is
  /// overwritten.
  ///
  /// If [pairs] is empty, the map is returned unchanged.
  ImmortalMap<K, V> addPairs(ImmortalList<Tuple2<K, V>> pairs) =>
      addPairsIterable(pairs.toMutableList());

  /// Returns a copy of this map where all elements of [pairs] are added as new
  /// map entries.
  ///
  /// See [addPairs].
  /// It iterates over [pairs], which must therefore not change during the
  /// iteration.
  ImmortalMap<K, V> addPairsIterable(Iterable<Tuple2<K, V>> pairs) =>
      addEntriesIterable(pairs.map(
        (pair) => MapEntry(pair.item1, pair.item2),
      ));

  /// Returns a copy of this map casting all keys to instances of [K2] and all
  /// values to instances of [V2].
  ///
  /// If this map contains only keys of type [K2] and values of type [V2], the
  /// copy will be created correctly, otherwise an exception will be thrown.
  ImmortalMap<K2, V2> cast<K2, V2>() => ImmortalMap(_map.cast<K2, V2>());

  /// Returns `true` if this map contains the given [key].
  ///
  /// Returns `true` if any of the keys in the map are equal to [key] according
  /// to the `==` operator.
  bool containsKey(Object key) => _map.containsKey(key);

  /// Returns `true` if this map contains the given [value].
  ///
  /// Returns `true` if any of the values in the map are equal to [value]
  /// according to the `==` operator.
  bool containsValue(Object value) => _map.containsValue(value);

  /// Returns a copy of this map.
  ImmortalMap<K, V> copy() => ImmortalMap(_map);

  /// Returns an [ImmortalList] containing the entries of this map.
  ImmortalList<MapEntry<K, V>> get entries => ImmortalList(_map.entries);

  /// Checks whether this map is equal to [other].
  ///
  /// First an identity check is performed, using [ImmortalMap.==]. If this
  /// fails, it is checked if [other] is an [ImmortalMap] and all contained
  /// entries of the two maps are compared using the `==` operators for keys
  /// and values.
  ///
  /// To solely test if two maps are identical, the operator `==` can be used.
  bool equals(dynamic other) =>
      this == other ||
      other is ImmortalMap<K, V> &&
          length == other.length &&
          mapEntries(
            (key, value) => other[key]
                .map((otherValue) => otherValue == value)
                .orElse(false),
          ).every((result) => result);

  /// Returns a copy of this map containing all entries that satisfy the given
  /// [predicate].
  ///
  /// See [where].
  ImmortalMap<K, V> filter(bool Function(K key, V value) predicate) =>
      where(predicate);

  /// Returns a copy of this map containing all entries with keys that satisfy
  /// the given [predicate].
  ///
  /// See [whereKey].
  ImmortalMap<K, V> filterKeys(bool Function(K key) predicate) =>
      whereKey(predicate);

  /// Returns a copy of this map containing all entries with values that satisfy
  /// the given [predicate].
  ///
  /// See [whereValue].
  ImmortalMap<K, V> filterValues(bool Function(V value) predicate) =>
      whereValue(predicate);

  /// Applies [f] to each key/value pair of the map.
  void forEach(void Function(K key, V value) f) => _map.forEach(f);

  /// Returns an [Optional] containing the value for the given [key] or
  /// [Optional.empty] if [key] is not in the map.
  ///
  /// See [lookup].
  Optional<V> get(K key) => lookup(key);

  /// Returns an immortal list of all keys with a value equal to the given
  /// [value] according to the `==` operator.
  ///
  /// See [lookupKeysForValue].
  ImmortalList<K> getKeysForValue(V value) => lookupKeysForValue(value);

  /// Returns `true` if there is no key/value pair in the map.
  bool get isEmpty => _map.isEmpty;

  /// Returns `true` if there is at least one key/value pair in the map.
  bool get isNotEmpty => _map.isNotEmpty;

  /// Returns an [ImmortalList] containing the keys of this map.
  ImmortalList<K> get keys => ImmortalList(_map.keys);

  /// Returns an immortal list of all keys with a value equal to the given
  /// [value] according to the `==` operator.
  ///
  /// See [lookupKeysForValue].
  ImmortalList<K> keysForValue(V value) => lookupKeysForValue(value);

  /// The number of key/value pairs in the map.
  int get length => _map.length;

  /// Returns an [Optional] containing the value for the given [key] or
  /// [Optional.empty] if [key] is not in the map.
  ///
  /// This lookup can not distinguish between a key not being in the map and the
  /// key having a `null` value.
  /// Methods like [containsKey] or [addIfAbsent] can be used if the distinction
  /// is important.
  Optional<V> lookup(K key) => Optional.ofNullable(_map[key]);

  /// Returns an immortal list of all keys with a value equal to the given
  /// [lookupValue] according to the `==` operator.
  ImmortalList<K> lookupKeysForValue(V lookupValue) =>
      where((_, value) => value == lookupValue).keys;

  /// Returns a new map where all entries of this map are transformed by the
  /// given [f] function.
  ///
  /// If multiple entries have the same key after transformation, later
  /// occurences overwrite the earlier ones.
  ImmortalMap<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(K key, V value) f,
  ) =>
      ImmortalMap._internal(_map.map(f));

  /// Returns an [ImmortalList] with elements that are created by calling [f]
  /// on each entry in the map.
  ///
  /// If multiple entries have the same key after transformation, later
  /// occurences overwrite the earlier ones.
  ImmortalList<R> mapEntries<R>(R Function(K key, V value) f) =>
      ImmortalList(_map.entries.map(
        (entry) => f(entry.key, entry.value),
      ));

  /// Returns a new map where all keys of this map are transformed by the given
  /// [f] function in respect to their values.
  ///
  /// If multiple entries have the same key after transformation, later
  /// occurences overwrite the earlier ones.
  ImmortalMap<K2, V> mapKeys<K2>(K2 Function(K key, V value) f) =>
      map((key, value) => MapEntry(f(key, value), value));

  /// Returns a new map where all values of this map are transformed by
  /// the given [f] function in respect of their keys.
  ImmortalMap<K, V2> mapValues<V2>(V2 Function(K key, V value) f) =>
      map((key, value) => MapEntry(key, f(key, value)));

  /// Returns an [ImmortalList] containing the entries of this map as tuples of
  /// key and value.
  ///
  /// If multiple pairs have the same key, later occurences overwrite the
  /// earlier ones.
  ImmortalList<Tuple2<K, V>> pairs() =>
      mapEntries((key, value) => Tuple2(key, value));

  /// Returns a copy of this map where the value of [key] is set to [value].
  ///
  /// See [add].
  ImmortalMap<K, V> put(K key, V value) => add(key, value);

  /// Returns a copy of this map where the key/value pair [entry] is added if no
  /// entry for [entry.key] is already present.
  ///
  /// See [addEntryIfAbsent].
  ImmortalMap<K, V> putEntryIfAbsent(MapEntry<K, V> entry) =>
      addEntryIfAbsent(entry);

  /// Returns a copy of this map setting the value of [key] if it isn't there.
  ///
  /// If [key] is present in the original map, [ifAbsent] is called to get the
  /// new value and [key] is associated to that value in the copied map.
  ///
  /// Example:
  ///
  ///     var scores = ImmortalMap({'Bob': 36});
  ///     for (var key in ['Bob', 'Rohan', 'Sophena']) {
  ///       scores = scores.addIfAbsent(key, () => key.length);
  ///     }
  ///     scores['Bob'];      // 36
  ///     scores['Rohan'];    //  5
  ///     scores['Sophena'];  //  7
  ImmortalMap<K, V> putIfAbsent(K key, V Function() ifAbsent) =>
      ImmortalMap._internal(toMutableMap()..putIfAbsent(key, ifAbsent));

  /// Returns a copy of this map replacing the values of all key/value pairs
  /// fulfilling the given [predicate] with [newValue].
  ImmortalMap<K, V> putWhere(
    bool Function(K key, V value) predicate,
    V newValue,
  ) =>
      mapValues((key, value) => predicate(key, value) ? newValue : value);

  /// Returns a copy of this map where [key] and its associated value are
  /// removed if present.
  ImmortalMap<K, V> remove(Object key) =>
      ImmortalMap._internal(toMutableMap()..remove(key));

  /// Returns a copy of this map where all keys and their associated values
  /// contained in [keysToRemove] are removed from.
  ImmortalMap<K, V> removeAll(ImmortalList<K> keysToRemove) =>
      removeWhere((key, _) => keysToRemove.contains(key));

  /// Returns a copy of this map where all entries with a value contained in
  /// [valuesToRemove] are removed from.
  ImmortalMap<K, V> removeAllValues(ImmortalList<V> valuesToRemove) =>
      removeWhere((_, value) => valuesToRemove.contains(value));

  /// Returns a copy of this map where all keys and their associated values
  /// contained in the iterable [keysToRemove] are removed from.
  ///
  /// See [removeAll].
  /// It iterates over [keysToRemove], which must therefore not change during
  /// the iteration.
  ImmortalMap<K, V> removeIterable(Iterable<K> keysToRemove) =>
      removeWhere((key, _) => keysToRemove.contains(key));

  /// Returns a copy of this map where all entries are removed that contain a
  /// value equal to [valueToRemove] according to the `==` operator.
  ImmortalMap<K, V> removeValue(Object valueToRemove) =>
      removeWhere((_, value) => value == valueToRemove);

  /// Returns a copy of this map where all entries with a value contained in the
  /// iterable [valuesToRemove] are removed from.
  /// It iterates over [valuesToRemove], which must therefore not change during
  /// the iteration.
  ImmortalMap<K, V> removeValuesIterable(Iterable<V> valuesToRemove) =>
      removeWhere((_, value) => valuesToRemove.contains(value));

  /// Returns a copy of this map where all entries that satisfy the given
  /// [predicate] are removed.
  ImmortalMap<K, V> removeWhere(bool Function(K key, V value) predicate) =>
      ImmortalMap._internal(toMutableMap()..removeWhere(predicate));

  /// Returns a copy of this map where the value of [key] is set to [newValue]
  /// if already present.
  ///
  /// Returns the map unchanged if [key] is not present.
  ImmortalMap<K, V> replace(K key, V newValue) =>
      lookup(key).map((value) => add(key, newValue)).orElse(this);

  /// Returns a copy of this map where the key/value pair with [key] is replaced
  /// by [entry] if already present.
  ///
  /// Overwrites a previous value in the copied map if [entry.key] was already
  /// present.
  ///
  /// Returns the map unchanged if [key] is not present.
  ImmortalMap<K, V> replaceEntry(K key, MapEntry<K, V> entry) =>
      lookup(key).map((_) => remove(key).addEntry(entry)).orElse(this);

  /// Returns a copy of this map where the key of the entry with [key] is
  /// replaced by [newKey] if already present.
  ///
  /// Overwrites a previous value in the copied map if [newKey] was already
  /// present.
  ///
  /// Returns the map unchanged if [key] is not present.
  ImmortalMap<K, V> replaceKey(K key, K newKey) =>
      lookup(key).map((value) => remove(key).add(newKey, value)).orElse(this);

  /// Returns a copy of this map replacing the values of all key/value pairs
  /// fulfilling the given [predicate] with [value].
  ///
  /// See [putWhere].
  ImmortalMap<K, V> replaceWhere(
    bool Function(K key, V value) predicate,
    V value,
  ) =>
      putWhere(predicate, value);

  /// Returns a copy of this map where the value of [key] is set to [value].
  ///
  /// See [add].
  ImmortalMap<K, V> set(K key, V value) => add(key, value);

  /// Returns a copy of this map where the key/value pair [entry] is added.
  ///
  /// See [addEntry].
  ImmortalMap<K, V> setEntry(MapEntry<K, V> entry) => addEntry(entry);

  /// Returns a copy of this map where the key/value pair [entry] is added if no
  /// entry for [entry.key] is already present.
  ///
  /// See [addEntryIfAbsent].
  ImmortalMap<K, V> setEntryIfAbsent(MapEntry<K, V> entry) =>
      addEntryIfAbsent(entry);

  /// Returns a copy of this map setting the value of [key] if it isn't there.
  ///
  /// See [putIfAbsent].
  ImmortalMap<K, V> setIfAbsent(K key, V Function() ifAbsent) =>
      putIfAbsent(key, ifAbsent);

  /// Returns a copy of this map replacing the values of all key/value pairs
  /// fulfilling the given [predicate] with [value].
  ///
  /// See [putWhere].
  ImmortalMap<K, V> setWhere(
    bool Function(K key, V value) predicate,
    V value,
  ) =>
      putWhere(predicate, value);

  /// Returns an [Optional] containing the only entry of this map if it has
  /// exactly one key/value pair, otherwise returns [Optional.empty].
  Optional<MapEntry<K, V>> get single => entries.single;

  /// Returns an [Optional] containing the only key in this map if it has
  /// exactly one key/value pair, otherwise returns [Optional.empty].
  ///
  /// This lookup can not distinguish between the map being empty and
  /// containing the `null` value as only key.
  /// Methods like [containsKey] or [length] can be used if the distinction
  /// is important.
  Optional<K> get singleKey => single.map((entry) => entry.key);

  /// Returns an [Optional] containing the only value in this map if it has
  /// exactly one key/value pair, otherwise returns [Optional.empty].
  ///
  /// This lookup can not distinguish between the map being empty and
  /// containing `null` as only value.
  /// Methods like [containsValue] or [length] can be used if the distinction
  /// is important.
  Optional<V> get singleValue => single.map((entry) => entry.value);

  /// Returns a mutable [LinkedHashMap] containing all key/value pairs of this
  /// map.
  Map<K, V> toMutableMap() => Map.from(_map);

  @override
  String toString() => 'Immortal${_map.toString()}';

  /// Returns a copy of this map updating the value for the provided [key].
  ///
  /// If the key is present, invokes [update] with the current value and stores
  /// the new value in the copied map.
  ///
  /// If the key is not present and [ifAbsent] is provided, calls [ifAbsent] and
  /// adds the key with the returned value to the copied map.
  ///
  /// If the key is not present and [ifAbsent] is not provided, the map is
  /// returned unchanged.
  ImmortalMap<K, V> update(
    K key,
    V Function(V value) update, {
    V Function() ifAbsent,
  }) {
    if (ifAbsent == null && !containsKey(key)) {
      return this;
    }
    return ImmortalMap._internal(
      toMutableMap()..update(key, update, ifAbsent: ifAbsent),
    );
  }

  /// Returns a copy of this map updating all values.
  ///
  /// Iterates over all entries in the copied map and updates them with the
  /// result of invoking [update].
  ImmortalMap<K, V> updateAll(V Function(K key, V value) update) =>
      ImmortalMap._internal(toMutableMap()..updateAll(update));

  /// Returns a copy of this map updating the entry for the provided [key].
  ///
  /// If the key is present, invokes [update] with the current value and
  /// replaces the key/value-pair with the result in the copied map.
  ///
  /// If the key is not present and [ifAbsent] is provided, calls [ifAbsent] and
  /// replaces the key/value with the result in the copied map.
  ///
  /// If the key is not present and [ifAbsent] is not provided, the map is
  /// returned unchanged.
  ///
  /// Overwrites a previous value in the copied map if a key/value pair with the
  /// new entry's key is already present.
  ImmortalMap<K, V> updateEntry(
    K key,
    MapEntry<K, V> Function(V value) update, {
    MapEntry<K, V> Function() ifAbsent,
  }) =>
      lookup(key)
          .map((value) => remove(key).addEntry(update(value)))
          .orElse(ifAbsent == null ? this : remove(key).addEntry(ifAbsent()));

  /// Returns a copy of this map where the key of the entry with [key] is
  /// replaced by applying [update] to its value if already present.
  ///
  /// Overwrites a previous value in the copied map if an entry for the
  /// resulting key was already present.
  ///
  /// Returns the map unchanged if [key] is not present.
  ImmortalMap<K, V> updateKey(K key, K Function(V value) update) => lookup(key)
      .map((value) => remove(key).add(update(value), value))
      .orElse(this);

  /// Returns a copy of this map invoking [update] on all key/value pairs
  /// fulfilling the given [predicate].
  ImmortalMap<K, V> updateWhere(
    bool Function(K key, V value) predicate,
    V Function(K key, V value) update,
  ) =>
      mapValues(
        (key, value) => predicate(key, value) ? update(key, value) : value,
      );

  /// Returns an [ImmortalList] containing the values of this map.
  ImmortalList<V> get values => ImmortalList(_map.values);

  /// Returns a copy of this map containing all entries that satisfy the given
  /// [predicate].
  ImmortalMap<K, V> where(bool Function(K key, V value) predicate) =>
      ImmortalMap._internal(
        toMutableMap()..removeWhere((key, value) => !predicate(key, value)),
      );

  /// Returns a copy of this map containing all entries with keys that satisfy
  /// the given [predicate].
  ImmortalMap<K, V> whereKey(bool Function(K key) predicate) =>
      ImmortalMap._internal(
        toMutableMap()..removeWhere((key, _) => !predicate(key)),
      );

  /// Returns a copy of this map containing all entries with values that satisfy
  /// the given [predicate].
  ImmortalMap<K, V> whereValue(bool Function(V value) predicate) =>
      ImmortalMap._internal(
        toMutableMap()..removeWhere((_, value) => !predicate(value)),
      );
}
