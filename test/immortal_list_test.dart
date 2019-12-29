import 'dart:math';

import 'package:optional/optional.dart';
import 'package:test/test.dart';

import 'package:immortal/immortal.dart';
import 'package:tuple/tuple.dart';

void main() {
  final emptyList = ImmortalList<int>();
  final singleList = ImmortalList([1]);
  final multiList = ImmortalList([1, 2, 3]);
  final equalElementsList = ImmortalList([1, 1, 1]);

  void expectList<T>(ImmortalList<T> actual, ImmortalList<T> expected) {
    expect(actual.equals(expected), true);
  }

  void expectSet<T>(ImmortalSet<T> actual, ImmortalSet<T> expected) {
    expect(actual.equals(expected), true);
  }

  void expectMap<K, V>(ImmortalMap<K, V> actual, ImmortalMap<K, V> expected) {
    expect(actual.equals(expected), true);
  }

  void expectMapOfLists<K, V>(ImmortalMap<K, ImmortalList<V>> actual,
      ImmortalMap<K, ImmortalList<V>> expected) {
    expect(actual.length, expected.length);
    actual.entries.forEach((entry) {
      final expectedEntry = expected[entry.key];
      expectList(entry.value, expectedEntry.value);
    });
  }

  void expectListTuple<T1, T2>(
    Tuple2<ImmortalList<T1>, ImmortalList<T2>> actual,
    Tuple2<ImmortalList<T1>, ImmortalList<T2>> expected,
  ) {
    expectList(actual.item1, expected.item1);
    expectList(actual.item2, expected.item2);
  }

  tearDown(() {
    // Make sure that original lists were not changed
    expectList(emptyList, ImmortalList<int>());
    expectList(singleList, ImmortalList([1]));
    expectList(multiList, ImmortalList([1, 2, 3]));
  });

  test('should create copy of list passed in constructor', () {
    final mutableList = [1, 2, 3];
    final immortalList = ImmortalList(mutableList);
    mutableList.add(4);
    expectList(immortalList, multiList);
  });

  test('should create empty list', () {
    expectList(ImmortalList<int>.empty(), emptyList);
  });

  test('should create list with fill value', () {
    expectList(ImmortalList.filled(-1, 1), emptyList);
    expectList(ImmortalList.filled(1, 1), singleList);
    expectList(ImmortalList.filled(3, 1), ImmortalList([1, 1, 1]));
  });

  test('should create list from existing', () {
    expectList(ImmortalList.from(emptyList), emptyList);
    expectList(ImmortalList.from(singleList), singleList);
    expectList(ImmortalList.from(multiList), multiList);
    expectList(ImmortalList.of(emptyList), emptyList);
    expectList(ImmortalList.of(singleList), singleList);
    expectList(ImmortalList.of(multiList), multiList);
  });

  test('should create list from iterable', () {
    expectList(ImmortalList.fromIterable([]), emptyList);
    expectList(ImmortalList.fromIterable([1]), singleList);
    expectList(ImmortalList.fromIterable([1, 2, 3]), multiList);
    expectList(ImmortalList.ofIterable([]), emptyList);
    expectList(ImmortalList.ofIterable([1]), singleList);
    expectList(ImmortalList.ofIterable([1, 2, 3]), multiList);
  });

  test('should generate list', () {
    expectList(ImmortalList.generate(-1, (index) => index), emptyList);
    expectList(ImmortalList.generate(1, (index) => index + 1), singleList);
    expectList(ImmortalList.generate(3, (index) => index + 1), multiList);
  });

  test('should return elements by index', () {
    expect(multiList[-1], Optional.empty());
    expect(multiList.elementAt(-1), Optional.empty());
    expect(multiList[0], Optional.of(1));
    expect(multiList.elementAt(0), Optional.of(1));
    expect(multiList[1], Optional.of(2));
    expect(multiList.elementAt(1), Optional.of(2));
    expect(multiList[2], Optional.of(3));
    expect(multiList.elementAt(2), Optional.of(3));
    expect(multiList[3], Optional.empty());
    expect(multiList.elementAt(3), Optional.empty());
    expect(emptyList[0], Optional.empty());
    expect(emptyList.elementAt(0), Optional.empty());
  });

  test('should add single value', () {
    expectList(emptyList.add(1), singleList);
    expectList(multiList.add(4), ImmortalList([1, 2, 3, 4]));
  });

  test('should add all elements', () {
    expect(emptyList.addAll(emptyList), emptyList);
    expectList(emptyList.addAll(singleList), singleList);
    expectList(
      multiList.addAll(ImmortalList([4, 5])),
      ImmortalList([1, 2, 3, 4, 5]),
    );
  });

  test('should add all elements of the given iterable', () {
    expect(emptyList.addIterable([]), emptyList);
    expectList(emptyList.addIterable([1]), singleList);
    expectList(multiList.addIterable([4, 5]), ImmortalList([1, 2, 3, 4, 5]));
  });

  test('should check if any element satisfies a test', () {
    expect(multiList.any((value) => value < 3), true);
    expect(multiList.any((value) => value > 3), false);
  });

  test('should check if any element and index satisfies a test', () {
    expect(multiList.anyIndexed((index, value) => value + index < 3), true);
    expect(multiList.anyIndexed((index, value) => value - index > 3), false);
  });

  test('should transform list to immortal map', () {
    expectMap(emptyList.asMap(), ImmortalMap<int, int>());
    expectMap(singleList.asMap(), ImmortalMap({0: 1}));
    expectMap(multiList.asMap(), ImmortalMap({0: 1, 1: 2, 2: 3}));
  });

  test('should transform list to immortal map of lists', () {
    expectMapOfLists(
      singleList.asMapOfLists((v) => v),
      ImmortalMap({
        1: ImmortalList([1]),
      }),
    );
    expectMapOfLists(
      multiList.asMapOfLists((v) => v.isOdd),
      ImmortalMap({
        true: ImmortalList([1, 3]),
        false: ImmortalList([2]),
      }),
    );
  });

  test('should transform list to immortal map with a key function', () {
    expectMap(singleList.asMapWithKeys((v) => v), ImmortalMap({1: 1}));
    expectMap(
      multiList.asMapWithKeys((v) => v.toString()),
      ImmortalMap({'1': 1, '2': 2, '3': 3}),
    );
    expectMap(
      multiList.asMapWithKeys((v) => v.isOdd),
      ImmortalMap({true: 3, false: 2}),
    );
  });

  test('should transform list to immortal map with an indexed key function',
      () {
    expectMap(
      singleList.asMapWithKeysIndexed((i, v) => v + i),
      ImmortalMap({1: 1}),
    );
    expectMap(
      multiList.asMapWithKeysIndexed((i, v) => '$i-$v'),
      ImmortalMap({'0-1': 1, '1-2': 2, '2-3': 3}),
    );
    expectMap(
      multiList.asMapWithKeysIndexed((i, v) => (v + i).isOdd),
      ImmortalMap({true: 3}),
    );
  });

  test('should cast the list', () {
    expectList(ImmortalList<Object>([1, 2, 3]).cast<int>(), multiList);
  });

  test('should create list by casting existing', () {
    expectList(
      ImmortalList.castFrom(ImmortalList<Object>([1, 2, 3])),
      multiList,
    );
  });

  test('should create list by casting iterable', () {
    expectList(ImmortalList.castFromIterable(<Object>[1, 2, 3]), multiList);
  });

  test('should concatenate', () {
    expect(singleList + emptyList, singleList);
    expectList(emptyList + singleList, singleList);
    expectList(singleList + multiList, ImmortalList([1, 1, 2, 3]));
    expect(singleList.concatenate(emptyList), singleList);
    expectList(emptyList.concatenate(singleList), singleList);
    expectList(singleList.concatenate(multiList), ImmortalList([1, 1, 2, 3]));
    expect(singleList.followedBy(emptyList), singleList);
    expectList(emptyList.followedBy(singleList), singleList);
    expectList(singleList.followedBy(multiList), ImmortalList([1, 1, 2, 3]));
  });

  test('should concatenate the given iterable', () {
    expect(singleList.concatenateIterable([]), singleList);
    expectList(emptyList.concatenateIterable([1]), singleList);
    expectList(
      singleList.concatenateIterable([1, 2, 3]),
      ImmortalList([1, 1, 2, 3]),
    );
    expect(singleList.followedByIterable([]), singleList);
    expectList(emptyList.followedByIterable([1]), singleList);
    expectList(
      singleList.followedByIterable([1, 2, 3]),
      ImmortalList([1, 1, 2, 3]),
    );
  });

  test('should check if an element is contained', () {
    expect(multiList.contains(3), true);
    expect(multiList.contains(4), false);
  });

  test('should copy list', () {
    final copy = singleList.copy();
    expectList(copy, singleList);
    expect(copy == singleList, false);
  });

  test('should compare lists', () {
    expect(emptyList.equals(ImmortalList<int>()), true);
    expect(singleList.equals(multiList), false);
    expect(multiList.equals(ImmortalList([1, 2, 3])), true);
  });

  test('should check if all elements satisfy a test', () {
    expect(emptyList.every((value) => value < 4), true);
    expect(multiList.every((value) => value < 4), true);
    expect(multiList.every((value) => value > 2), false);
  });

  test('should check if all elements and their indices satisfy a test', () {
    expect(emptyList.everyIndexed((index, value) => value + index < 4), true);
    expect(multiList.everyIndexed((index, value) => value - index < 4), true);
    expect(multiList.everyIndexed((index, value) => value + index > 2), false);
  });

  test('should expand each element to a list and flatten the result', () {
    expectList(
      singleList.expand((i) => ImmortalList([i, i * 1.0])),
      ImmortalList([1.0, 1.0]),
    );
    expectList(
      multiList.expand((i) => ImmortalList([i, i * 2])),
      ImmortalList([1, 2, 2, 4, 3, 6]),
    );
    expectList(
      singleList.flatMap((i) => ImmortalList([i, i * 1.0])),
      ImmortalList([1.0, 1.0]),
    );
    expectList(
      multiList.flatMap((i) => ImmortalList([i, i * 2])),
      ImmortalList([1, 2, 2, 4, 3, 6]),
    );
  });

  test(
      'should expand each element and its index to a list and flatten the'
      'result', () {
    expectList(
      singleList.expandIndexed((index, i) => ImmortalList([i, i * index])),
      ImmortalList([1, 0]),
    );
    expectList(
      multiList.expandIndexed((index, i) => ImmortalList([i, i * index])),
      ImmortalList([1, 0, 2, 2, 3, 6]),
    );
    expectList(
      singleList.flatMapIndexed((index, i) => ImmortalList([i, i * index])),
      ImmortalList([1, 0]),
    );
    expectList(
      multiList.flatMapIndexed((index, i) => ImmortalList([i, i * index])),
      ImmortalList([1, 0, 2, 2, 3, 6]),
    );
  });

  test('should expand each element to an iterable and flatten the result', () {
    expectList(
      singleList.expandIterable((i) => [i, i * 1.0]),
      ImmortalList([1.0, 1.0]),
    );
    expectList(
      multiList.expandIterable((i) => [i, i * 2]),
      ImmortalList([1, 2, 2, 4, 3, 6]),
    );
    expectList(
      singleList.flatMapIterable((i) => [i, i * 1.0]),
      ImmortalList([1.0, 1.0]),
    );
    expectList(
      multiList.flatMapIterable((i) => [i, i * 2]),
      ImmortalList([1, 2, 2, 4, 3, 6]),
    );
  });

  test(
      'should expand each element and its index to an iterable and flatten the'
      'result', () {
    expectList(
      singleList.expandIterableIndexed((index, i) => [i, i * index]),
      ImmortalList([1, 0]),
    );
    expectList(
      multiList.expandIterableIndexed((index, i) => [i, i * index]),
      ImmortalList([1, 0, 2, 2, 3, 6]),
    );
    expectList(
      singleList.flatMapIterableIndexed((index, i) => [i, i * index]),
      ImmortalList([1, 0]),
    );
    expectList(
      multiList.flatMapIterableIndexed((index, i) => [i, i * index]),
      ImmortalList([1, 0, 2, 2, 3, 6]),
    );
  });

  test('should fill a range with a given value', () {
    expectList(multiList.fillRange(-1, 1, 4), ImmortalList([4, 2, 3]));
    expectList(multiList.fillRange(2, 5, 4), ImmortalList([1, 2, 4]));
    expect(multiList.fillRange(1, 1, 4), multiList);
    expectList(multiList.fillRange(0, 2, 4), ImmortalList([4, 4, 3]));
  });

  test('should return elements fulfilling a test', () {
    expectList(multiList.filter((value) => value > 1), ImmortalList([2, 3]));
    expectList(multiList.filter((value) => value > 4), emptyList);
    expectList(multiList.filter((value) => value > 0), multiList);
    expectList(multiList.where((value) => value > 1), ImmortalList([2, 3]));
    expectList(multiList.where((value) => value > 4), emptyList);
    expectList(multiList.where((value) => value > 0), multiList);
  });

  test('should return elements that fulfill a test with their index', () {
    expectList(
      multiList.filterIndexed((index, value) => value + index > 1),
      ImmortalList([2, 3]),
    );
    expectList(
      multiList.filterIndexed((index, value) => value + index > 5),
      emptyList,
    );
    expectList(
      multiList.filterIndexed((index, value) => value + index > 0),
      multiList,
    );
    expectList(
      multiList.whereIndexed((index, value) => value + index > 1),
      ImmortalList([2, 3]),
    );
    expectList(
      multiList.whereIndexed((index, value) => value + index > 5),
      emptyList,
    );
    expectList(
      multiList.whereIndexed((index, value) => value + index > 0),
      multiList,
    );
  });

  test('should return elements of a type', () {
    expectList(ImmortalList([1, '1', '2']).filterType<int>(), singleList);
    expectList(multiList.filterType<String>(), ImmortalList<String>());
    expectList(ImmortalList([1, '1', '2']).whereType<int>(), singleList);
    expectList(multiList.whereType<String>(), ImmortalList<String>());
  });

  test('should return first element', () {
    expect(emptyList.first, Optional.empty());
    expect(singleList.first, Optional.of(1));
    expect(multiList.first, Optional.of(1));
  });

  test('should return first element fulfilling a given test', () {
    expect(multiList.firstWhere((value) => value < 0), Optional.empty());
    expect(multiList.firstWhere((value) => value > 2), Optional.of(3));
    expect(multiList.firstWhere((value) => value > 2), Optional.of(3));
    expect(multiList.firstWhere((value) => value < 0), Optional.empty());
  });

  test('should flatten list of lists', () {
    expectList(
      ImmortalList([
        ImmortalList([1, 2]),
        ImmortalList([1, 2, 3]),
        ImmortalList([4]),
      ]).flatten(),
      ImmortalList([1, 2, 1, 2, 3, 4]),
    );
  });

  test('should flatten list of iterables', () {
    expectList(
      ImmortalList([
        [1, 2],
        [1, 2, 3],
        [4],
      ]).flattenIterables(),
      ImmortalList([1, 2, 1, 2, 3, 4]),
    );
  });

  test('should fold elements', () {
    expect(emptyList.fold(0, max), 0);
    expect(multiList.fold(0, (v1, v2) => v1 + v2), 6);
    expect(multiList.fold(0, max), 3);
  });

  test('should execute function for each element', () {
    var callCount = 0;
    var sum = 0;
    void handleValue(value) {
      callCount++;
      sum += value;
    }

    multiList.forEach(handleValue);
    expect(callCount, 3);
    expect(sum, 6);

    callCount = 0;
    sum = 0;
    emptyList.forEach(handleValue);
    expect(callCount, 0);
    expect(sum, 0);
  });

  test('should execute function for each element and its index', () {
    var callCount = 0;
    var sum = 0;
    void handleValue(index, value) {
      callCount++;
      sum += (index + 1) * value;
    }

    multiList.forEachIndexed(handleValue);
    expect(callCount, 3);
    expect(sum, 14);

    callCount = 0;
    sum = 0;
    emptyList.forEachIndexed(handleValue);
    expect(callCount, 0);
    expect(sum, 0);
  });

  test('should return range', () {
    expectList(singleList.getRange(-1, 1), singleList);
    expectList(singleList.getRange(2, 3), emptyList);
    expectList(singleList.getRange(0, 1), singleList);
    expectList(multiList.getRange(1, 3), ImmortalList([2, 3]));
    expect(multiList.getRange(0, 3), multiList);
  });

  test('should return index of element', () {
    expect(multiList.indexOf(2), 1);
    expect(multiList.indexOf(4), -1);
    expect(equalElementsList.indexOf(1), 0);
    expect(equalElementsList.indexOf(1, 1), 1);
  });

  test('should return index of element fulfilling a test', () {
    expect(multiList.indexWhere((value) => value > 2), 2);
    expect(multiList.indexWhere((value) => value > 4), -1);
    expect(multiList.indexWhere((value) => value > 0, 2), 2);
  });

  test('should return all indices of element', () {
    expectList(singleList.indicesOf(2), ImmortalList<int>());
    expectList(multiList.indicesOf(2), ImmortalList([1]));
    expectList(equalElementsList.indicesOf(1), ImmortalList([0, 1, 2]));
  });

  test('should return all indices fulfilling a test', () {
    expectList(singleList.indicesWhere((e) => e > 1), ImmortalList<int>());
    expectList(multiList.indicesWhere((e) => e > 1), ImmortalList([1, 2]));
  });

  test('should insert element at index', () {
    expectList(emptyList.insert(0, 1), singleList);
    expectList(multiList.insert(1, 2), ImmortalList([1, 2, 2, 3]));
    expectList(emptyList.insert(-1, 1), singleList);
    expectList(multiList.insert(5, 1), ImmortalList([1, 2, 3, 1]));
  });

  test('should insert list at index', () {
    expectList(emptyList.insertAll(0, multiList), multiList);
    expectList(
      multiList.insertAll(1, multiList),
      ImmortalList([1, 1, 2, 3, 2, 3]),
    );
    expectList(emptyList.insertAll(-1, multiList), multiList);
    expectList(
      multiList.insertAll(5, multiList),
      ImmortalList([1, 2, 3, 1, 2, 3]),
    );
    expect(singleList.insertAll(0, ImmortalList()), singleList);
  });

  test('should insert iterable at index', () {
    expectList(emptyList.insertIterable(0, [1, 2, 3]), multiList);
    expectList(
      multiList.insertIterable(1, [1, 2, 3]),
      ImmortalList([1, 1, 2, 3, 2, 3]),
    );
    expectList(emptyList.insertIterable(-1, [1, 2, 3]), multiList);
    expectList(
      multiList.insertIterable(5, [1, 2, 3]),
      ImmortalList([1, 2, 3, 1, 2, 3]),
    );
    expect(singleList.insertIterable(0, []), singleList);
  });

  test('should return if list is empty', () {
    expect(emptyList.isEmpty, true);
    expect(multiList.isEmpty, false);
  });

  test('should return if list is not empty', () {
    expect(emptyList.isNotEmpty, false);
    expect(multiList.isNotEmpty, true);
  });

  test('should return iterator', () {
    final iterator = multiList.iterator;
    expect(iterator.current, null);
    expect(iterator.moveNext(), true);
    expect(iterator.current, 1);
    expect(iterator.moveNext(), true);
    expect(iterator.current, 2);
    expect(iterator.moveNext(), true);
    expect(iterator.current, 3);
    expect(iterator.moveNext(), false);
  });

  test('should join elements to a string', () {
    expect(emptyList.join(), '');
    expect(multiList.join(), '123');
    expect(multiList.join(','), '1,2,3');
  });

  test('should return last element', () {
    expect(emptyList.last, Optional.empty());
    expect(singleList.last, Optional.of(1));
    expect(multiList.last, Optional.of(3));
  });

  test('should return last index of element', () {
    expect(multiList.lastIndexOf(2), 1);
    expect(multiList.lastIndexOf(4), -1);
    expect(equalElementsList.lastIndexOf(1), 2);
    expect(equalElementsList.lastIndexOf(1, 1), 1);
  });

  test('should return last index of element fulfilling test', () {
    expect(multiList.lastIndexWhere((value) => value > 1), 2);
    expect(multiList.lastIndexWhere((value) => value > 4), -1);
    expect(multiList.lastIndexWhere((value) => value > 0, 1), 1);
  });

  test('should return last element fulfilling a test', () {
    expect(multiList.lastWhere((value) => value > 4), Optional.empty());
    expect(multiList.lastWhere((value) => value > 0), Optional.of(3));
    expect(multiList.lastWhere((value) => value < 0), Optional.empty());
    expect(multiList.lastWhere((value) => value < 3), Optional.of(2));
  });

  test('should return length', () {
    expect(emptyList.length, 0);
    expect(singleList.length, 1);
    expect(multiList.length, 3);
  });

  test('should apply function to each element of the list', () {
    expectList(
      multiList.map((value) => value.toString()),
      ImmortalList(['1', '2', '3']),
    );
  });

  test('should apply function to each element of the list and its index', () {
    expectList(
      multiList.mapIndexed((index, value) => '$index-$value'),
      ImmortalList(['0-1', '1-2', '2-3']),
    );
  });

  test('should partition list', () {
    expectListTuple(
      singleList.partition((value) => value > 0),
      Tuple2(singleList, emptyList),
    );
    expectListTuple(
      multiList.partition((value) => value > 1),
      Tuple2(ImmortalList([2, 3]), singleList),
    );
  });

  test('should remove all occurrences of an element', () {
    expectList(singleList.remove(1), emptyList);
    expectList(multiList.remove(2), ImmortalList([1, 3]));
    expectList(multiList.remove(4), multiList);
    expectList(ImmortalList([1, 2, 1, 3]).remove(1), ImmortalList([2, 3]));
  });

  test('should remove all elements', () {
    expectList(singleList.removeAll(singleList), emptyList);
    expectList(multiList.removeAll(singleList), ImmortalList([2, 3]));
    expectList(
      ImmortalList([1, 2, 1, 2, 1]).removeAll(singleList),
      ImmortalList([2, 2]),
    );
    expectList(singleList - singleList, emptyList);
    expectList(multiList - singleList, ImmortalList([2, 3]));
    expectList(
      ImmortalList([1, 2, 1, 2, 1]) - singleList,
      ImmortalList([2, 2]),
    );
    expect(singleList.removeAll(ImmortalList()), singleList);
  });

  test('should remove element at index', () {
    expectList(multiList.removeAt(-1), ImmortalList([2, 3]));
    expectList(multiList.removeAt(5), ImmortalList([1, 2]));
    expectList(singleList.removeAt(0), emptyList);
    expectList(multiList.removeAt(1), ImmortalList([1, 3]));
    expect(emptyList.removeAt(0), emptyList);
  });

  test('should remove all elements from iterable', () {
    expectList(singleList.removeIterable([1]), emptyList);
    expectList(multiList.removeIterable([1]), ImmortalList([2, 3]));
    expectList(
      ImmortalList([1, 2, 1, 2, 1]).removeIterable([1]),
      ImmortalList([2, 2]),
    );
    expect(singleList.removeIterable([]), singleList);
  });

  test('should remove first occurrence of element', () {
    expectList(singleList.removeFirst(1), emptyList);
    expectList(multiList.removeFirst(2), ImmortalList([1, 3]));
    expectList(multiList.removeFirst(4), multiList);
    expectList(
      ImmortalList([1, 2, 1, 3]).removeFirst(1),
      ImmortalList([2, 1, 3]),
    );
  });

  test('should remove last element', () {
    expectList(emptyList.removeLast(), emptyList);
    expectList(singleList.removeLast(), emptyList);
    expectList(multiList.removeLast(), ImmortalList([1, 2]));
  });

  test('should remove range', () {
    expectList(multiList.removeRange(-1, 3), emptyList);
    expectList(multiList.removeRange(5, 3), multiList);
    expectList(singleList.removeRange(0, 1), emptyList);
    expectList(multiList.removeRange(1, 3), singleList);
    expect(multiList.removeRange(1, 1), multiList);
  });

  test('should remove elements fulfilling test', () {
    expectList(multiList.removeWhere((value) => value > 1), singleList);
    expectList(multiList.removeWhere((value) => value > 4), multiList);
  });

  test('should replace range', () {
    expectList(multiList.replaceRange(-1, 3, multiList), multiList);
    expectList(
      multiList.replaceRange(5, 3, multiList),
      ImmortalList([1, 2, 3, 1, 2, 3]),
    );
    expectList(singleList.replaceRange(0, 0, singleList), ImmortalList([1, 1]));
    expectList(multiList.replaceRange(0, 3, emptyList), emptyList);
    expectList(
      singleList.replaceRange(1, 1, multiList),
      ImmortalList([1, 1, 2, 3]),
    );
  });

  test('should replace range with the given iterable', () {
    expectList(multiList.replaceRangeIterable(-1, 3, [1, 2, 3]), multiList);
    expectList(
      multiList.replaceRangeIterable(5, 3, [1, 2, 3]),
      ImmortalList([1, 2, 3, 1, 2, 3]),
    );
    expectList(
      singleList.replaceRangeIterable(0, 0, [1]),
      ImmortalList([1, 1]),
    );
    expectList(multiList.replaceRangeIterable(0, 3, []), emptyList);
    expectList(
      singleList.replaceRangeIterable(1, 1, [1, 2, 3]),
      ImmortalList([1, 1, 2, 3]),
    );
  });

  test('should retain elements fulfilling a test', () {
    expectList(multiList.retainWhere((value) => value > 4), emptyList);
    expectList(multiList.retainWhere((value) => value < 2), singleList);
    expectList(multiList.retainWhere((value) => value > 0), multiList);
  });

  test('should reverse list', () {
    expectList(emptyList.reversed, emptyList);
    expectList(singleList.reversed, singleList);
    expectList(multiList.reversed, ImmortalList([3, 2, 1]));
  });

  test('should set element at index', () {
    expectList(multiList.set(-1, 4), ImmortalList([4, 2, 3]));
    expectList(multiList.set(5, 4), ImmortalList([1, 2, 4]));
    expectList(singleList.set(0, 2), ImmortalList([2]));
    expectList(multiList.set(1, 4), ImmortalList([1, 4, 3]));
    expect(emptyList.set(0, 1), emptyList);
    expectList(multiList.put(-1, 4), ImmortalList([4, 2, 3]));
    expectList(multiList.put(5, 4), ImmortalList([1, 2, 4]));
    expectList(singleList.put(0, 2), ImmortalList([2]));
    expectList(multiList.put(1, 4), ImmortalList([1, 4, 3]));
    expect(emptyList.put(0, 1), emptyList);
    expectList(multiList.replaceAt(-1, 4), ImmortalList([4, 2, 3]));
    expectList(multiList.replaceAt(5, 4), ImmortalList([1, 2, 4]));
    expectList(singleList.replaceAt(0, 2), ImmortalList([2]));
    expectList(multiList.replaceAt(1, 4), ImmortalList([1, 4, 3]));
    expect(emptyList.replaceAt(0, 1), emptyList);
  });

  test('should set elements starting at index', () {
    expect(multiList.setAll(1, emptyList), multiList);
    expectList(multiList.setAll(-1, multiList.take(2)), multiList);
    expectList(multiList.setAll(5, multiList.skip(1)), multiList);
    expectList(singleList.setAll(0, multiList.skip(1)), ImmortalList([2]));
    expectList(multiList.setAll(1, multiList), ImmortalList([1, 1, 2]));
  });

  test('should set elements to iterable starting at index', () {
    expect(multiList.setIterable(1, []), multiList);
    expectList(multiList.setIterable(-1, [1, 2]), multiList);
    expectList(multiList.setIterable(5, [2]), multiList);
    expectList(singleList.setIterable(0, [2, 3]), ImmortalList([2]));
    expectList(multiList.setIterable(1, [1, 2, 3]), ImmortalList([1, 1, 2]));
  });

  test('should set range to list', () {
    expect(multiList.setRange(1, 1, singleList), multiList);
    expect(multiList.setRange(1, 2, emptyList), multiList);
    expectList(multiList.setRange(-1, 1, multiList), multiList);
    expectList(multiList.setRange(5, 6, multiList), multiList);
    expectList(singleList.setRange(0, 1, multiList), singleList);
    expectList(multiList.setRange(1, 3, multiList), ImmortalList([1, 1, 2]));
    expectList(multiList.setRange(1, 3, singleList), ImmortalList([1, 1, 3]));
  });

  test('should set range to iterable', () {
    expect(multiList.setRangeIterable(1, 1, [1]), multiList);
    expect(multiList.setRangeIterable(1, 2, []), multiList);
    expectList(multiList.setRangeIterable(-1, 1, [1, 2, 3]), multiList);
    expectList(multiList.setRangeIterable(5, 6, [1, 2, 3]), multiList);
    expectList(singleList.setRangeIterable(0, 1, [1, 2, 3]), singleList);
    expectList(
      multiList.setRangeIterable(1, 3, [1, 2, 3]),
      ImmortalList([1, 1, 2]),
    );
    expectList(multiList.setRangeIterable(1, 3, [1]), ImmortalList([1, 1, 3]));
  });

  test('should replace elements fulfilling a test', () {
    expectList(
      multiList.setWhere((value) => value > 1, 4),
      ImmortalList([1, 4, 4]),
    );
    expectList(multiList.setWhere((value) => value < 1, 4), multiList);
    expectList(
      multiList.putWhere((value) => value > 1, 4),
      ImmortalList([1, 4, 4]),
    );
    expectList(multiList.putWhere((value) => value < 1, 4), multiList);
    expectList(
      multiList.replaceWhere((value) => value > 1, 4),
      ImmortalList([1, 4, 4]),
    );
    expectList(multiList.replaceWhere((value) => value < 1, 4), multiList);
  });

  test('should replace elements fulfilling a test by index', () {
    expectList(
      multiList.setWhereIndexed((value, index) => value + index > 1, 4),
      ImmortalList([1, 4, 4]),
    );
    expectList(
      multiList.setWhereIndexed((value, index) => value + index < 1, 4),
      multiList,
    );
    expectList(
      multiList.putWhereIndexed((value, index) => value + index > 1, 4),
      ImmortalList([1, 4, 4]),
    );
    expectList(
      multiList.putWhereIndexed((value, index) => value + index < 1, 4),
      multiList,
    );
    expectList(
      multiList.replaceWhereIndexed((value, index) => value + index > 1, 4),
      ImmortalList([1, 4, 4]),
    );
    expectList(
      multiList.replaceWhereIndexed((value, index) => value + index < 1, 4),
      multiList,
    );
  });

  test('should shuffle elements', () {
    expectList(emptyList.shuffle(), emptyList);
    expectList(singleList.shuffle(), singleList);
    final shuffledList = multiList.shuffle(Random(3));
    expectList(shuffledList, ImmortalList([1, 3, 2]));
  });

  test('should return single element', () {
    expect(emptyList.single, Optional.empty());
    expect(singleList.single, Optional.of(1));
    expect(multiList.single, Optional.empty());
  });

  test('should return single element fulfilling a test', () {
    expect(multiList.singleWhere((value) => value > 2), Optional.of(3));
    expect(multiList.singleWhere((value) => value < 0), Optional.empty());
    expect(multiList.singleWhere((value) => value > 4), Optional.empty());
  });

  test('should skip elements', () {
    expect(multiList.skip(-1), multiList);
    expect(multiList.skip(0), multiList);
    expectList(multiList.skip(5), emptyList);
    expectList(singleList.skip(1), emptyList);
    expectList(multiList.skip(1), ImmortalList([2, 3]));
  });

  test('should skip elements fulfilling test', () {
    expectList(singleList.skipWhile((value) => value > 4), singleList);
    expectList(multiList.skipWhile((value) => value < 2), ImmortalList([2, 3]));
  });

  test('should sort elements', () {
    expectList(emptyList.sort(), emptyList);
    expectList(singleList.sort(), singleList);
    expectList(ImmortalList([2, 1, 3]).sort(), multiList);
    expectList(
      multiList.sort((v1, v2) => v2.compareTo(v1)),
      ImmortalList([3, 2, 1]),
    );
  });

  test('should return sublist', () {
    expectList(multiList.sublist(-1), multiList);
    expectList(multiList.sublist(5), emptyList);
    expectList(multiList.sublist(1), ImmortalList([2, 3]));
    expectList(multiList.sublist(0, 1), singleList);
    expect(multiList.sublist(0, 3), multiList);
    expect(multiList.sublist(0), multiList);
  });

  test('should take elements', () {
    expectList(singleList.take(-1), emptyList);
    expectList(singleList.take(0), emptyList);
    expectList(singleList.take(1), singleList);
    expectList(multiList.take(2), ImmortalList([1, 2]));
    expect(multiList.take(5), multiList);
  });

  test('should take elements fulfilling test', () {
    expectList(singleList.takeWhile((value) => value > 0), singleList);
    expectList(multiList.takeWhile((value) => value < 3), ImmortalList([1, 2]));
  });

  test('should return list', () {
    expect(emptyList.toMutableList(), []);
    expect(singleList.toMutableList(), [1]);
    expect(multiList.toMutableList(), [1, 2, 3]);
  });

  test('should return immortal set', () {
    expectSet(emptyList.toSet(), ImmortalSet<int>());
    expectSet(singleList.toSet(), ImmortalSet({1}));
    expectSet(multiList.toSet(), ImmortalSet({1, 2, 3}));
    expectSet(equalElementsList.toSet(), ImmortalSet({1}));
    expectSet(ImmortalList([1, 3, 1, 2, 3]).toSet(), ImmortalSet({1, 2, 3}));
  });

  test('should convert list to string', () {
    expect(emptyList.toString(), 'Immortal[]');
    expect(singleList.toString(), 'Immortal[1]');
    expect(multiList.toString(), 'Immortal[1, 2, 3]');
  });

  test('should update element at index', () {
    int inc(v) => v + 1;
    expect(emptyList.updateAt(1, inc), emptyList);
    expectList(singleList.updateAt(0, inc), ImmortalList([2]));
    expectList(multiList.updateAt(1, inc), ImmortalList([1, 3, 3]));
  });

  test('should update elements fulfilling a test', () {
    int inc(v) => v + 1;
    expectList(
      multiList.updateWhere((value) => value > 1, inc),
      ImmortalList([1, 3, 4]),
    );
    expectList(multiList.updateWhere((value) => value < 1, inc), multiList);
  });

  test('should update elements fulfilling a test by index', () {
    int add(v, i) => v + i;
    expectList(
      multiList.updateWhereIndexed((value, index) => value + index > 1, add),
      ImmortalList([1, 3, 5]),
    );
    expectList(
      multiList.updateWhereIndexed((value, index) => value + index < 1, add),
      multiList,
    );
  });

  test('should zip lists', () {
    expectList(singleList.zip(emptyList), ImmortalList<Tuple2<int, int>>());
    expectList(
      singleList.zip(multiList.reversed),
      ImmortalList([Tuple2(1, 3)]),
    );
    expectList(
      multiList.zip(multiList.reversed),
      ImmortalList([Tuple2(1, 3), Tuple2(2, 2), Tuple2(3, 1)]),
    );
  });

  test('should zip list iterable', () {
    expectList(singleList.zipIterable([]), ImmortalList<Tuple2<int, int>>());
    expectList(singleList.zipIterable([3, 2, 1]), ImmortalList([Tuple2(1, 3)]));
    expectList(
      multiList.zipIterable([3, 2, 1]),
      ImmortalList([Tuple2(1, 3), Tuple2(2, 2), Tuple2(3, 1)]),
    );
  });
}
