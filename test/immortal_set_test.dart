import 'dart:math';

import 'package:immortal/src/utils.dart';
import 'package:optional/optional.dart';
import 'package:test/test.dart';

import 'package:immortal/immortal.dart';
import 'package:tuple/tuple.dart';

import 'test_data.dart';
import 'test_utils.dart';

void main() {
  final set13 = ImmortalSet({1, 3});
  final set23 = ImmortalSet({2, 3});

  tearDown(() {
    // Make sure that original sets were not changed
    expectCollection(emptySet, ImmortalSet<int>());
    expectCollection(set1, ImmortalSet({1}));
    expectCollection(set123, ImmortalSet({1, 2, 3}));
  });

  test('should create copy of set passed in constructor', () {
    final mutableSet = {1, 2, 3};
    final immortalSet = ImmortalSet(mutableSet);
    mutableSet.add(4);
    expectCollection(immortalSet, set123);
  });

  test('should create empty set', () {
    expectCollection(ImmortalSet<int>.empty(), emptySet);
  });

  test('should create set from existing', () {
    expectCollection(ImmortalSet.from(emptySet), emptySet);
    expectCollection(ImmortalSet.from(set1), set1);
    expectCollection(ImmortalSet.from(set123), set123);
    expectCollection(ImmortalSet.of(emptySet), emptySet);
    expectCollection(ImmortalSet.of(set1), set1);
    expectCollection(ImmortalSet.of(set123), set123);
  });

  test('should create set from iterable', () {
    expectCollection(ImmortalSet.fromIterable([]), emptySet);
    expectCollection(ImmortalSet.fromIterable([1]), set1);
    expectCollection(ImmortalSet.fromIterable([1, 2, 3]), set123);
    expectCollection(ImmortalSet.ofIterable([]), emptySet);
    expectCollection(ImmortalSet.ofIterable([1]), set1);
    expectCollection(ImmortalSet.ofIterable([1, 2, 3]), set123);
  });

  test('should add single value', () {
    expectCollection(emptySet.add(1), set1);
    expect(set1.add(1), set1);
    expectCollection(set23.add(1), set123);
  });

  test('should add all elements', () {
    expectCollection(emptySet.addAll(set1), set1);
    expectCollection(set23.addAll(ImmortalSet({1, 2})), set123);
    expect(set1.addAll(emptySet), set1);
  });

  test('should add all elements of the given iterable', () {
    expectCollection(emptySet.addIterable([1]), set1);
    expectCollection(set23.addIterable([1, 2]), set123);
    expect(set1.addIterable([]), set1);
  });

  test('should add all elements of the given list', () {
    expectCollection(emptySet.addList(list1), set1);
    expectCollection(set23.addList(ImmortalList([1, 2])), set123);
    expect(set1.addList(emptyList), set1);
  });

  test('should add or replace elements fulfilling a test', () {
    expectCollection(set1.addOrReplaceWhere(matchingNone, 3), set13);
    expectCollection(set13.addOrReplaceWhere(matching(1), 2), set23);
    expectCollection(set123.addOrReplaceWhere(matchingAll, 1), set1);
  });

  test('should add or update element fulfilling a test', () {
    expectCollection(
      set1.addOrUpdateWhere(matchingNone, inc, yields(3)),
      set13,
    );
    expectCollection(
      set13.addOrUpdateWhere(matching(1), inc, yields(4)),
      set23,
    );
    expectCollection(
      set123.addOrUpdateWhere(matchingAll, yields1(1), yields(4)),
      set1,
    );
  });

  test('should check if any element satisfies a test', () {
    expect(set123.any(matchingAll), true);
    expect(set123.any(matching(1)), true);
    expect(set123.any(matchingNone), false);
    expect(emptyList.any(matchingAll), false);
  });

  test('should transform set to immortal map with a key function', () {
    expectCollection(
      set123.asMapWithKeys(identity),
      ImmortalMap({1: 1, 2: 2, 3: 3}),
    );
    expectCollection(
      set123.asMapWithKeys(toString),
      ImmortalMap({'1': 1, '2': 2, '3': 3}),
    );
    expectCollection(
      set123.asMapWithKeys(isOdd),
      ImmortalMap({true: 3, false: 2}),
    );
  });

  test('should cast the set', () {
    expectCollection(ImmortalSet<Object>({1, 2, 3}).cast<int>(), set123);
  });

  test('should create set by casting existing', () {
    expectCollection(
      ImmortalSet.castFrom(ImmortalSet<Object>({1, 2, 3})),
      set123,
    );
  });

  test('should create set by casting iterable', () {
    expectCollection(ImmortalSet.castFromIterable(<Object>[1, 2, 3]), set123);
  });

  test('should check if an element is contained', () {
    expect(set123.contains(3), true);
    expect(set123.contains(4), false);
  });

  test('should check if all elements are contained', () {
    expect(set123.containsAll(set13), true);
    expect(set23.containsAll(set123), false);
  });

  test('should check if all elements of the given iterable are contained', () {
    expect(set123.containsIterable([1, 3]), true);
    expect(set123.containsIterable([3, 4]), false);
  });

  test('should copy set', () {
    final copy = set1.copy();
    expectCollection(copy, set1);
    expect(copy == set1, false);
  });

  test('should calculate difference', () {
    expectCollection(emptySet.difference(set1), emptySet);
    expect(set1.difference(emptySet), set1);
    expectCollection(set13.difference(set23), set1);
    expectCollection(emptySet - set1, emptySet);
    expect(set1 - emptySet, set1);
    expectCollection(set13 - set23, set1);
  });

  test('should calculate difference with the given mortal set', () {
    expectCollection(emptySet.differenceWithSet(set1.toMutableSet()), emptySet);
    expect(set1.differenceWithSet({}), set1);
    expectCollection(set13.differenceWithSet({2, 3}), set1);
  });

  test('should compare sets', () {
    expect(emptySet.equals(ImmortalSet<int>()), true);
    expect(set1.equals(set123), false);
    expect(set123.equals(ImmortalSet({1, 2, 3})), true);
  });

  test('should check if every element satisfies a test', () {
    expect(emptySet.every(matchingAll), true);
    expect(set123.every(matchingAll), true);
    expect(set123.every(matching(1)), false);
    expect(set123.every(matchingNone), false);
  });

  test('should expand each element to an immortal set and flatten the result',
      () {
    ImmortalSet<double> expansion(int i) => ImmortalSet({i * 1.0, i * 2.0});
    final expandedSet1 = ImmortalSet<double>({1, 2});
    final expandedSet123 = ImmortalSet<double>({1, 2, 3, 4, 6});
    expectCollection(set1.expand(expansion), expandedSet1);
    expectCollection(set123.expand(expansion), expandedSet123);
    expectCollection(set1.flatMap(expansion), expandedSet1);
    expectCollection(set123.flatMap(expansion), expandedSet123);
  });

  test('should expand each element to an iterable and flatten the result', () {
    Set<double> expansion(int i) => {i * 1.0, i * 2.0};
    final expandedSet1 = ImmortalSet<double>({1, 2});
    final expandedSet123 = ImmortalSet<double>({1, 2, 3, 4, 6});
    expectCollection(set1.expandIterable(expansion), expandedSet1);
    expectCollection(set123.expandIterable(expansion), expandedSet123);
    expectCollection(set1.flatMapIterable(expansion), expandedSet1);
    expectCollection(set123.flatMapIterable(expansion), expandedSet123);
  });

  test('should return elements fulfilling a test', () {
    expectCollection(set123.filter(not(matching(1))), set23);
    expectCollection(set123.filter(matchingNone), emptySet);
    expectCollection(set123.filter(matchingAll), set123);
    expectCollection(set123.where(not(matching(1))), set23);
    expectCollection(set123.where(matchingNone), emptySet);
    expectCollection(set123.where(matchingAll), set123);
  });

  test('should return elements of a type', () {
    expectCollection(ImmortalSet({1, '1', '2'}).filterType<int>(), set1);
    expectCollection(set123.filterType<String>(), ImmortalSet<String>({}));
    expectCollection(ImmortalSet({1, '1', '2'}).whereType<int>(), set1);
    expectCollection(set123.whereType<String>(), ImmortalSet<String>({}));
  });

  test('should flatten set of sets', () {
    expectCollection(
      ImmortalSet({
        ImmortalSet({1, 3}),
        ImmortalSet({1, 2, 3}),
        ImmortalSet({2}),
      }).flatten(),
      set123,
    );
  });

  test('should flatten set of iterables', () {
    expectCollection(
      ImmortalSet({
        [1, 3],
        [1, 2, 3],
        [2],
      }).flattenIterables(),
      set123,
    );
  });

  test('should flatten set of lists', () {
    expectCollection(
      ImmortalSet({
        ImmortalList([1, 1, 2]),
        ImmortalList([1, 2, 2, 3]),
        ImmortalList([2]),
      }).flattenLists(),
      set123,
    );
  });

  test('should fold elements', () {
    expect(emptySet.fold(0, max), 0);
    expect(set123.fold(0, add), 6);
    expect(set123.fold(0, max), 3);
  });

  test('should execute function for each element', () {
    var callCount = 0;
    var sum = 0;
    void handleValue(int value) {
      callCount++;
      sum += value;
    }

    set123.forEach(handleValue);
    expect(callCount, 3);
    expect(sum, 6);

    callCount = 0;
    sum = 0;
    emptySet.forEach(handleValue);
    expect(callCount, 0);
    expect(sum, 0);
  });

  test('should calculate intersection', () {
    final set134 = ImmortalSet({1, 3, 4});
    expectCollection(emptySet.intersection(set1), emptySet);
    expectCollection(set123.intersection(set134), set13);
    expectCollection(emptySet & set1, emptySet);
    expectCollection(set123 & set134, set13);
  });

  test('should calculate intersection with the given mortal set', () {
    expectCollection(
      emptySet.intersectionWithSet(set1.toMutableSet()),
      emptySet,
    );
    expectCollection(set123.intersectionWithSet({1, 3, 4}), set13);
  });

  test('should return if list is empty', () {
    expect(emptySet.isEmpty, true);
    expect(set123.isEmpty, false);
  });

  test('should return if list is not empty', () {
    expect(emptySet.isNotEmpty, false);
    expect(set123.isNotEmpty, true);
  });

  test('should return iterator', () {
    final iterator = set123.iterator;
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
    expect(emptySet.join(), '');
    expect(set123.join(), '123');
    expect(set123.join(','), '1,2,3');
  });

  test('should return length', () {
    expect(emptySet.length, 0);
    expect(set1.length, 1);
    expect(set123.length, 3);
  });

  test('should lookup elements', () {
    expect(set123.lookup(3), Optional.of(3));
    expect(set123.lookup(4), const Optional.empty());
  });

  test('should apply function to each element of the list', () {
    expectCollection(
      set123.map(toString),
      ImmortalSet({'1', '2', '3'}),
    );
  });

  test('should partition set', () {
    expectCollectionTuple(
      set1.partition(matchingAll),
      Tuple2(set1, emptySet),
    );
    expectCollectionTuple(
      set123.partition(not(matching(1))),
      Tuple2(set23, set1),
    );
  });

  test('should remove element', () {
    expect(emptySet.remove(1), emptySet);
    expectCollection(set1.remove(1), emptySet);
    expectCollection(set123.remove(2), set13);
    expect(set123.remove(4), set123);
  });

  test('should remove all given elements', () {
    expectCollection(emptySet.removeAll(set1), emptySet);
    expectCollection(set1.removeAll(set1), emptySet);
    expectCollection(set123.removeAll(set23), set1);
    expect(set123.removeAll(emptySet), set123);
  });

  test('should remove all elements of the given iterable', () {
    expectCollection(emptySet.removeIterable({1}), emptySet);
    expectCollection(set1.removeIterable({1}), emptySet);
    expectCollection(set123.removeIterable({2, 3}), set1);
    expect(set123.removeIterable({}), set123);
  });

  test('should remove elements fulfilling a test', () {
    expectCollection(set123.removeWhere(not(matching(1))), set1);
    expectCollection(set123.removeWhere(matchingNone), set123);
    expectCollection(set123.removeWhere(matchingAll), emptySet);
  });

  test('should replace elements fulfilling a test', () {
    expectCollection(set13.replaceWhere(matching(1), 2), set23);
    expectCollection(set123.replaceWhere(matching(1), 2), set23);
    expectCollection(set123.replaceWhere(matchingNone, 4), set123);
  });

  test('should retain all given elements', () {
    expectCollection(emptySet.retainAll(set1), emptySet);
    expectCollection(set123.retainAll(ImmortalSet({4})), emptySet);
    expectCollection(set123.retainAll(set1), set1);
    expectCollection(set123.retainAll(set123), set123);
  });

  test('should retain all elements of the given iterable', () {
    expectCollection(emptySet.retainIterable([1]), emptySet);
    expectCollection(set123.retainIterable([4]), emptySet);
    expectCollection(set123.retainIterable([1]), set1);
    expectCollection(set123.retainIterable([1, 2, 3]), set123);
  });

  test('should retain elements fulfilling a test', () {
    expectCollection(set123.retainWhere(matchingNone), emptySet);
    expectCollection(set123.retainWhere(matching(1)), set1);
    expectCollection(set123.retainWhere(matchingAll), set123);
  });

  test('should return single element', () {
    expect(emptySet.single, const Optional.empty());
    expect(set1.single, Optional.of(1));
    expect(set123.single, const Optional.empty());
  });

  test('should return single element fulfilling a test', () {
    expect(set123.singleWhere(matching(1)), Optional.of(1));
    expect(set123.singleWhere(matchingNone), const Optional.empty());
    expect(set123.singleWhere(matchingAll), const Optional.empty());
  });

  test('should toggle element', () {
    expectCollection(emptySet.toggle(1), set1);
    expectCollection(set1.toggle(1), emptySet);
    expectCollection(set123.toggle(1), set23);
  });

  test('should return immortal list', () {
    expectCollection(emptySet.toList(), emptyList);
    expectCollection(set1.toList(), list1);
    expectCollection(set123.toList(), list123);
  });

  test('should return list', () {
    expect(emptySet.toMutableList(), []);
    expect(set1.toMutableList(), [1]);
    expect(set123.toMutableList(), [1, 2, 3]);
  });

  test('should return immortal set', () {
    expect(emptySet.toMutableSet(), <int>{});
    expect(set1.toMutableSet(), {1});
    expect(set123.toMutableSet(), {1, 2, 3});
  });

  test('should convert set to string', () {
    expect(emptySet.toString(), 'Immortal{}');
    expect(set1.toString(), 'Immortal{1}');
    expect(set123.toString(), 'Immortal{1, 2, 3}');
  });

  test('should calculate union', () {
    expectCollection(emptySet.union(set1), set1);
    expectCollection(set23.union(set13), set123);
    expect(set123.union(emptySet), set123);
    expectCollection(emptySet + set1, set1);
    expectCollection(set23 + set13, set123);
    expect(set123 + emptySet, set123);
    expectCollection(emptySet | set1, set1);
    expectCollection(set23 | set13, set123);
    expect(set123 | emptySet, set123);
  });

  test('should calculate union with the given mortal set', () {
    expectCollection(emptySet.unionWithSet(set1.toMutableSet()), set1);
    expectCollection(set23.unionWithSet({1, 3}), set123);
    expect(set123.unionWithSet({}), set123);
  });

  test('should update elements fulfilling a test', () {
    expectCollection(set13.updateWhere(matching(1), inc), set23);
    expectCollection(set123.updateWhere(matchingNone, inc), set123);
  });
}
