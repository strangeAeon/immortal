import 'package:optional/optional.dart';

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

  final Map<K, V> _map;

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

  /// Returns a copy of this map where all key/value pairs of [newEntries] are
  /// added.
  ///
  /// If a key of [newEntries] is already present in the copy,
  /// the corresponding value is overwritten.
  ///
  /// If [newEntries] is empty, the map is returned unchanged.
  ImmortalMap<K, V> addEntries(ImmortalList<MapEntry<K, V>> newEntries) =>
      addEntriesIterable(newEntries.toMutableList());

  /// Returns a copy of this map where all key/value pairs of the iterable
  /// [newEntries] are added.
  ///
  /// See [addEntries].
  /// It iterates over [newEntries], which must therefore not change during the
  /// iteration.
  ImmortalMap<K, V> addEntriesIterable(Iterable<MapEntry<K, V>> newEntries) {
    if (newEntries.isEmpty) {
      return this;
    }
    return ImmortalMap._internal(toMutableMap()..addEntries(newEntries));
  }

  /// Returns a copy of this map where the key/value pair [entry] is added.
  ///
  /// If the key of [entry] is already present in the copy,
  /// the corresponding value is overwritten.
  ImmortalMap<K, V> addEntry(MapEntry<K, V> entry) =>
      addEntriesIterable([entry]);

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

  /// Returns a copy of this map casting all keys to instances of [K2] and all
  /// values to instances of [V2].
  ///
  /// If this map contains only keys of type [K2] and values of type [V2],
  /// the copy will be created correctly, otherwise an exception will be thrown.
  ImmortalMap<K2, V2> cast<K2, V2>() => ImmortalMap(_map.cast<K2, V2>());

  /// Returns `true` if this map contains the given [key].
  ///
  /// Returns `true` if any of the keys in the map are equal to [key]
  /// according to the `==` operator.
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

  /// Applies [f] to each key/value pair of the map.
  void forEach(void Function(K key, V value) f) => _map.forEach(f);

  /// Returns `true` if there is no key/value pair in the map.
  bool get isEmpty => _map.isEmpty;

  /// Returns `true` if there is at least one key/value pair in the map.
  bool get isNotEmpty => _map.isNotEmpty;

  /// Returns an [ImmortalList] containing the keys of this map.
  ImmortalList<K> get keys => ImmortalList(_map.keys);

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

  /// Returns a new map where all entries of this map are transformed by
  /// the given [f] function.
  ImmortalMap<K2, V2> map<K2, V2>(
    MapEntry<K2, V2> Function(K key, V value) f,
  ) =>
      ImmortalMap(_map.map(f));

  /// Returns a new map where all keys of this map are transformed by
  /// the given [f] function in respect to their values.
  ImmortalMap<K2, V> mapKeys<K2>(K2 Function(K key, V value) f) =>
      map((key, value) => MapEntry(f(key, value), value));

  /// Returns a new map where all values of this map are transformed by
  /// the given [f] function in respect of their keys.
  ImmortalMap<K, V2> mapValues<V2>(V2 Function(K key, V value) f) =>
      map((key, value) => MapEntry(key, f(key, value)));

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

  /// Returns a copy of this map where [key] and its associated value are
  /// removed if present.
  ImmortalMap<K, V> remove(Object key) =>
      ImmortalMap._internal(toMutableMap()..remove(key));

  /// Returns a copy of this map where all entries are removed that contain a
  /// value equal to [valueToRemove] according to the `==` operator.
  ImmortalMap<K, V> removeValue(Object valueToRemove) =>
      removeWhere((_, value) => value == valueToRemove);

  /// Returns a copy of this map where all entries that satisfy the given
  /// [predicate] are removed.
  ImmortalMap<K, V> removeWhere(bool Function(K key, V value) predicate) =>
      ImmortalMap._internal(toMutableMap()..removeWhere(predicate));

  /// Returns a mutable [LinkedHashMap] containing all key/value pairs of this map.
  Map<K, V> toMutableMap() => Map.from(_map);

  @override
  String toString() => 'Immortal${_map.toString()}';

  /// Returns a copy of this map updating the value for the provided [key].
  ///
  /// If the key is present, invokes [update] with the current value and stores
  /// the new value in the copied map.
  ///
  /// If the key is not present and [ifAbsent] is provided, calls [ifAbsent]
  /// and adds the key with the returned value to the copied map.
  ///
  /// If the key is not present and [ifAbsent] is not provided, the list is
  /// returned unchanged.
  ImmortalMap<K, V> update(K key, V Function(V value) update,
      {V Function() ifAbsent}) {
    if (ifAbsent == null && !containsKey(key)) {
      return this;
    }
    return ImmortalMap._internal(toMutableMap()
      ..update(
        key,
        update,
        ifAbsent: ifAbsent,
      ));
  }

  /// Returns a copy of this map updating all values.
  ///
  /// Iterates over all entries in the copied map and updates them with the
  /// result of invoking [update].
  ImmortalMap<K, V> updateAll(V Function(K key, V value) update) =>
      ImmortalMap._internal(toMutableMap()..updateAll(update));

  /// Returns an [ImmortalList] containing the values of this map.
  ImmortalList<V> get values => ImmortalList(_map.values);
}
