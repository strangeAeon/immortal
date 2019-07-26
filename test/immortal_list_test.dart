import 'dart:math';

import 'package:optional/optional.dart';
import 'package:test/test.dart';

import 'package:immortal/immortal.dart';

void main() {
  final emptyList = ImmortalList<int>();
  final singleList = ImmortalList([1]);
  final multiList = ImmortalList([1, 2, 3]);
  final equalElementsList = ImmortalList([1, 1, 1]);

  void expectList<T>(ImmortalList<T> actual, ImmortalList<T> expected) {
    expect(actual.toMutableList(), expected.toMutableList());
  }

  void expectSet<T>(ImmortalSet<T> actual, ImmortalSet<T> expected) {
    expect(actual.toMutableSet(), expected.toMutableSet());
  }

  void expectMap<K, V>(ImmortalMap<K, V> actual, ImmortalMap<K, V> expected) {
    expect(actual.toMutableMap(), expected.toMutableMap());
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

  test('should transform list to immortal map', () {
    expectMap(emptyList.asMap(), ImmortalMap<int, int>());
    expectMap(singleList.asMap(), ImmortalMap({0: 1}));
    expectMap(multiList.asMap(), ImmortalMap({0: 1, 1: 2, 2: 3}));
  });

  test('should cast the list', () {
    expectList(ImmortalList<Object>([1, 2, 3]).cast<int>(), multiList);
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

  test('should check if all elements satisfy a test', () {
    expect(emptyList.every((value) => value < 4), true);
    expect(multiList.every((value) => value < 4), true);
    expect(multiList.every((value) => value > 2), false);
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

  test('should remove element', () {
    expectList(singleList.remove(1), emptyList);
    expectList(multiList.remove(2), ImmortalList([1, 3]));
    expectList(multiList.remove(4), multiList);
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
  });

  test('should remove element at index', () {
    expectList(multiList.removeAt(-1), ImmortalList([2, 3]));
    expectList(multiList.removeAt(5), ImmortalList([1, 2]));
    expectList(singleList.removeAt(0), emptyList);
    expectList(multiList.removeAt(1), ImmortalList([1, 3]));
  });

  test('should remove all elements from iterable', () {
    expectList(singleList.removeIterable([1]), emptyList);
    expectList(multiList.removeIterable([1]), ImmortalList([2, 3]));
    expectList(
      ImmortalList([1, 2, 1, 2, 1]).removeIterable([1]),
      ImmortalList([2, 2]),
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
    expectList(multiList.put(-1, 4), ImmortalList([4, 2, 3]));
    expectList(multiList.put(5, 4), ImmortalList([1, 2, 4]));
    expectList(singleList.put(0, 2), ImmortalList([2]));
    expectList(multiList.put(1, 4), ImmortalList([1, 4, 3]));
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
    expectSet(emptyList.toSet(), ImmortalSet());
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
}
