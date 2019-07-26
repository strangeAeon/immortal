import 'package:optional/optional_internal.dart';
import 'package:test/test.dart';

import 'package:immortal/immortal.dart';

void main() {
  final emptyMap = ImmortalMap<String, int>();
  final singleMap = ImmortalMap({'a': 1});
  final multiMap = ImmortalMap({'a': 1, 'b': 2, 'c': 3});

  void expectMap<K, V>(ImmortalMap<K, V> actual, ImmortalMap<K, V> expected) {
    expect(actual.toMutableMap(), expected.toMutableMap());
  }

  void expectMapEntries<K, V>(ImmortalList<MapEntry<K, V>> actual,
      ImmortalList<MapEntry<K, V>> expected) {
    expect(actual.length, expected.length);
    for (var index = 0; index < actual.length; index++) {
      final actualEntry = actual.elementAt(index).value;
      final expectedEntry = expected.elementAt(index).value;
      expect(actualEntry.key, expectedEntry.key);
      expect(actualEntry.value, expectedEntry.value);
    }
  }

  void expectList<T>(ImmortalList<T> actual, ImmortalList<T> expected) {
    expect(actual.toMutableList(), expected.toMutableList());
  }

  tearDown(() {
    // Make sure that original maps were not changed
    expectMap(emptyMap, ImmortalMap<String, int>());
    expectMap(singleMap, ImmortalMap({'a': 1}));
    expectMap(multiMap, ImmortalMap({'a': 1, 'b': 2, 'c': 3}));
  });

  test('should create copy of map passed in constructor', () {
    final mutableMap = {'a': 1, 'b': 2, 'c': 3};
    final immortalMap = ImmortalMap(mutableMap);
    mutableMap.putIfAbsent('d', () => 4);
    expectMap(immortalMap, multiMap);
  });

  test('should return elements by key', () {
    expect(multiMap['a'], Optional.of(1));
    expect(multiMap['b'], Optional.of(2));
    expect(multiMap['c'], Optional.of(3));
    expect(multiMap['d'], Optional.empty());
    expect(multiMap.lookup('a'), Optional.of(1));
    expect(multiMap.lookup('b'), Optional.of(2));
    expect(multiMap.lookup('c'), Optional.of(3));
    expect(multiMap.lookup('d'), Optional.empty());
  });

  test('should add entry', () {
    expectMap(emptyMap.add('a', 1), singleMap);
    expectMap(emptyMap.addEntry(MapEntry('a', 1)), singleMap);
    final twoEntryMap = ImmortalMap({'a': 1, 'c': 3});
    expectMap(twoEntryMap.add('b', 2), multiMap);
    expectMap(twoEntryMap.addEntry(MapEntry('b', 2)), multiMap);
  });

  test('should replace entry', () {
    final otherSingleMap = ImmortalMap({'a': 2});
    expectMap(otherSingleMap.add('a', 1), singleMap);
    expectMap(otherSingleMap.addEntry(MapEntry('a', 1)), singleMap);
    final otherMultiMap = ImmortalMap({'a': 1, 'b': 4, 'c': 3});
    expectMap(otherMultiMap.add('b', 2), multiMap);
    expectMap(otherMultiMap.addEntry(MapEntry('b', 2)), multiMap);
  });

  test('should combine two immortal maps', () {
    expectMap(emptyMap.addAll(multiMap), multiMap);
    expectMap(singleMap.addAll(multiMap), multiMap);
    expect(multiMap.addAll(emptyMap), multiMap);
    expectMap(emptyMap + multiMap, multiMap);
    expectMap(singleMap + multiMap, multiMap);
    expect(multiMap + emptyMap, multiMap);
  });

  test('should add entries', () {
    expectMap(emptyMap.addEntries(multiMap.entries), multiMap);
    expectMap(singleMap.addEntries(multiMap.entries), multiMap);
    expect(multiMap.addEntries(ImmortalList()), multiMap);
  });

  test('should add iterable of entries', () {
    expectMap(
      emptyMap.addEntriesIterable(multiMap.entries.toMutableList()),
      multiMap,
    );
    expectMap(
      singleMap.addEntriesIterable(multiMap.entries.toMutableList()),
      multiMap,
    );
    expect(multiMap.addEntriesIterable([]), multiMap);
  });

  test('should add entry if absent', () {
    expectMap(emptyMap.addIfAbsent('a', () => 1), singleMap);
    expectMap(multiMap.addIfAbsent('a', () => 4), multiMap);
    expectMap(emptyMap.putIfAbsent('a', () => 1), singleMap);
    expectMap(multiMap.putIfAbsent('a', () => 4), multiMap);
  });

  test('should combine with the given mortal map', () {
    expectMap(emptyMap.addMap(multiMap.toMutableMap()), multiMap);
    expectMap(singleMap.addMap(multiMap.toMutableMap()), multiMap);
    expect(multiMap.addMap({}), multiMap);
  });

  test('should cast the map', () {
    expectMap(
      ImmortalMap<Object, Object>({'a': 1, 'b': 2, 'c': 3}).cast<String, int>(),
      multiMap,
    );
  });

  test('should check if key is contained', () {
    expect(emptyMap.containsKey('a'), false);
    expect(multiMap.containsKey('a'), true);
  });

  test('should check if value is contained', () {
    expect(emptyMap.containsValue(1), false);
    expect(multiMap.containsValue(1), true);
  });

  test('should copy map', () {
    final copy = singleMap.copy();
    expectMap(copy, singleMap);
    expect(copy == singleMap, false);
  });

  test('should return immortal list of entries', () {
    expectMapEntries(
      emptyMap.entries,
      ImmortalList<MapEntry<String, int>>(),
    );
    expectMapEntries(
      singleMap.entries,
      ImmortalList([MapEntry('a', 1)]),
    );
    expectMapEntries(
      multiMap.entries,
      ImmortalList([
        MapEntry('a', 1),
        MapEntry('b', 2),
        MapEntry('c', 3),
      ]),
    );
  });

  test('should execute function for each entry', () {
    var joinedKeys = '';
    var sum = 0;
    void handleEntry(key, value) {
      joinedKeys += key;
      sum += value;
    }

    multiMap.forEach(handleEntry);
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
    expect(multiMap.isEmpty, false);
  });

  test('should return if map is not empty', () {
    expect(emptyMap.isNotEmpty, false);
    expect(multiMap.isNotEmpty, true);
  });

  test('should return immortal list of keys', () {
    expectList(emptyMap.keys, ImmortalList<String>());
    expectList(singleMap.keys, ImmortalList(['a']));
    expectList(multiMap.keys, ImmortalList(['a', 'b', 'c']));
  });

  test("should return the map's size", () {
    expect(emptyMap.length, 0);
    expect(singleMap.length, 1);
    expect(multiMap.length, 3);
  });

  test('should apply function to each entry', () {
    expectMap(
      multiMap.map((key, value) => MapEntry(value, key)),
      ImmortalMap({1: 'a', 2: 'b', 3: 'c'}),
    );
    expectMap(
      multiMap.map((key, value) => MapEntry('a', value)),
      ImmortalMap({'a': 3}),
    );
  });

  test('should create list by applying function to each entry', () {
    expectList(
      multiMap.mapEntries((key, value) => '$value$key'),
      ImmortalList(['1a', '2b', '3c']),
    );
  });

  test('should apply function to each key', () {
    expectMap(
      multiMap.mapKeys((key, value) => value),
      ImmortalMap({1: 1, 2: 2, 3: 3}),
    );
    expectMap(multiMap.mapKeys((key, value) => 'a'), ImmortalMap({'a': 3}));
  });

  test('should apply function to each value', () {
    expectMap(
      multiMap.mapValues((key, value) => value * 2),
      ImmortalMap({'a': 2, 'b': 4, 'c': 6}),
    );
  });

  test('should remove entry by key', () {
    expectMap(singleMap.remove('a'), emptyMap);
    expectMap(multiMap.remove('a'), ImmortalMap({'b': 2, 'c': 3}));
  });

  test('should remove entries by key', () {
    expectMap(singleMap.removeAll(ImmortalList(['a'])), emptyMap);
    expectMap(
      multiMap.removeAll(ImmortalList(['a', 'c'])),
      ImmortalMap({'b': 2}),
    );
  });

  test('should remove entries by value', () {
    expectMap(singleMap.removeAllValues(ImmortalList([1])), emptyMap);
    expectMap(
      multiMap.removeAllValues(ImmortalList([1, 3])),
      ImmortalMap({'b': 2}),
    );
  });

  test('should remove entries by key iterable', () {
    expectMap(singleMap.removeIterable(['a']), emptyMap);
    expectMap(multiMap.removeIterable(['a', 'c']), ImmortalMap({'b': 2}));
  });

  test('should remove entry by value', () {
    expectMap(singleMap.removeValue(1), emptyMap);
    expectMap(ImmortalMap({'a': 1, 'b': 2, 'c': 2}).removeValue(2), singleMap);
    expectMap(multiMap.removeValue(4), multiMap);
  });

  test('should remove entries by value iterable', () {
    expectMap(singleMap.removeValuesIterable([1]), emptyMap);
    expectMap(multiMap.removeValuesIterable([1, 3]), ImmortalMap({'b': 2}));
  });

  test('should remove entries fulfilling a test', () {
    expectMap(singleMap.removeWhere((key, value) => true), emptyMap);
    expectMap(multiMap.removeWhere((key, value) => value > 1), singleMap);
    expectMap(multiMap.removeWhere((key, value) => false), multiMap);
  });

  test('should return map', () {
    expect(emptyMap.toMutableMap(), <String, int>{});
    expect(singleMap.toMutableMap(), {'a': 1});
    expect(multiMap.toMutableMap(), {'a': 1, 'b': 2, 'c': 3});
  });

  test('should transform map to string', () {
    expect(emptyMap.toString(), 'Immortal{}');
    expect(singleMap.toString(), 'Immortal{a: 1}');
    expect(multiMap.toString(), 'Immortal{a: 1, b: 2, c: 3}');
  });

  test('should update entry', () {
    expect(emptyMap.update('a', (value) => 4), emptyMap);
    expectMap(emptyMap.update('a', (value) => 4, ifAbsent: () => 1), singleMap);
    expectMap(
      singleMap.update('a', (value) => value + 1),
      ImmortalMap({'a': 2}),
    );
  });

  test('should update all entries', () {
    expectMap(emptyMap.updateAll((key, value) => 1), emptyMap);
    expectMap(
      multiMap.updateAll((key, value) => value + 1),
      ImmortalMap({'a': 2, 'b': 3, 'c': 4}),
    );
  });

  test('should return immortal list of values', () {
    expectList(emptyMap.values, ImmortalList<int>());
    expectList(singleMap.values, ImmortalList([1]));
    expectList(multiMap.values, ImmortalList([1, 2, 3]));
  });
}
