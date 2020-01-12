import 'package:immortal/src/utils.dart';
import 'package:optional/optional_internal.dart';
import 'package:test/test.dart';

import 'package:immortal/immortal.dart';
import 'package:tuple/tuple.dart';

import 'test_data.dart';
import 'test_utils.dart';

void main() {
  final map123 = ImmortalMap({1: 1, 2: 2, 3: 3});
  final mapA1C3 = ImmortalMap({'a': 1, 'c': 3});
  final mapA1B1C1 = ImmortalMap({'a': 1, 'b': 1, 'c': 1});
  final mapA1B2C1 = ImmortalMap({'a': 1, 'b': 2, 'c': 1});
  final mapB2 = ImmortalMap({'b': 2});

  final entryA1 = MapEntry('a', 1);
  final entryB2 = MapEntry('b', 2);
  final entryC1 = MapEntry('c', 1);

  final listABC = ImmortalList(['a', 'b', 'c']);
  final emptyKeySet = ImmortalSet<String>();

  void expectMapEntry<K, V>(MapEntry<K, V> actual, MapEntry<K, V> expected) {
    expect(actual.key, expected.key);
    expect(actual.value, expected.value);
  }

  void expectMapEntries<K, V>(
    ImmortalList<MapEntry<K, V>> actual,
    ImmortalList<MapEntry<K, V>> expected,
  ) {
    expect(actual.length, expected.length);
    actual.forEachIndexed((index, actualEntry) {
      expectMapEntry(actualEntry, expected[index].value);
    });
  }

  tearDown(() {
    // Make sure that original maps were not changed
    expectCollection(emptyMap, ImmortalMap<String, int>());
    expectCollection(mapA1, ImmortalMap({'a': 1}));
    expectCollection(mapA1B2C3, ImmortalMap({'a': 1, 'b': 2, 'c': 3}));
  });

  test('should create copy of map passed in constructor', () {
    final mutableMap = {'a': 1, 'b': 2, 'c': 3};
    final immortalMap = ImmortalMap(mutableMap);
    mutableMap.putIfAbsent('d', yields(4));
    expectCollection(immortalMap, mapA1B2C3);
  });

  test('should create empty map', () {
    expectCollection(ImmortalMap<String, int>.empty(), emptyMap);
  });

  test('should create map from existing', () {
    expectCollection(ImmortalMap.from(emptyMap), emptyMap);
    expectCollection(ImmortalMap.from(mapA1), mapA1);
    expectCollection(ImmortalMap.from(mapA1B2C3), mapA1B2C3);
    expectCollection(ImmortalMap.of(emptyMap), emptyMap);
    expectCollection(ImmortalMap.of(mapA1), mapA1);
    expectCollection(ImmortalMap.of(mapA1B2C3), mapA1B2C3);
  });

  test('should create map from mutable', () {
    expectCollection(ImmortalMap.fromMutable({}), emptyMap);
    expectCollection(ImmortalMap.fromMutable({'a': 1}), mapA1);
    expectCollection(
      ImmortalMap.fromMutable({'a': 1, 'b': 2, 'c': 3}),
      mapA1B2C3,
    );
    expectCollection(ImmortalMap.ofMutable({}), emptyMap);
    expectCollection(ImmortalMap.ofMutable({'a': 1}), mapA1);
    expectCollection(
      ImmortalMap.ofMutable({'a': 1, 'b': 2, 'c': 3}),
      mapA1B2C3,
    );
  });

  test('should create map from entries', () {
    expectCollection(ImmortalMap.fromEntries(emptyMap.entries), emptyMap);
    expectCollection(ImmortalMap.fromEntries(mapA1.entries), mapA1);
    expectCollection(ImmortalMap.fromEntries(mapA1B2C3.entries), mapA1B2C3);
  });

  test('should create map from entries iterable', () {
    expectCollection(
      ImmortalMap.fromEntriesIterable(emptyMap.entries.toMutableList()),
      emptyMap,
    );
    expectCollection(
      ImmortalMap.fromEntriesIterable(mapA1.entries.toMutableList()),
      mapA1,
    );
    expectCollection(
      ImmortalMap.fromEntriesIterable(mapA1B2C3.entries.toMutableList()),
      mapA1B2C3,
    );
  });

  test('should create map from pairs', () {
    expectCollection(ImmortalMap.fromPairs(emptyMap.pairs()), emptyMap);
    expectCollection(ImmortalMap.fromPairs(mapA1.pairs()), mapA1);
    expectCollection(ImmortalMap.fromPairs(mapA1B2C3.pairs()), mapA1B2C3);
  });

  test('should create map from pairs iterable', () {
    expectCollection(
      ImmortalMap.fromPairsIterable(emptyMap.pairs().toMutableList()),
      emptyMap,
    );
    expectCollection(
      ImmortalMap.fromPairsIterable(mapA1.pairs().toMutableList()),
      mapA1,
    );
    expectCollection(
      ImmortalMap.fromPairsIterable(mapA1B2C3.pairs().toMutableList()),
      mapA1B2C3,
    );
  });

  test('should create map from lists of keys and values', () {
    expectCollection(ImmortalMap.fromLists(listABC, list123), mapA1B2C3);
    expectCollection(ImmortalMap.fromLists(listABC.take(1), list123), mapA1);
    expectCollection(ImmortalMap.fromLists(listABC, list1), mapA1);
  });

  test('should create map from iterables of keys and values', () {
    expectCollection(
      ImmortalMap.fromIterables(['a', 'b', 'c'], [1, 2, 3]),
      mapA1B2C3,
    );
    expectCollection(ImmortalMap.fromIterables(['a'], [1, 2, 3]), mapA1);
    expectCollection(ImmortalMap.fromIterables(['a', 'b', 'c'], [1]), mapA1);
  });

  test('should create map from list', () {
    expectCollection(
      ImmortalMap.fromList(
        list123,
        keyGenerator: (key) => 'b',
        valueGenerator: (value) => 2,
      ),
      mapB2,
    );
    expectCollection(ImmortalMap.fromList(list123), map123);
  });

  test('should create map from iterable', () {
    expectCollection(
      ImmortalMap.fromIterable(
        [1, 2, 3],
        keyGenerator: (key) => 'b',
        valueGenerator: (value) => 2,
      ),
      mapB2,
    );
    expectCollection(ImmortalMap.fromIterable([1, 2, 3]), map123);
  });

  test('should return elements by key', () {
    expect(mapA1B2C3['a'], Optional.of(1));
    expect(mapA1B2C3['b'], Optional.of(2));
    expect(mapA1B2C3['c'], Optional.of(3));
    expect(mapA1B2C3['d'], Optional.empty());
    expect(mapA1B2C3.lookup('a'), Optional.of(1));
    expect(mapA1B2C3.lookup('b'), Optional.of(2));
    expect(mapA1B2C3.lookup('c'), Optional.of(3));
    expect(mapA1B2C3.lookup('d'), Optional.empty());
    expect(mapA1B2C3.get('a'), Optional.of(1));
    expect(mapA1B2C3.get('b'), Optional.of(2));
    expect(mapA1B2C3.get('c'), Optional.of(3));
    expect(mapA1B2C3.get('d'), Optional.empty());
  });

  test('should add entry', () {
    expectCollection(emptyMap.add('a', 1), mapA1);
    expectCollection(emptyMap.addEntry(entryA1), mapA1);
    expectCollection(emptyMap.addPair(Tuple2('a', 1)), mapA1);
    expectCollection(emptyMap.put('a', 1), mapA1);
    expectCollection(emptyMap.set('a', 1), mapA1);
    expectCollection(emptyMap.setEntry(entryA1), mapA1);
    expectCollection(mapA1C3.add('b', 2), mapA1B2C3);
    expectCollection(mapA1C3.addEntry(entryB2), mapA1B2C3);
    expectCollection(mapA1C3.addPair(Tuple2('b', 2)), mapA1B2C3);
    expectCollection(mapA1C3.put('b', 2), mapA1B2C3);
    expectCollection(mapA1C3.set('b', 2), mapA1B2C3);
    expectCollection(mapA1C3.setEntry(entryB2), mapA1B2C3);
  });

  test('should replace entry', () {
    expectCollection(mapA1B2C3.add('c', 1), mapA1B2C1);
    expectCollection(mapA1B2C3.addEntry(entryC1), mapA1B2C1);
    expectCollection(mapA1B2C3.addPair(Tuple2('c', 1)), mapA1B2C1);
  });

  test('should combine two immortal maps', () {
    expectCollection(emptyMap.addAll(mapA1B2C3), mapA1B2C3);
    expectCollection(mapA1.addAll(mapA1B2C3), mapA1B2C3);
    expect(mapA1B2C3.addAll(emptyMap), mapA1B2C3);
    expectCollection(emptyMap + mapA1B2C3, mapA1B2C3);
    expectCollection(mapA1 + mapA1B2C3, mapA1B2C3);
    expect(mapA1B2C3 + emptyMap, mapA1B2C3);
  });

  test('should add entries', () {
    expectCollection(emptyMap.addEntries(mapA1B2C3.entries), mapA1B2C3);
    expectCollection(mapA1.addEntries(mapA1B2C3.entries), mapA1B2C3);
    expect(mapA1B2C3.addEntries(ImmortalList()), mapA1B2C3);
  });

  test('should add iterable of entries', () {
    expectCollection(
      emptyMap.addEntriesIterable(mapA1B2C3.entries.toMutableList()),
      mapA1B2C3,
    );
    expectCollection(
      mapA1.addEntriesIterable(mapA1B2C3.entries.toMutableList()),
      mapA1B2C3,
    );
    expect(mapA1B2C3.addEntriesIterable([]), mapA1B2C3);
  });

  test('should add entry if absent', () {
    final entryA4 = MapEntry('a', 4);
    expectCollection(emptyMap.addIfAbsent('a', yields(1)), mapA1);
    expectCollection(mapA1B2C3.addIfAbsent('a', yields(4)), mapA1B2C3);
    expectCollection(emptyMap.putIfAbsent('a', yields(1)), mapA1);
    expectCollection(mapA1B2C3.putIfAbsent('a', yields(4)), mapA1B2C3);
    expectCollection(emptyMap.setIfAbsent('a', yields(1)), mapA1);
    expectCollection(mapA1B2C3.setIfAbsent('a', yields(4)), mapA1B2C3);
    expectCollection(emptyMap.addEntryIfAbsent(entryA1), mapA1);
    expectCollection(mapA1B2C3.addEntryIfAbsent(entryA4), mapA1B2C3);
    expectCollection(emptyMap.putEntryIfAbsent(entryA1), mapA1);
    expectCollection(mapA1B2C3.putEntryIfAbsent(entryA4), mapA1B2C3);
    expectCollection(emptyMap.setEntryIfAbsent(entryA1), mapA1);
    expectCollection(mapA1B2C3.setEntryIfAbsent(entryA4), mapA1B2C3);
  });

  test('should combine with the given mortal map', () {
    expectCollection(emptyMap.addMap(mapA1B2C3.toMutableMap()), mapA1B2C3);
    expectCollection(mapA1.addMap(mapA1B2C3.toMutableMap()), mapA1B2C3);
    expect(mapA1B2C3.addMap({}), mapA1B2C3);
  });

  test('should add pairs', () {
    expectCollection(emptyMap.addPairs(mapA1B2C3.pairs()), mapA1B2C3);
    expectCollection(mapA1.addPairs(mapA1B2C3.pairs()), mapA1B2C3);
    expect(mapA1B2C3.addPairs(ImmortalList()), mapA1B2C3);
  });

  test('should add iterable of pairs', () {
    expectCollection(
      emptyMap.addPairsIterable(mapA1B2C3.pairs().toMutableList()),
      mapA1B2C3,
    );
    expectCollection(
      mapA1.addPairsIterable(mapA1B2C3.pairs().toMutableList()),
      mapA1B2C3,
    );
    expect(mapA1B2C3.addPairsIterable([]), mapA1B2C3);
  });

  test('should check if any entry satisfies a test', () {
    expect(mapA1B2C3.any(matchingAll), true);
    expect(mapA1B2C3.any(matchingValue(1)), true);
    expect(mapA1B2C3.any(matchingNone), false);
  });

  test('should check if any key satisfies a test', () {
    expect(mapA1B2C3.anyKey(matching('a')), true);
    expect(mapA1B2C3.anyKey(matchingAll), true);
    expect(mapA1B2C3.anyKey(matchingNone), false);
  });

  test('should check if any value satisfies a test', () {
    expect(mapA1B2C3.anyValue(matching(1)), true);
    expect(mapA1B2C3.anyValue(matchingAll), true);
    expect(mapA1B2C3.anyValue(matchingNone), false);
  });

  test('should cast the map', () {
    expectCollection(
      ImmortalMap<Object, Object>({'a': 1, 'b': 2, 'c': 3}).cast<String, int>(),
      mapA1B2C3,
    );
  });

  test('should create map by casting existing', () {
    expectCollection(
      ImmortalMap.castFrom(
        ImmortalMap<Object, Object>({'a': 1, 'b': 2, 'c': 3}),
      ),
      mapA1B2C3,
    );
  });

  test('should create map by casting mutable', () {
    expectCollection(
      ImmortalMap.castFromMutable(<Object, Object>{'a': 1, 'b': 2, 'c': 3}),
      mapA1B2C3,
    );
  });

  test('should check if key is contained', () {
    expect(emptyMap.containsKey('a'), false);
    expect(mapA1B2C3.containsKey('a'), true);
  });

  test('should check if value is contained', () {
    expect(emptyMap.containsValue(1), false);
    expect(mapA1B2C3.containsValue(1), true);
  });

  test('should copy map', () {
    final copy = mapA1.copy();
    expectCollection(copy, mapA1);
    expect(copy == mapA1, false);
  });

  test('should return immortal list of entries', () {
    expectMapEntries(emptyMap.entries, ImmortalList<MapEntry<String, int>>());
    expectMapEntries(mapA1.entries, ImmortalList([entryA1]));
    expectMapEntries(
      mapA1B2C3.entries,
      ImmortalList([
        MapEntry('a', 1),
        MapEntry('b', 2),
        MapEntry('c', 3),
      ]),
    );
  });

  test('should compare maps', () {
    expect(emptyMap.equals(ImmortalMap<String, int>()), true);
    expect(mapA1.equals(mapA1B2C3), false);
    expect(mapA1B2C3.equals(ImmortalMap({'a': 1, 'b': 2, 'c': 3})), true);
  });

  test('should check if every entry satisfies a test', () {
    expect(mapA1B2C3.every(matchingAll), true);
    expect(mapA1B2C3.every(matchingValue(1)), false);
    expect(mapA1B2C3.every(matchingNone), false);
  });

  test('should check if every key satisfies a test', () {
    expect(mapA1B2C3.everyKey(matchingAll), true);
    expect(mapA1B2C3.everyKey(matching('a')), false);
    expect(mapA1B2C3.everyKey(matchingNone), false);
  });

  test('should check if every value satisfies a test', () {
    expect(mapA1B2C3.everyValue(matchingAll), true);
    expect(mapA1B2C3.everyValue(matching(1)), false);
    expect(mapA1B2C3.everyValue(matchingNone), false);
  });

  test('should filter for entries fulfilling a test', () {
    expectCollection(mapA1.filter(matchingNone), emptyMap);
    expectCollection(mapA1B2C3.filter(matchingValue(1)), mapA1);
    expectCollection(mapA1B2C3.filter(matchingAll), mapA1B2C3);
    expectCollection(mapA1.where(matchingNone), emptyMap);
    expectCollection(mapA1B2C3.where(matchingValue(1)), mapA1);
    expectCollection(mapA1B2C3.where(matchingAll), mapA1B2C3);
  });

  test('should filter for entries with keys fulfilling a test', () {
    expectCollection(mapA1.filterKeys(matchingNone), emptyMap);
    expectCollection(mapA1B2C3.filterKeys(matching('a')), mapA1);
    expectCollection(mapA1B2C3.filterKeys(matchingAll), mapA1B2C3);
    expectCollection(mapA1.whereKey(matchingNone), emptyMap);
    expectCollection(mapA1B2C3.whereKey(matching('a')), mapA1);
    expectCollection(mapA1B2C3.whereKey(matchingAll), mapA1B2C3);
  });

  test('should filter for entries with values fulfilling a test', () {
    expectCollection(mapA1.filterValues(matchingNone), emptyMap);
    expectCollection(mapA1B2C3.filterValues(matching(1)), mapA1);
    expectCollection(mapA1B2C3.filterValues(matchingAll), mapA1B2C3);
    expectCollection(mapA1.whereValue(matchingNone), emptyMap);
    expectCollection(mapA1B2C3.whereValue(matching(1)), mapA1);
    expectCollection(mapA1B2C3.whereValue(matchingAll), mapA1B2C3);
  });

  test('should flatten map', () {
    final initialMap = ImmortalMap({
      1: ImmortalMap({'a': 4, 'b': 4, 'c': 4}),
      2: ImmortalMap({'a': 1, 'c': 4}),
      3: ImmortalMap({'b': 2, 'c': 3}),
    });
    expectCollection(initialMap.flatten(), mapA1B2C3);
  });

  test('should flatten nested mutable maps', () {
    final initialMap = ImmortalMap({
      1: {'a': 4, 'b': 4, 'c': 4},
      2: {'a': 1, 'c': 4},
      3: {'b': 2, 'c': 3},
    });
    expectCollection(initialMap.flattenMutables(), mapA1B2C3);
  });

  test('should execute function for each entry', () {
    var joinedKeys = '';
    var sum = 0;
    void handleEntry(key, value) {
      joinedKeys += key;
      sum += value;
    }

    mapA1B2C3.forEach(handleEntry);
    expect(joinedKeys, 'abc');
    expect(sum, 6);

    joinedKeys = '';
    sum = 0;
    emptyMap.forEach(handleEntry);
    expect(joinedKeys, '');
    expect(sum, 0);
  });

  test('should return if map is empty', () {
    expect(emptyMap.isEmpty, true);
    expect(mapA1B2C3.isEmpty, false);
  });

  test('should return if map is not empty', () {
    expect(emptyMap.isNotEmpty, false);
    expect(mapA1B2C3.isNotEmpty, true);
  });

  test('should return immortal set of keys', () {
    expectCollection(emptyMap.keys, emptyKeySet);
    expectCollection(mapA1.keys, ImmortalSet({'a'}));
    expectCollection(mapA1B2C3.keys, ImmortalSet({'a', 'b', 'c'}));
  });

  test('should return immortal set of keys with value', () {
    expectCollection(emptyMap.keysForValue(1), emptyKeySet);
    expectCollection(mapA1.keysForValue(1), ImmortalSet({'a'}));
    expectCollection(mapA1B2C1.keysForValue(1), ImmortalSet({'a', 'c'}));
    expectCollection(emptyMap.lookupKeysForValue(1), emptyKeySet);
    expectCollection(mapA1.lookupKeysForValue(1), ImmortalSet({'a'}));
    expectCollection(mapA1B2C1.lookupKeysForValue(1), ImmortalSet({'a', 'c'}));
    expectCollection(emptyMap.getKeysForValue(1), emptyKeySet);
    expectCollection(mapA1.getKeysForValue(1), ImmortalSet({'a'}));
    expectCollection(mapA1B2C1.getKeysForValue(1), ImmortalSet({'a', 'c'}));
  });

  test('should return keys of entries fulfilling a test', () {
    expectCollection(mapA1.keysWhere(matchingNone), emptyKeySet);
    expectCollection(mapA1B2C3.keysWhere(matchingValue(1)), ImmortalSet({'a'}));
    expectCollection(
      mapA1B2C3.keysWhere(matchingAll),
      ImmortalSet({'a', 'b', 'c'}),
    );
  });

  test("should return the map's size", () {
    expect(emptyMap.length, 0);
    expect(mapA1.length, 1);
    expect(mapA1B2C3.length, 3);
  });

  test('should apply function to each entry', () {
    expectCollection(
      mapA1B2C1.map((key, value) => MapEntry(value, key)),
      ImmortalMap({1: 'c', 2: 'b'}),
    );
    expectCollection(mapA1B2C3.map((key, value) => entryB2), mapB2);
  });

  test('should create list by applying function to each entry', () {
    expectCollection(map123.mapEntries(add), ImmortalList([2, 4, 6]));
  });

  test('should apply function to each key', () {
    expectCollection(mapA1B2C3.mapKeys((key, value) => value), map123);
    expectCollection(mapA1B2C3.mapKeys(yields(1)), ImmortalMap({1: 3}));
  });

  test('should apply function to each value', () {
    expectCollection(mapA1B2C3.mapValues(yields(1)), mapA1B1C1);
  });

  test('should merge values with other map if possible', () {
    final list23 = ImmortalList([2, 3]);
    final set23 = ImmortalSet({2, 3});
    expectCollection(emptyMap.merge(mapA1B2C3), mapA1B2C3);
    expectCollection(emptyMap.merge(mapA1B2C3), mapA1B2C3);
    expectCollection(mapA1B1C1.merge(mapA1B2C3), mapA1B2C3);
    expect(mapA1B2C3.merge(emptyMap), mapA1B2C3);
    expectCollection(
      ImmortalMap({'a': list1, 'b': list1}).merge(
        ImmortalMap({'b': list23, 'c': list23}),
      ),
      ImmortalMap({'a': list1, 'b': list123, 'c': list23}),
    );
    expectCollection(
      ImmortalMap({'a': set1, 'b': set1}).merge(
        ImmortalMap({'b': set23, 'c': set23}),
      ),
      ImmortalMap({'a': set1, 'b': set123, 'c': set23}),
    );
    expectCollection(
      ImmortalMap({'a': mapA1B1C1, 'b': mapA1C3}).merge(
        ImmortalMap({'b': mapB2, 'c': mapA1B2C1}),
      ),
      ImmortalMap({'a': mapA1B1C1, 'b': mapA1B2C3, 'c': mapA1B2C1}),
    );
  });

  test('should return immortal list of pairs', () {
    expectCollection(emptyMap.pairs(), ImmortalList<Tuple2<String, int>>());
    expectCollection(mapA1.pairs(), ImmortalList([Tuple2('a', 1)]));
    expectCollection(
      mapA1B2C3.pairs(),
      ImmortalList([
        Tuple2('a', 1),
        Tuple2('b', 2),
        Tuple2('c', 3),
      ]),
    );
  });

  test('should remove entry by key', () {
    expectCollection(mapA1.remove('a'), emptyMap);
    expectCollection(mapA1B2C3.remove('b'), mapA1C3);
  });

  test('should remove entries by key', () {
    final toRemove = ImmortalSet({'a', 'c'});
    expectCollection(mapA1.removeAll(toRemove), emptyMap);
    expectCollection(mapA1B2C3.removeAll(toRemove), mapB2);
  });

  test('should remove entries by key iterable', () {
    expectCollection(mapA1.removeIterable(['a']), emptyMap);
    expectCollection(mapA1B2C3.removeIterable(['a', 'c']), mapB2);
  });

  test('should remove entry by value', () {
    expectCollection(mapA1.removeValue(1), emptyMap);
    expectCollection(mapA1B2C1.removeValue(1), mapB2);
    expectCollection(mapA1B2C3.removeValue(4), mapA1B2C3);
  });

  test('should remove entries by value', () {
    expectCollection(mapA1.removeValues(list1), emptyMap);
    expectCollection(mapA1B2C3.removeValues(ImmortalList([1, 3])), mapB2);
  });

  test('should remove entries by value iterable', () {
    expectCollection(mapA1.removeValuesIterable([1]), emptyMap);
    expectCollection(mapA1B2C3.removeValuesIterable([1, 3]), mapB2);
  });

  test('should remove entries fulfilling a test', () {
    expectCollection(mapA1.removeWhere(matchingAll), emptyMap);
    expectCollection(mapA1B2C1.removeWhere(matchingValue(1)), mapB2);
    expectCollection(mapA1B2C3.removeWhere(matchingNone), mapA1B2C3);
  });

  test('should remove entries with keys fulfilling a test', () {
    expectCollection(mapA1.removeWhereKey(matchingAll), emptyMap);
    expectCollection(mapA1B2C3.removeWhereKey(not(matching('a'))), mapA1);
    expectCollection(mapA1B2C3.removeWhereKey(matchingNone), mapA1B2C3);
  });

  test('should remove entries with values fulfilling a test', () {
    expectCollection(mapA1.removeWhereValue(matchingAll), emptyMap);
    expectCollection(mapA1B2C3.removeWhereValue(not(matching(1))), mapA1);
    expectCollection(mapA1B2C3.removeWhereValue(matchingNone), mapA1B2C3);
  });

  test('should replace value if present', () {
    expect(emptyMap.replace('a', 1), emptyMap);
    expect(mapA1B2C3.replace('d', 4), mapA1B2C3);
    expectCollection(mapA1B2C3.replace('c', 1), mapA1B2C1);
  });

  test('should replace entry if present', () {
    expect(emptyMap.replaceEntry('a', entryC1), emptyMap);
    expect(mapA1B2C3.replaceEntry('d', entryC1), mapA1B2C3);
    expectCollection(mapA1B2C3.replaceEntry('c', entryC1), mapA1B2C1);
  });

  test('should replace key if present', () {
    expect(emptyMap.replaceKey('a', 'd'), emptyMap);
    expect(mapA1B2C3.replaceKey('d', 'e'), mapA1B2C3);
    expectCollection(
      mapA1B2C3.replaceKey('a', 'd'),
      ImmortalMap({'b': 2, 'c': 3, 'd': 1}),
    );
    expectCollection(
      mapA1B2C3.replaceKey('a', 'b'),
      ImmortalMap({'b': 1, 'c': 3}),
    );
  });

  test('should replace values fulfilling a test', () {
    expectCollection(mapA1B2C3.replaceWhere(matchingValue(3), 1), mapA1B2C1);
    expectCollection(mapA1B2C3.replaceWhere(matchingNone, 4), mapA1B2C3);
    expectCollection(mapA1B2C3.putWhere(matchingValue(3), 1), mapA1B2C1);
    expectCollection(mapA1B2C3.putWhere(matchingNone, 4), mapA1B2C3);
    expectCollection(mapA1B2C3.setWhere(matchingValue(3), 1), mapA1B2C1);
    expectCollection(mapA1B2C3.setWhere(matchingNone, 4), mapA1B2C3);
  });

  test('should return single entry', () {
    expect(emptyMap.single, Optional.empty());
    expectMapEntry(mapA1.single.value, entryA1);
    expect(mapA1B2C3.single, Optional.empty());
  });

  test('should return single key', () {
    expect(emptyMap.singleKey, Optional.empty());
    expect(mapA1.singleKey, Optional.of('a'));
    expect(mapA1B2C3.singleKey, Optional.empty());
  });

  test('should return single key fulfilling a test', () {
    expect(emptyMap.singleKeyWhere(matchingNone), Optional.empty());
    expect(mapA1B2C3.singleKeyWhere(matchingValue(1)), Optional.of('a'));
    expect(mapA1B2C3.singleKeyWhere(matchingAll), Optional.empty());
  });

  test('should return single value', () {
    expect(emptyMap.singleValue, Optional.empty());
    expect(mapA1.singleValue, Optional.of(1));
    expect(mapA1B2C3.singleValue, Optional.empty());
  });

  test('should return single value fulfilling a test', () {
    expect(emptyMap.singleValueWhere(matchingNone), Optional.empty());
    expect(mapA1B2C3.singleValueWhere(matchingValue(1)), Optional.of(1));
    expect(mapA1B2C3.singleValueWhere(matchingAll), Optional.empty());
  });

  test('should return single entry fulfilling a test', () {
    expect(emptyMap.singleWhere(matchingNone), Optional.empty());
    expectMapEntry(mapA1B2C3.singleWhere(matchingValue(1)).value, entryA1);
    expect(mapA1B2C3.singleWhere(matchingAll), Optional.empty());
  });

  test('should return map', () {
    expect(emptyMap.toMutableMap(), <String, int>{});
    expect(mapA1.toMutableMap(), {'a': 1});
    expect(mapA1B2C3.toMutableMap(), {'a': 1, 'b': 2, 'c': 3});
  });

  test('should transform map to string', () {
    expect(emptyMap.toString(), 'Immortal{}');
    expect(mapA1.toString(), 'Immortal{a: 1}');
    expect(mapA1B2C3.toString(), 'Immortal{a: 1, b: 2, c: 3}');
  });

  test('should update entry', () {
    expect(emptyMap.update('a', yields(2)), emptyMap);
    expectCollection(
      emptyMap.update('a', yields(2), ifAbsent: yields(1)),
      mapA1,
    );
    expectCollection(mapA1.update('a', inc), ImmortalMap({'a': 2}));
    expect(emptyMap.updateEntry('a', yields(entryB2)), emptyMap);
    expectCollection(
      emptyMap.updateEntry('a', yields(entryB2), ifAbsent: yields(entryA1)),
      mapA1,
    );
    expectCollection(mapA1.updateEntry('a', yields(entryB2)), mapB2);
  });

  test('should update all entries', () {
    expectCollection(emptyMap.updateAll(yields(1)), emptyMap);
    expectCollection(mapA1B2C3.updateAll(yields(1)), mapA1B1C1);
  });

  test('should update key', () {
    expect(emptyMap.updateKey('a', (value) => 'd'), emptyMap);
    expectCollection(
      mapA1.updateKey('a', (value) => 'd'),
      ImmortalMap({'d': 1}),
    );
  });

  test('should update values fulfilling a test', () {
    expectCollection(
      mapA1B2C3.updateWhere(matchingValue(3), yields(1)),
      mapA1B2C1,
    );
    expectCollection(
      mapA1B2C3.updateWhere(matchingNone, yields(1)),
      mapA1B2C3,
    );
  });

  test('should return immortal list of values', () {
    expectCollection(emptyMap.values, emptyList);
    expectCollection(mapA1.values, list1);
    expectCollection(mapA1B2C3.values, list123);
  });

  test('should return values of entries fulfilling a test', () {
    expectCollection(mapA1.valuesWhere(matchingNone), emptyList);
    expectCollection(mapA1B2C3.valuesWhere(matchingValue(1)), list1);
    expectCollection(mapA1B2C3.valuesWhere(matchingAll), list123);
  });
}
