import 'package:optional/optional.dart';
import 'package:tuple/tuple.dart';

import '../immortal.dart';
import 'utils.dart';

R Function(K, V) _mapValue<K, V, R>(R Function(V value) f) => (_, v) => f(v);

/// An immutable collection of key/value pairs, from which you retrieve a value
/// using its associated key.
///
/// Operations on this map never modify the original instance but instead return
/// new instances created from mutable maps where the operations are applied to.
///
/// Internally a [LinkedHashMap] is used, regardless of what type of map is
/// passed to the constructor.
class ImmortalMap<K, V>
    implements DeeplyComparable, Mergeable<ImmortalMap<K, V>> {
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
  ImmortalMap([Map<K, V> map = const {}]) : _map = Map<K, V>.from(map);

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
  ///
  /// If multiple [entries] have the same key, later occurrences overwrite the
  /// earlier ones.
  ///
  /// It iterates over [entries], which must therefore not change during the
  /// iteration.
  factory ImmortalMap.fromEntries(Iterable<MapEntry<K, V>> entries) =>
      ImmortalMap._internal(Map.fromEntries(entries));

  /// Creates an [ImmortalMap] by associating the given [keys] to [values].
  ///
  /// This constructor iterates over [keys] and [values] and maps each element
  /// of [keys] to the corresponding element of [values].
  ///
  /// If the two iterables have different lengths, the iteration will stop at
  /// the length of the shorter one, so that there are always complete key/value
  /// pairs.
  ///
  /// If [keys] contains the same object multiple times, later occurrences
  /// overwrite the previous ones.
  ///
  /// All [keys] are required to implement compatible `operator==` and
  /// `hashCode`.
  ///
  /// It iterates over [keys] and [values], which must therefore not change
  /// during the iteration.
  factory ImmortalMap.fromIterables(Iterable<K> keys, Iterable<V> values) =>
      ImmortalMap._internal(Map.fromIterables(
        keys.take(values.length),
        values.take(keys.length),
      ));

  /// Creates an [ImmortalMap] containing all entries of [other].
  ///
  /// See [ImmortalMap.ofMap].
  factory ImmortalMap.fromMap(Map<K, V> other) => ImmortalMap(other);

  /// Creates an [ImmortalMap] instance that contains all [pairs] as entries.
  ///
  /// The keys must all be instances of [K] and the values of [V].
  ///
  /// All keys are required to implement compatible `operator==` and `hashCode`.
  ///
  /// If multiple [pairs] have the same key, later occurrences overwrite the
  /// earlier ones.
  ///
  /// It iterates over [pairs], which must therefore not change during the
  /// iteration.
  factory ImmortalMap.fromPairs(Iterable<Tuple2<K, V>> pairs) =>
      ImmortalMap<K, V>().addPairs(pairs);

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
  factory ImmortalMap.ofMap(Map<K, V> other) => ImmortalMap(other);

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
  static ImmortalMap<K2, V2> castFromMap<K, V, K2, V2>(Map<K, V> other) =>
      ImmortalMap(other.cast<K2, V2>());

  /// Creates an [ImmortalMap] by computing the keys and values from [iterable].
  ///
  /// For each element of [iterable] this constructor computes a key/value pair
  /// by applying [keyGenerator] and [valueGenerator] respectively.
  /// If no values are specified for [keyGenerator] and [valueGenerator] the
  /// default is the identity function.
  ///
  /// The keys computed by the source [iterable] do not need to be unique. The
  /// last occurrence of a key will simply overwrite any previous value.
  ///
  /// All keys are required to implement compatible `operator==` and `hashCode`.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  static ImmortalMap<K, V> fromIterable<K, V>(
    Iterable<dynamic> iterable, {
    K Function(dynamic value)? keyGenerator,
    V Function(dynamic value)? valueGenerator,
  }) =>
      ImmortalMap._internal(Map.fromIterable(
        iterable,
        key: keyGenerator,
        value: valueGenerator,
      ));

  final Map<K, V> _map;

  ImmortalMap<K, V> _mutateAsMap(Map<K, V> Function(Map<K, V>) f) =>
      ImmortalMap._internal(f(toMap()));

  ImmortalMap<K, V> _mutateAsMapIf(
    bool condition,
    Map<K, V> Function(Map<K, V>) f,
  ) =>
      condition ? _mutateAsMap(f) : this;

  /// Returns a copy of this map where all key/value pairs of [other] are added.
  ///
  /// See [addAll].
  ImmortalMap<K, V> operator +(ImmortalMap<K, V> other) => addAll(other);

  /// Returns an [Optional] containing the value for the given [key] or
  /// [Optional.empty] if [key] is not in the map.
  ///
  /// See [lookup].
  Optional<V> operator [](Object? key) => lookup(key);

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
  ImmortalMap<K, V> addAll(ImmortalMap<K, V> other) => addMap(other.toMap());

  /// Returns a copy of this map where all key/value pairs of [entries] are
  /// added.
  ///
  /// If a key of [entries] is already present in the copy, the corresponding
  /// value is overwritten.
  ///
  /// If [entries] is empty, the map is returned unchanged.
  ///
  /// It iterates over [entries], which must therefore not change during the
  /// iteration.
  ImmortalMap<K, V> addEntries(Iterable<MapEntry<K, V>> entries) =>
      _mutateAsMapIf(entries.isNotEmpty, (map) => map..addEntries(entries));

  /// Returns a copy of this map where the key/value pair [entry] is added.
  ///
  /// If the key of [entry] is already present in the copy, the corresponding
  /// value is overwritten.
  ImmortalMap<K, V> addEntry(MapEntry<K, V> entry) => addEntries([entry]);

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
  ImmortalMap<K, V> addMap(Map<K, V> other) =>
      _mutateAsMapIf(other.isNotEmpty, (map) => map..addAll(other));

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
  ///
  /// It iterates over [pairs], which must therefore not change during the
  /// iteration.
  ImmortalMap<K, V> addPairs(Iterable<Tuple2<K, V>> pairs) =>
      addEntries(pairs.map(
        (pair) => MapEntry(pair.item1, pair.item2),
      ));

  /// Checks whether any entry in this map satisfies the given [predicate].
  ///
  /// Checks every entry and returns `true` if any of them make [predicate]
  /// return `true`, otherwise returns `false`.
  bool any(bool Function(K key, V value) predicate) =>
      _map.entries.any((entry) => predicate(entry.key, entry.value));

  /// Checks whether any key of this map satisfies the given [predicate].
  ///
  /// Checks every key and returns `true` if any of them make [predicate]
  /// return `true`, otherwise returns `false`.
  bool anyKey(bool Function(K key) predicate) => _map.keys.any(predicate);

  /// Checks whether any value in this map satisfies the given [predicate].
  ///
  /// Checks every value and returns `true` if any of them make [predicate]
  /// return `true`, otherwise returns `false`.
  bool anyValue(bool Function(V value) predicate) => _map.values.any(predicate);

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
  bool containsKey(Object? key) => _map.containsKey(key);

  /// Returns `true` if this map contains the given [value].
  ///
  /// Returns `true` if any of the values in the map are equal to [value]
  /// according to the `==` operator.
  bool containsValue(Object? value) => _map.containsValue(value);

  /// Returns a copy of this map.
  ImmortalMap<K, V> copy() => ImmortalMap(_map);

  /// Returns an [ImmortalList] containing the entries of this map.
  ImmortalList<MapEntry<K, V>> get entries => ImmortalList(_map.entries);

  /// Checks whether this map is equal to [other].
  ///
  /// First an identity check is performed, using [operator ==]. If this fails,
  /// it is checked if [other] is an [ImmortalMap] and all contained entries of
  /// the two maps are compared using the `==` operators for keys and values.
  ///
  /// To solely test if two maps are identical, the operator `==` can be used.
  @override
  bool equals(dynamic other) =>
      this == other ||
      other is ImmortalMap<K, V> &&
          length == other.length &&
          mapEntries(
            (key, value) => other[key].map(equalTo(value)).orElse(false),
          ).every(isTrue);

  /// Checks whether every entry in this map satisfies the given [predicate].
  ///
  /// Returns `false` if any entry makes [predicate] return `false`, otherwise
  /// returns `true`.
  bool every(bool Function(K key, V value) predicate) =>
      _map.entries.every((entry) => predicate(entry.key, entry.value));

  /// Checks whether every key of this map satisfies the given [predicate].
  ///
  /// Returns `false` if any key makes [predicate] return `false`, otherwise
  /// returns `true`.
  bool everyKey(bool Function(K key) predicate) => _map.keys.every(predicate);

  /// Checks whether every value in this map satisfies the given [predicate].
  ///
  /// Returns `false` if any value makes [predicate] return `false`, otherwise
  /// returns `true`.
  bool everyValue(bool Function(V value) predicate) =>
      _map.values.every(predicate);

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

  /// Flattens a map of [ImmortalMap]s by building a new map from the nested map
  /// entries.
  ///
  /// If multiple entries have the same key after transformation, later
  /// occurences overwrite the earlier ones.
  ///
  /// If this map contains only instances of [ImmortalMap<K2, V2>] the new map
  /// will be created correctly, otherwise an exception is thrown.
  ImmortalMap<K2, V2> flatten<K2, V2>() =>
      ImmortalMap.fromEntries(cast<K, ImmortalMap<K2, V2>>()
          .mapEntries((_, map) => map.entries)
          .flatten());

  /// Flattens a map of mutable maps by building a new map from the nested map
  /// entries.
  ///
  /// If this map contains only instances of [Map<K2, V2>] the new map will be
  /// created correctly, otherwise an exception is thrown.
  ///
  /// See [flatten].
  ImmortalMap<K2, V2> flattenMaps<K2, V2>() => ImmortalMap.fromEntries(
      cast<K, Map<K2, V2>>().mapEntries((_, map) => map.entries).flatten());

  /// Applies [f] to each key/value pair of the map.
  void forEach(void Function(K key, V value) f) => _map.forEach(f);

  /// Returns an [Optional] containing the value for the given [key] or
  /// [Optional.empty] if [key] is not in the map.
  ///
  /// See [lookup].
  Optional<V> get(Object? key) => lookup(key);

  /// Returns an [ImmortalSet] of all keys with a value equal to the given
  /// [value] according to the `==` operator.
  ///
  /// See [lookupKeysForValue].
  ImmortalSet<K> getKeysForValue(Object? value) => lookupKeysForValue(value);

  /// Returns `true` if there is no key/value pair in the map.
  bool get isEmpty => _map.isEmpty;

  /// Returns `true` if there is at least one key/value pair in the map.
  bool get isNotEmpty => _map.isNotEmpty;

  /// Returns an [ImmortalSet] containing the keys of this map.
  ImmortalSet<K> get keys => ImmortalSet(_map.keys);

  /// Returns an [ImmortalSet] of all keys with a value equal to the given
  /// [value] according to the `==` operator.
  ///
  /// See [lookupKeysForValue].
  ImmortalSet<K> keysForValue(Object? value) => lookupKeysForValue(value);

  /// Returns an [ImmortalSet] containing the keys of all entries in this map
  /// that fulfill the given [predicate].
  ImmortalSet<K> keysWhere(bool Function(K key, V value) predicate) =>
      where(predicate).keys;

  /// The number of key/value pairs in the map.
  int get length => _map.length;

  /// Returns an [Optional] containing the value for the given [key] or
  /// [Optional.empty] if [key] is not in the map.
  ///
  /// This lookup can not distinguish between a key not being in the map and the
  /// key having a `null` value.
  /// Methods like [containsKey] or [addIfAbsent] can be used if the distinction
  /// is important.
  Optional<V> lookup(Object? key) => Optional.ofNullable(_map[key]);

  /// Returns an [ImmortalSet] of all keys with a value equal to the given
  /// [lookupValue] according to the `==` operator.
  ImmortalSet<K> lookupKeysForValue(Object? lookupValue) =>
      where(_mapValue(equalTo(lookupValue))).keys;

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

  /// Returns a copy of this map where all key/value pairs of [other] are added
  /// and merged with existing values if possible.
  ///
  /// If the value type [V] is [Mergeable] and a key is present in both maps,
  /// the resulting map will contain the merged result of the two respective
  /// values for this key.
  ///
  /// Otherwise the function behaves like [addAll], i.e. if a key of [other] is
  /// already present in this map, its value is overwritten in the copy.
  ///
  /// If [other] is empty, the map is returned unchanged.
  @override
  ImmortalMap<K, V> merge(ImmortalMap<K, V> other) => other.isEmpty
      ? this
      : updateAll((k, v) => other[k]
          .map(
              (otherValue) => v is Mergeable ? v.merge(otherValue) : otherValue)
          .orElse(v)).addAll(other.removeAll(keys));

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
  /// ```dart
  /// var scores = ImmortalMap({'Bob': 36});
  /// for (var key in ['Bob', 'Rohan', 'Sophena']) {
  ///   scores = scores.addIfAbsent(key, () => key.length);
  /// }
  /// scores['Bob'];      // 36
  /// scores['Rohan'];    //  5
  /// scores['Sophena'];  //  7
  /// ```
  ImmortalMap<K, V> putIfAbsent(K key, V Function() ifAbsent) =>
      _mutateAsMap((map) => map..putIfAbsent(key, ifAbsent));

  /// Returns a copy of this map replacing the values of all key/value pairs
  /// fulfilling the given [predicate] with [newValue].
  ImmortalMap<K, V> putWhere(
    bool Function(K key, V value) predicate,
    V newValue,
  ) =>
      mapValues((key, value) => predicate(key, value) ? newValue : value);

  /// Returns a copy of this map where [key] and its associated value are
  /// removed if present.
  ImmortalMap<K, V> remove(Object? key) =>
      _mutateAsMap((map) => map..remove(key));

  /// Returns a copy of this map where all keys and their associated values
  /// contained in [keysToRemove] are removed from.
  ImmortalMap<K, V> removeAll(ImmortalSet<Object?> keysToRemove) =>
      removeWhereKey(keysToRemove.contains);

  /// Returns a copy of this map where all keys and their associated values
  /// contained in the iterable [keysToRemove] are removed from.
  ///
  /// See [removeAll].
  /// It iterates over [keysToRemove], which must therefore not change during
  /// the iteration.
  ImmortalMap<K, V> removeIterable(Iterable<Object?> keysToRemove) =>
      removeWhereKey(keysToRemove.contains);

  /// Returns a copy of this map where all entries are removed that contain a
  /// value equal to [valueToRemove] according to the `==` operator.
  ImmortalMap<K, V> removeValue(Object? valueToRemove) =>
      removeWhereValue(equalTo(valueToRemove));

  /// Returns a copy of this map where all entries with a value contained in
  /// [valuesToRemove] are removed from.
  ///
  /// It iterates over [valuesToRemove], which must therefore not change during
  /// the iteration.
  ImmortalMap<K, V> removeValues(Iterable<Object?> valuesToRemove) =>
      removeWhereValue(valuesToRemove.contains);

  /// Returns a copy of this map where all entries that satisfy the given
  /// [predicate] are removed.
  ImmortalMap<K, V> removeWhere(bool Function(K key, V value) predicate) =>
      _mutateAsMap((map) => map..removeWhere(predicate));

  /// Returns a copy of this map removing all entries with keys fulfilling the
  /// given [predicate].
  ImmortalMap<K, V> removeWhereKey(bool Function(K key) predicate) =>
      _mutateAsMap((map) => map..removeWhere((key, _) => predicate(key)));

  /// Returns a copy of this map removing all entries with values fulfilling
  /// the given [predicate].
  ImmortalMap<K, V> removeWhereValue(bool Function(V value) predicate) =>
      _mutateAsMap((map) => map..removeWhere(_mapValue(predicate)));

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
  Optional<MapEntry<K, V>> get single => entries.singleAsOptional;

  /// Returns an [Optional] containing the only key in this map if it has
  /// exactly one key/value pair, otherwise returns [Optional.empty].
  ///
  /// This lookup can not distinguish between the map being empty and
  /// containing the `null` value as only key.
  /// Methods like [containsKey] or [length] can be used if the distinction
  /// is important.
  Optional<K> get singleKey => single.map((entry) => entry.key);

  /// Returns an [Optional] containing the key of only entry in this map that
  /// fulfills the given [predicate] if there is exactly one entry fulfilling
  /// this condition, otherwise returns [Optional.empty].
  Optional<K> singleKeyWhere(bool Function(K key, V value) predicate) =>
      where(predicate).singleKey;

  /// Returns an [Optional] containing the only value in this map if it has
  /// exactly one key/value pair, otherwise returns [Optional.empty].
  ///
  /// This lookup can not distinguish between the map being empty and
  /// containing `null` as only value.
  /// Methods like [containsValue] or [length] can be used if the distinction
  /// is important.
  Optional<V> get singleValue => single.map((entry) => entry.value);

  /// Returns an [Optional] containing the value of only entry in this map that
  /// fulfills the given [predicate] if there is exactly one entry fulfilling
  /// this condition, otherwise returns [Optional.empty].
  Optional<V> singleValueWhere(bool Function(K key, V value) predicate) =>
      where(predicate).singleValue;

  /// Returns an [Optional] containing the only entry in this map that fulfills
  /// the given [predicate] if there is exactly one entry fulfilling this
  /// condition, otherwise returns [Optional.empty].
  Optional<MapEntry<K, V>> singleWhere(
          bool Function(K key, V value) predicate) =>
      where(predicate).single;

  /// Returns a mutable [LinkedHashMap] containing all key/value pairs of this
  /// map.
  Map<K, V> toMap() => Map.from(_map);

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
    V Function()? ifAbsent,
  }) =>
      _mutateAsMapIf(ifAbsent != null || containsKey(key),
          (map) => map..update(key, update, ifAbsent: ifAbsent));

  /// Returns a copy of this map updating all values.
  ///
  /// Iterates over all entries in the copied map and updates them with the
  /// result of invoking [update].
  ImmortalMap<K, V> updateAll(V Function(K key, V value) update) =>
      _mutateAsMap((map) => map..updateAll(update));

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
    MapEntry<K, V> Function()? ifAbsent,
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

  /// Returns an [ImmortalList] containing the values of all entries in this
  /// map that fulfill the given [predicate].
  ImmortalList<V> valuesWhere(bool Function(K key, V value) predicate) =>
      where(predicate).values;

  /// Returns a copy of this map containing all entries that satisfy the given
  /// [predicate].
  ImmortalMap<K, V> where(bool Function(K key, V value) predicate) =>
      removeWhere((key, value) => !predicate(key, value));

  /// Returns a copy of this map containing all entries with keys that satisfy
  /// the given [predicate].
  ImmortalMap<K, V> whereKey(bool Function(K key) predicate) =>
      removeWhereKey(not(predicate));

  /// Returns a copy of this map containing all entries with values that satisfy
  /// the given [predicate].
  ImmortalMap<K, V> whereValue(bool Function(V value) predicate) =>
      removeWhereValue(not(predicate));
}
