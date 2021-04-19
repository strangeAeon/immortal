import 'dart:math';

import 'package:immortal/src/utils.dart';
import 'package:optional/optional.dart';
import 'package:test/test.dart';

import 'package:immortal/immortal.dart';
import 'package:tuple/tuple.dart';

import 'test_data.dart';
import 'test_utils.dart';

void main() {
  final list11 = ImmortalList([1, 1]);
  final list111 = ImmortalList([1, 1, 1]);
  final list112 = ImmortalList([1, 1, 2]);
  final list13 = ImmortalList([1, 3]);
  final list2 = ImmortalList([2]);
  final list23 = ImmortalList([2, 3]);
  final list423 = ImmortalList([4, 2, 3]);

  tearDown(() {
    // Make sure that original lists were not changed
    expectCollection(emptyList, ImmortalList<int>());
    expectCollection(list1, ImmortalList([1]));
    expectCollection(list123, ImmortalList([1, 2, 3]));
  });

  test('should create copy of list passed in constructor', () {
    final mutableList = [1, 2, 3];
    final immortalList = ImmortalList(mutableList);
    mutableList.add(4);
    expectCollection(immortalList, list123);
  });

  test('should create empty list', () {
    expectCollection(ImmortalList<int>.empty(), emptyList);
  });

  test('should create list with fill value', () {
    expectCollection(ImmortalList.filled(-1, 1), emptyList);
    expectCollection(ImmortalList.filled(1, 1), list1);
    expectCollection(ImmortalList.filled(3, 1), list111);
  });

  test('should create list from existing', () {
    expectCollection(ImmortalList.from(emptyList), emptyList);
    expectCollection(ImmortalList.from(list1), list1);
    expectCollection(ImmortalList.from(list123), list123);
    expectCollection(ImmortalList.of(emptyList), emptyList);
    expectCollection(ImmortalList.of(list1), list1);
    expectCollection(ImmortalList.of(list123), list123);
  });

  test('should create list from iterable', () {
    expectCollection(ImmortalList.fromIterable([]), emptyList);
    expectCollection(ImmortalList.fromIterable([1]), list1);
    expectCollection(ImmortalList.fromIterable([1, 2, 3]), list123);
    expectCollection(ImmortalList.ofIterable([]), emptyList);
    expectCollection(ImmortalList.ofIterable([1]), list1);
    expectCollection(ImmortalList.ofIterable([1, 2, 3]), list123);
  });

  test('should generate list', () {
    expectCollection(ImmortalList.generate(-1, inc), emptyList);
    expectCollection(ImmortalList.generate(1, inc), list1);
    expectCollection(ImmortalList.generate(3, inc), list123);
  });

  test('should return elements by index', () {
    expect(list123[-1], const Optional.empty());
    expect(list123.elementAt(-1), const Optional.empty());
    expect(list123[0], Optional.of(1));
    expect(list123.elementAt(0), Optional.of(1));
    expect(list123[1], Optional.of(2));
    expect(list123.elementAt(1), Optional.of(2));
    expect(list123[2], Optional.of(3));
    expect(list123.elementAt(2), Optional.of(3));
    expect(list123[3], const Optional.empty());
    expect(list123.elementAt(3), const Optional.empty());
    expect(emptyList[0], const Optional.empty());
    expect(emptyList.elementAt(0), const Optional.empty());
  });

  test('should add single value', () {
    expectCollection(emptyList.add(1), list1);
    expectCollection(list11.add(2), list112);
  });

  test('should add all elements', () {
    expect(emptyList.addAll(emptyList), emptyList);
    expectCollection(emptyList.addAll(list1), list1);
    expectCollection(list1.addAll(list11), list111);
  });

  test('should add value if absent', () {
    expectCollection(emptyList.addIfAbsent(1), list1);
    expect(list123.addIfAbsent(1), list123);
  });

  test('should add all elements of the given iterable', () {
    expect(emptyList.addIterable([]), emptyList);
    expectCollection(emptyList.addIterable([1]), list1);
    expectCollection(list1.addIterable([1, 1]), list111);
  });

  test('should add or replace elements fulfilling a test', () {
    expectCollection(list1.addOrPutWhere(matchingNone, 3), list13);
    expectCollection(list13.addOrPutWhere(matching(1), 2), list23);
    expectCollection(list123.addOrPutWhere(matchingAll, 1), list111);
    expectCollection(list1.addOrReplaceWhere(matchingNone, 3), list13);
    expectCollection(list13.addOrReplaceWhere(matching(1), 2), list23);
    expectCollection(list123.addOrReplaceWhere(matchingAll, 1), list111);
    expectCollection(list1.addOrSetWhere(matchingNone, 3), list13);
    expectCollection(list13.addOrSetWhere(matching(1), 2), list23);
    expectCollection(list123.addOrSetWhere(matchingAll, 1), list111);
  });

  test('should add or update element fulfilling a test', () {
    expectCollection(
      list1.addOrUpdateWhere(matchingNone, inc, yields(3)),
      list13,
    );
    expectCollection(
      list13.addOrUpdateWhere(matching(1), inc, yields(4)),
      list23,
    );
    expectCollection(
      list123.addOrUpdateWhere(matchingAll, yields1(1), yields(4)),
      list111,
    );
  });

  test('should check if any element satisfies a test', () {
    expect(list123.any(matchingAll), true);
    expect(list123.any(matching(1)), true);
    expect(list123.any(matchingNone), false);
    expect(emptyList.any(matchingAll), false);
  });

  test('should check if any element and index satisfies a test', () {
    expect(list123.anyIndexed(matchingAll), true);
    expect(list123.anyIndexed(matchingValue(1)), true);
    expect(list123.anyIndexed(matchingNone), false);
  });

  test('should transform list to immortal map', () {
    expectCollection(emptyList.asMap(), ImmortalMap<int, int>());
    expectCollection(list1.asMap(), ImmortalMap({0: 1}));
    expectCollection(list123.asMap(), ImmortalMap({0: 1, 1: 2, 2: 3}));
  });

  test('should transform list to immortal map of lists', () {
    expectCollection(
      list1.asMapOfLists(identity),
      ImmortalMap({1: list1}),
    );
    expectCollection(
      list123.asMapOfLists(isOdd),
      ImmortalMap({true: list13, false: list2}),
    );
  });

  test('should transform list to immortal map with a key function', () {
    expectCollection(list1.asMapWithKeys(identity), ImmortalMap({1: 1}));
    expectCollection(
      list123.asMapWithKeys(toString),
      ImmortalMap({'1': 1, '2': 2, '3': 3}),
    );
    expectCollection(
      list123.asMapWithKeys(isOdd),
      ImmortalMap({true: 3, false: 2}),
    );
  });

  test('should transform list to immortal map with an indexed key function',
      () {
    expectCollection(list1.asMapWithKeysIndexed(add), ImmortalMap({1: 1}));
    expectCollection(
      list123.asMapWithKeysIndexed(add),
      ImmortalMap({1: 1, 3: 2, 5: 3}),
    );
    expectCollection(
      list123.asMapWithKeysIndexed((i, v) => (v + i).isOdd),
      ImmortalMap({true: 3}),
    );
  });

  test('should cast the list', () {
    expectCollection(ImmortalList<Object>([1, 2, 3]).cast<int>(), list123);
  });

  test('should create list by casting existing', () {
    expectCollection(
      ImmortalList.castFrom(ImmortalList<Object>([1, 2, 3])),
      list123,
    );
  });

  test('should create list by casting iterable', () {
    expectCollection(
      ImmortalList.castFromIterable(<Object>[1, 2, 3]),
      list123,
    );
  });

  test('should concatenate', () {
    expect(list1 + emptyList, list1);
    expectCollection(emptyList + list1, list1);
    expectCollection(list1 + list23, list123);
    expect(list1.concatenate(emptyList), list1);
    expectCollection(emptyList.concatenate(list1), list1);
    expectCollection(list1.concatenate(list23), list123);
    expect(list1.followedBy(emptyList), list1);
    expectCollection(emptyList.followedBy(list1), list1);
    expectCollection(list1.followedBy(list23), list123);
  });

  test('should concatenate the given iterable', () {
    expect(list1.concatenateIterable([]), list1);
    expectCollection(emptyList.concatenateIterable([1]), list1);
    expectCollection(list1.concatenateIterable([2, 3]), list123);
    expect(list1.followedByIterable([]), list1);
    expectCollection(emptyList.followedByIterable([1]), list1);
    expectCollection(list1.followedByIterable([2, 3]), list123);
  });

  test('should check if an element is contained', () {
    expect(list123.contains(3), true);
    expect(list123.contains(4), false);
  });

  test('should copy list', () {
    final copy = list1.copy();
    expectCollection(copy, list1);
    expect(copy == list1, false);
  });

  test('should compare lists', () {
    expect(emptyList.equals(ImmortalList<int>()), true);
    expect(list1.equals(list123), false);
    expect(list123.equals(ImmortalList([1, 2, 3])), true);
  });

  test('should check if all elements satisfy a test', () {
    expect(emptyList.every(matchingAll), true);
    expect(list123.every(matchingAll), true);
    expect(list123.every(matching(1)), false);
    expect(list123.every(matchingNone), false);
  });

  test('should check if all elements and their indices satisfy a test', () {
    expect(emptyList.everyIndexed(matchingNone), true);
    expect(list123.everyIndexed(matchingAll), true);
    expect(list123.everyIndexed(matchingValue(1)), false);
    expect(list123.everyIndexed(matchingNone), false);
  });

  test('should expand each element to a list and flatten the result', () {
    ImmortalList<double> expansion(int i) => ImmortalList([i * 1.0, i * 2.0]);
    final expandedList1 = ImmortalList<double>([1, 2]);
    final expandedList123 = ImmortalList<double>([1, 2, 2, 4, 3, 6]);
    expectCollection(list1.expand(expansion), expandedList1);
    expectCollection(list123.expand(expansion), expandedList123);
    expectCollection(list1.flatMap(expansion), expandedList1);
    expectCollection(list123.flatMap(expansion), expandedList123);
  });

  test(
      'should expand each element and its index to a list and flatten the '
      'result', () {
    ImmortalList expansion(int index, int i) => ImmortalList([i, i * index]);
    final expandedList1 = ImmortalList([1, 0]);
    final expandedList123 = ImmortalList([1, 0, 2, 2, 3, 6]);
    expectCollection(list1.expandIndexed(expansion), expandedList1);
    expectCollection(list123.expandIndexed(expansion), expandedList123);
    expectCollection(list1.flatMapIndexed(expansion), expandedList1);
    expectCollection(list123.flatMapIndexed(expansion), expandedList123);
  });

  test('should expand each element to an iterable and flatten the result', () {
    List<double> expansion(int i) => [i * 1.0, i * 2.0];
    final expandedList1 = ImmortalList<double>([1, 2]);
    final expandedList123 = ImmortalList<double>([1, 2, 2, 4, 3, 6]);
    expectCollection(list1.expandIterable(expansion), expandedList1);
    expectCollection(list123.expandIterable(expansion), expandedList123);
    expectCollection(list1.flatMapIterable(expansion), expandedList1);
    expectCollection(list123.flatMapIterable(expansion), expandedList123);
  });

  test(
      'should expand each element and its index to an iterable and flatten the '
      'result', () {
    List expansion(int index, int i) => [i, i * index];
    final expandedList1 = ImmortalList([1, 0]);
    final expandedList123 = ImmortalList([1, 0, 2, 2, 3, 6]);
    expectCollection(list1.expandIterableIndexed(expansion), expandedList1);
    expectCollection(list123.expandIterableIndexed(expansion), expandedList123);
    expectCollection(list1.flatMapIterableIndexed(expansion), expandedList1);
    expectCollection(
      list123.flatMapIterableIndexed(expansion),
      expandedList123,
    );
  });

  test('should fill a range with a given value', () {
    expectCollection(list123.fillRange(-1, 1, 4), list423);
    expectCollection(list111.fillRange(2, 5, 2), list112);
    expect(list123.fillRange(1, 1, 4), list123);
    expectCollection(list123.fillRange(0, 2, 4), ImmortalList([4, 4, 3]));
  });

  test('should return elements fulfilling a test', () {
    expectCollection(list123.filter(not(matching(1))), list23);
    expectCollection(list123.filter(matchingNone), emptyList);
    expectCollection(list123.filter(matchingAll), list123);
    expectCollection(list123.where(not(matching(1))), list23);
    expectCollection(list123.where(matchingNone), emptyList);
    expectCollection(list123.where(matchingAll), list123);
  });

  test('should return elements that fulfill a test with their index', () {
    expectCollection(list123.filterIndexed(matchingValue(1)), list1);
    expectCollection(list123.filterIndexed(matchingNone), emptyList);
    expectCollection(list123.filterIndexed(matchingAll), list123);
    expectCollection(list123.whereIndexed(matchingValue(1)), list1);
    expectCollection(list123.whereIndexed(matchingNone), emptyList);
    expectCollection(list123.whereIndexed(matchingAll), list123);
  });

  test('should return elements of a type', () {
    final emptyStringList = ImmortalList<String>();
    expectCollection(ImmortalList([1, '1', '2']).filterType<int>(), list1);
    expectCollection(list123.filterType<String>(), emptyStringList);
    expectCollection(ImmortalList([1, '1', '2']).whereType<int>(), list1);
    expectCollection(list123.whereType<String>(), emptyStringList);
  });

  test('should return first element', () {
    expect(emptyList.first, const Optional.empty());
    expect(list1.first, Optional.of(1));
    expect(list123.first, Optional.of(1));
  });

  test('should return first element fulfilling a given test', () {
    expect(list123.firstWhere(matchingNone), const Optional.empty());
    expect(list123.firstWhere(not(matching(1))), Optional.of(2));
    expect(emptyList.firstWhere(matchingAll), const Optional.empty());
    expect(list111.firstWhere(matching(1)), Optional.of(1));
  });

  test('should flatten list of lists', () {
    expectCollection(
      ImmortalList([
        ImmortalList([1, 2]),
        ImmortalList([3, 1, 2]),
        ImmortalList([3]),
      ]).flatten(),
      ImmortalList([1, 2, 3, 1, 2, 3]),
    );
  });

  test('should flatten list of iterables', () {
    expectCollection(
      ImmortalList([
        [1, 2],
        [3, 1, 2],
        [3],
      ]).flattenIterables(),
      ImmortalList([1, 2, 3, 1, 2, 3]),
    );
  });

  test('should fold elements', () {
    expect(emptyList.fold(0, max), 0);
    expect(list123.fold(0, add), 6);
    expect(list123.fold(0, max), 3);
  });

  test('should execute function for each element', () {
    var callCount = 0;
    var sum = 0;
    void handleValue(int value) {
      callCount++;
      sum += value;
    }

    list123.forEach(handleValue);
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
    void handleValue(int index, int value) {
      callCount++;
      sum += (index + 1) * value;
    }

    list123.forEachIndexed(handleValue);
    expect(callCount, 3);
    expect(sum, 14);

    callCount = 0;
    sum = 0;
    emptyList.forEachIndexed(handleValue);
    expect(callCount, 0);
    expect(sum, 0);
  });

  test('should return range', () {
    expectCollection(list1.getRange(-1, 1), list1);
    expectCollection(list1.getRange(2, 3), emptyList);
    expectCollection(list1.getRange(0, 1), list1);
    expectCollection(list123.getRange(1, 3), list23);
    expect(list123.getRange(0, 3), list123);
  });

  test('should return index of element', () {
    expect(list123.indexOf(2), 1);
    expect(list123.indexOf(4), -1);
    expect(list111.indexOf(1), 0);
    expect(list111.indexOf(1, 1), 1);
  });

  test('should return index of element fulfilling a test', () {
    expect(list123.indexWhere(matching(1)), 0);
    expect(list123.indexWhere(matchingNone), -1);
    expect(list123.indexWhere(matchingAll, 2), 2);
  });

  test('should return all indices of element', () {
    expectCollection(list1.indicesOf(2), emptyList);
    expectCollection(list123.indicesOf(2), list1);
    expectCollection(list111.indicesOf(1), ImmortalList([0, 1, 2]));
  });

  test('should return all indices fulfilling a test', () {
    expectCollection(list1.indicesWhere(matchingNone), emptyList);
    expectCollection(list112.indicesWhere(not(matching(1))), list2);
  });

  test('should insert element at index', () {
    expectCollection(emptyList.insert(0, 1), list1);
    expectCollection(list13.insert(1, 2), list123);
    expectCollection(emptyList.insert(-1, 1), list1);
    expectCollection(list11.insert(5, 2), list112);
  });

  test('should insert list at index', () {
    expectCollection(emptyList.insertAll(0, list123), list123);
    expectCollection(list13.insertAll(1, list2), list123);
    expectCollection(emptyList.insertAll(-1, list123), list123);
    expectCollection(list1.insertAll(5, list23), list123);
    expect(list1.insertAll(0, emptyList), list1);
  });

  test('should insert iterable at index', () {
    expectCollection(emptyList.insertIterable(0, [1, 2, 3]), list123);
    expectCollection(list13.insertIterable(1, [2]), list123);
    expectCollection(emptyList.insertIterable(-1, [1, 2, 3]), list123);
    expectCollection(list11.insertIterable(5, [2]), list112);
    expect(list1.insertIterable(0, []), list1);
  });

  test('should return if list is empty', () {
    expect(emptyList.isEmpty, true);
    expect(list123.isEmpty, false);
  });

  test('should return if list is not empty', () {
    expect(emptyList.isNotEmpty, false);
    expect(list123.isNotEmpty, true);
  });

  test('should return iterator', () {
    final iterator = list123.iterator;
    expect(() => iterator.current, throwsA(TypeMatcher<TypeError>()));
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
    expect(list123.join(), '123');
    expect(list123.join(','), '1,2,3');
  });

  test('should return last element', () {
    expect(emptyList.last, const Optional.empty());
    expect(list1.last, Optional.of(1));
    expect(list123.last, Optional.of(3));
  });

  test('should return last index of element', () {
    expect(list123.lastIndexOf(2), 1);
    expect(list123.lastIndexOf(4), -1);
    expect(list111.lastIndexOf(1), 2);
    expect(list111.lastIndexOf(1, 1), 1);
  });

  test('should return last index of element fulfilling test', () {
    expect(list123.lastIndexWhere(matching(1)), 0);
    expect(list123.lastIndexWhere(matchingNone), -1);
    expect(list123.lastIndexWhere(matchingAll), 2);
    expect(list123.lastIndexWhere(not(matching(1)), 1), 1);
    expect(emptyList.lastIndexWhere(matchingAll), -1);
  });

  test('should return last element fulfilling a test', () {
    expect(emptyList.lastWhere(matchingAll), const Optional.empty());
    expect(list123.lastWhere(matchingNone), const Optional.empty());
    expect(list123.lastWhere(matchingAll), Optional.of(3));
    expect(list123.lastWhere(matching(1)), Optional.of(1));
    expect(list111.lastWhere(matching(1)), Optional.of(1));
  });

  test('should return length', () {
    expect(emptyList.length, 0);
    expect(list1.length, 1);
    expect(list123.length, 3);
  });

  test('should apply function to each element of the list', () {
    expectCollection(list123.map(toString), ImmortalList(['1', '2', '3']));
  });

  test('should apply function to each element of the list and its index', () {
    expectCollection(list123.mapIndexed(add), ImmortalList([1, 3, 5]));
  });

  test('should partition list', () {
    expectCollectionTuple(
      list1.partition(matchingAll),
      Tuple2(list1, emptyList),
    );
    expectCollectionTuple(
      list123.partition(not(matching(1))),
      Tuple2(list23, list1),
    );
  });

  test('should remove all occurrences of an element', () {
    expectCollection(list1.remove(1), emptyList);
    expectCollection(list123.remove(2), list13);
    expectCollection(list123.remove(4), list123);
    expectCollection(list111.remove(1), emptyList);
  });

  test('should remove all given elements', () {
    expectCollection(list1.removeAll(list1), emptyList);
    expectCollection(list123.removeAll(list1), list23);
    expectCollection(list111.removeAll(list1), emptyList);
    expectCollection(list1 - list1, emptyList);
    expectCollection(list123 - list1, list23);
    expectCollection(list111 - list1, emptyList);
    expect(list1.removeAll(emptyList), list1);
  });

  test('should remove element at index', () {
    expectCollection(list123.removeAt(-1), list23);
    expectCollection(list112.removeAt(5), list11);
    expectCollection(list1.removeAt(0), emptyList);
    expectCollection(list123.removeAt(1), list13);
    expect(emptyList.removeAt(0), emptyList);
  });

  test('should remove all elements from iterable', () {
    expectCollection(list1.removeIterable([1]), emptyList);
    expectCollection(list123.removeIterable([1]), list23);
    expectCollection(list111.removeIterable([1]), emptyList);
    expect(list1.removeIterable([]), list1);
  });

  test('should remove first element in list', () {
    expect(emptyList.removeFirst(), emptyList);
    expectCollection(list1.removeFirst(), emptyList);
    expectCollection(list123.removeFirst(), list23);
    expectCollection(list111.removeFirst(), list11);
  });

  test('should remove first occurrence of element', () {
    expectCollection(list1.removeFirstOccurrence(1), emptyList);
    expectCollection(list123.removeFirstOccurrence(2), list13);
    expect(list123.removeFirstOccurrence(4), list123);
    expectCollection(list111.removeFirstOccurrence(1), list11);
  });

  test('should remove last element', () {
    expect(emptyList.removeLast(), emptyList);
    expectCollection(list1.removeLast(), emptyList);
    expectCollection(list112.removeLast(), list11);
  });

  test('should remove last occurrence of element', () {
    expectCollection(list1.removeLastOccurrence(1), emptyList);
    expectCollection(list123.removeLastOccurrence(2), list13);
    expect(list123.removeLastOccurrence(4), list123);
    expectCollection(list111.removeLastOccurrence(1), list11);
  });

  test('should remove range', () {
    expectCollection(list123.removeRange(-1, 3), emptyList);
    expectCollection(list123.removeRange(5, 3), list123);
    expectCollection(list1.removeRange(0, 1), emptyList);
    expectCollection(list123.removeRange(1, 3), list1);
    expect(list123.removeRange(1, 1), list123);
  });

  test('should remove elements fulfilling test', () {
    expectCollection(list123.removeWhere(not(matching(1))), list1);
    expectCollection(list123.removeWhere(matchingNone), list123);
    expectCollection(list123.removeWhere(matchingAll), emptyList);
  });

  test('should replace range', () {
    expectCollection(list123.replaceRange(-1, 3, list123), list123);
    expectCollection(list1.replaceRange(5, 3, list23), list123);
    expectCollection(list23.replaceRange(0, 0, list1), list123);
    expectCollection(list123.replaceRange(0, 3, emptyList), emptyList);
    expectCollection(list1.replaceRange(1, 1, list23), list123);
  });

  test('should replace range with the given iterable', () {
    expectCollection(list123.replaceRangeIterable(-1, 3, [1, 2, 3]), list123);
    expectCollection(list1.replaceRangeIterable(5, 3, [2, 3]), list123);
    expectCollection(list23.replaceRangeIterable(0, 0, [1]), list123);
    expectCollection(list123.replaceRangeIterable(0, 3, []), emptyList);
    expectCollection(list1.replaceRangeIterable(1, 1, [2, 3]), list123);
  });

  test('should retain elements fulfilling a test', () {
    expectCollection(list123.retainWhere(matchingNone), emptyList);
    expectCollection(list123.retainWhere(matching(1)), list1);
    expectCollection(list123.retainWhere(matchingAll), list123);
  });

  test('should reverse list', () {
    expectCollection(emptyList.reversed, emptyList);
    expectCollection(list1.reversed, list1);
    expectCollection(list123.reversed, ImmortalList([3, 2, 1]));
  });

  test('should set element at index', () {
    expectCollection(list123.set(-1, 4), list423);
    expectCollection(list111.set(5, 2), list112);
    expectCollection(list1.set(0, 2), list2);
    expectCollection(list111.set(2, 2), list112);
    expect(emptyList.set(0, 1), emptyList);
    expectCollection(list123.put(-1, 4), list423);
    expectCollection(list111.put(5, 2), list112);
    expectCollection(list1.put(0, 2), list2);
    expectCollection(list111.put(2, 2), list112);
    expect(emptyList.put(0, 1), emptyList);
    expectCollection(list123.replaceAt(-1, 4), list423);
    expectCollection(list111.replaceAt(5, 2), list112);
    expectCollection(list1.replaceAt(0, 2), list2);
    expectCollection(list111.replaceAt(2, 2), list112);
    expect(emptyList.replaceAt(0, 1), emptyList);
  });

  test('should set elements starting at index', () {
    expect(list123.setAll(1, emptyList), list123);
    expectCollection(list423.setAll(-1, list1), list123);
    expectCollection(list123.setAll(5, list23), list123);
    expectCollection(list1.setAll(0, list23), list2);
    expectCollection(list423.setAll(0, list1), list123);
  });

  test('should set elements to iterable starting at index', () {
    expect(list123.setIterable(1, []), list123);
    expectCollection(list123.setIterable(-1, [1, 2]), list123);
    expectCollection(list123.setIterable(5, [2]), list123);
    expectCollection(list1.setIterable(0, [2, 3]), list2);
    expectCollection(list423.setIterable(0, [1]), list123);
  });

  test('should set range to list', () {
    expect(list123.setRange(1, 1, list1), list123);
    expect(list123.setRange(1, 2, emptyList), list123);
    expectCollection(list123.setRange(-1, 1, list123), list123);
    expectCollection(list123.setRange(5, 6, list123), list123);
    expectCollection(list1.setRange(0, 1, list123), list1);
    expectCollection(list123.setRange(1, 3, list123), list112);
    expectCollection(list423.setRange(0, 3, list1), list123);
  });

  test('should set range to iterable', () {
    expect(list123.setRangeIterable(1, 1, [1]), list123);
    expect(list123.setRangeIterable(1, 2, []), list123);
    expectCollection(list123.setRangeIterable(-1, 1, [1, 2, 3]), list123);
    expectCollection(list123.setRangeIterable(5, 6, [1, 2, 3]), list123);
    expectCollection(list1.setRangeIterable(0, 1, [1, 2, 3]), list1);
    expectCollection(list123.setRangeIterable(1, 3, [1, 2, 3]), list112);
    expectCollection(list423.setRangeIterable(0, 3, [1]), list123);
  });

  test('should replace elements fulfilling a test', () {
    expectCollection(list123.setWhere(matching(1), 4), list423);
    expectCollection(list123.setWhere(matchingNone, 4), list123);
    expectCollection(list123.putWhere(matching(1), 4), list423);
    expectCollection(list123.putWhere(matchingNone, 4), list123);
    expectCollection(list123.replaceWhere(matching(1), 4), list423);
    expectCollection(list123.replaceWhere(matchingNone, 4), list123);
  });

  test('should replace elements fulfilling a test by index', () {
    expectCollection(list123.setWhereIndexed(matchingValue(1), 4), list423);
    expectCollection(list123.setWhereIndexed(matchingNone, 4), list123);
    expectCollection(list123.putWhereIndexed(matchingValue(1), 4), list423);
    expectCollection(list123.putWhereIndexed(matchingNone, 4), list123);
    expectCollection(list123.replaceWhereIndexed(matchingValue(1), 4), list423);
    expectCollection(list123.replaceWhereIndexed(matchingNone, 4), list123);
  });

  test('should shuffle elements', () {
    expectCollection(emptyList.shuffle(), emptyList);
    expectCollection(list1.shuffle(), list1);
    final shuffledList = list123.shuffle(Random(3));
    expectCollection(shuffledList, ImmortalList([1, 3, 2]));
  });

  test('should return single element', () {
    expect(emptyList.single, const Optional.empty());
    expect(list1.single, Optional.of(1));
    expect(list123.single, const Optional.empty());
  });

  test('should return single element fulfilling a test', () {
    expect(list123.singleWhere(matching(1)), Optional.of(1));
    expect(list123.singleWhere(matchingNone), const Optional.empty());
    expect(list123.singleWhere(matchingAll), const Optional.empty());
  });

  test('should skip elements', () {
    expect(list123.skip(-1), list123);
    expect(list123.skip(0), list123);
    expectCollection(list123.skip(5), emptyList);
    expectCollection(list1.skip(1), emptyList);
    expectCollection(list123.skip(1), list23);
  });

  test('should skip elements fulfilling test', () {
    expectCollection(list1.skipWhile(matchingNone), list1);
    expectCollection(list123.skipWhile(matching(1)), list23);
    expectCollection(list123.skipWhile(matchingAll), emptyList);
  });

  test('should sort elements', () {
    expectCollection(emptyList.sort(), emptyList);
    expectCollection(list1.sort(), list1);
    expectCollection(ImmortalList([2, 1, 3]).sort(), list123);
    expectCollection(
      list123.sort((v1, v2) => v2.compareTo(v1)),
      ImmortalList([3, 2, 1]),
    );
  });

  test('should return sublist', () {
    expectCollection(list123.sublist(-1), list123);
    expectCollection(list123.sublist(5), emptyList);
    expectCollection(list123.sublist(1), list23);
    expectCollection(list123.sublist(0, 1), list1);
    expect(list123.sublist(0, 3), list123);
    expect(list123.sublist(0), list123);
  });

  test('should take elements', () {
    expectCollection(list1.take(-1), emptyList);
    expectCollection(list1.take(0), emptyList);
    expectCollection(list1.take(1), list1);
    expectCollection(list111.take(2), list11);
    expect(list123.take(5), list123);
  });

  test('should take elements fulfilling test', () {
    expectCollection(list123.takeWhile(matchingAll), list123);
    expectCollection(list123.takeWhile(matching(1)), list1);
    expectCollection(list123.takeWhile(matchingNone), emptyList);
  });

  test('should return list', () {
    expect(emptyList.toMutableList(), []);
    expect(list1.toMutableList(), [1]);
    expect(list123.toMutableList(), [1, 2, 3]);
  });

  test('should return immortal set', () {
    expectCollection(emptyList.toSet(), emptySet);
    expectCollection(list1.toSet(), set1);
    expectCollection(list123.toSet(), set123);
    expectCollection(list111.toSet(), set1);
  });

  test('should convert list to string', () {
    expect(emptyList.toString(), 'Immortal[]');
    expect(list1.toString(), 'Immortal[1]');
    expect(list123.toString(), 'Immortal[1, 2, 3]');
  });

  test('should update element at index', () {
    expect(emptyList.updateAt(1, inc), emptyList);
    expectCollection(list1.updateAt(0, inc), list2);
    expectCollection(list111.updateAt(2, inc), list112);
  });

  test('should update elements fulfilling a test', () {
    expectCollection(
      list112.updateWhere(not(matching(1)), inc),
      ImmortalList([1, 1, 3]),
    );
    expectCollection(list123.updateWhere(matchingNone, inc), list123);
  });

  test('should update elements fulfilling a test by index', () {
    expectCollection(
      list123.updateWhereIndexed(matchingValue(1), multiply),
      ImmortalList([0, 2, 3]),
    );
    expectCollection(list123.updateWhereIndexed(matchingNone, add), list123);
  });

  test('should zip lists', () {
    expectCollection(
      list1.zip(emptyList),
      ImmortalList<Tuple2<int, int>>(),
    );
    expectCollection(
      list1.zip(list123.reversed),
      ImmortalList([const Tuple2(1, 3)]),
    );
    expectCollection(
      list123.zip(list123.reversed),
      ImmortalList([
        const Tuple2(1, 3),
        const Tuple2(2, 2),
        const Tuple2(3, 1),
      ]),
    );
  });

  test('should zip list iterable', () {
    expectCollection(
      list1.zipIterable([]),
      ImmortalList<Tuple2<int, int>>(),
    );
    expectCollection(
      list1.zipIterable([3, 2, 1]),
      ImmortalList([const Tuple2(1, 3)]),
    );
    expectCollection(
      list123.zipIterable([3, 2, 1]),
      ImmortalList([
        const Tuple2(1, 3),
        const Tuple2(2, 2),
        const Tuple2(3, 1),
      ]),
    );
  });
}
