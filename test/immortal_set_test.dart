import 'dart:math';

import 'package:optional/optional.dart';
import 'package:test/test.dart';

import 'package:immortal/immortal.dart';
import 'package:tuple/tuple.dart';

void main() {
  final emptySet = ImmortalSet<int>();
  final singleSet = ImmortalSet({1});
  final multiSet = ImmortalSet({1, 2, 3});

  void expectSet<T>(ImmortalSet<T> actual, ImmortalSet<T> expected) {
    expect(actual.equals(expected), true);
  }

  void expectList<T>(ImmortalList<T> actual, ImmortalList<T> expected) {
    expect(actual.equals(expected), true);
  }

  void expectSetTuple<T1, T2>(
    Tuple2<ImmortalSet<T1>, ImmortalSet<T2>> actual,
    Tuple2<ImmortalSet<T1>, ImmortalSet<T2>> expected,
  ) {
    expectSet(actual.item1, expected.item1);
    expectSet(actual.item2, expected.item2);
  }

  tearDown(() {
    // Make sure that original sets were not changed
    expectSet(emptySet, ImmortalSet<int>());
    expectSet(singleSet, ImmortalSet({1}));
    expectSet(multiSet, ImmortalSet({1, 2, 3}));
  });

  test('should create copy of set passed in constructor', () {
    final mutableSet = {1, 2, 3};
    final immortalSet = ImmortalSet(mutableSet);
    mutableSet.add(4);
    expectSet(immortalSet, multiSet);
  });

  test('should create empty set', () {
    expectSet(ImmortalSet<int>.empty(), emptySet);
  });

  test('should create set from existing', () {
    expectSet(ImmortalSet.from(emptySet), emptySet);
    expectSet(ImmortalSet.from(singleSet), singleSet);
    expectSet(ImmortalSet.from(multiSet), multiSet);
    expectSet(ImmortalSet.of(emptySet), emptySet);
    expectSet(ImmortalSet.of(singleSet), singleSet);
    expectSet(ImmortalSet.of(multiSet), multiSet);
  });

  test('should create set from iterable', () {
    expectSet(ImmortalSet.fromIterable([]), emptySet);
    expectSet(ImmortalSet.fromIterable([1]), singleSet);
    expectSet(ImmortalSet.fromIterable([1, 2, 3]), multiSet);
    expectSet(ImmortalSet.ofIterable([]), emptySet);
    expectSet(ImmortalSet.ofIterable([1]), singleSet);
    expectSet(ImmortalSet.ofIterable([1, 2, 3]), multiSet);
  });

  test('should add single value', () {
    expectSet(emptySet.add(1), singleSet);
    expect(singleSet.add(1), singleSet);
    expectSet(multiSet.add(4), ImmortalSet({1, 2, 3, 4}));
  });

  test('should add all elements', () {
    expectSet(emptySet.addAll(singleSet), singleSet);
    expectSet(
      multiSet.addAll(ImmortalSet({3, 4, 5})),
      ImmortalSet({1, 2, 3, 4, 5}),
    );
    expect(singleSet.addAll(emptySet), singleSet);
  });

  test('should add all elements of the given iterable', () {
    expectSet(emptySet.addIterable({1}), singleSet);
    expectSet(
      multiSet.addIterable({3, 4, 5}),
      ImmortalSet({1, 2, 3, 4, 5}),
    );
    expect(singleSet.addIterable([]), singleSet);
  });

  test('should check if any element satisfies a test', () {
    expect(multiSet.any((value) => value < 3), true);
    expect(multiSet.any((value) => value > 3), false);
  });

  test('should cast the set', () {
    expectSet(ImmortalSet<Object>({1, 2, 3}).cast<int>(), multiSet);
  });

  test('should create set by casting existing', () {
    expectSet(ImmortalSet.castFrom(ImmortalSet<Object>({1, 2, 3})), multiSet);
  });

  test('should create set by casting iterable', () {
    expectSet(ImmortalSet.castFromIterable(<Object>[1, 2, 3]), multiSet);
  });

  test('should check if an element is contained', () {
    expect(multiSet.contains(3), true);
    expect(multiSet.contains(4), false);
  });

  test('should check if all elements are contained', () {
    expect(multiSet.containsAll(ImmortalSet({1, 3})), true);
    expect(multiSet.containsAll(ImmortalSet({3, 4})), false);
  });

  test('should check if all elements of the given iterable are contained', () {
    expect(multiSet.containsIterable({1, 3}), true);
    expect(multiSet.containsIterable({3, 4}), false);
  });

  test('should copy set', () {
    final copy = singleSet.copy();
    expectSet(copy, singleSet);
    expect(copy == singleSet, false);
  });

  test('should calculate difference', () {
    expectSet(emptySet.difference(singleSet), emptySet);
    expect(singleSet.difference(emptySet), singleSet);
    expectSet(multiSet.difference(ImmortalSet({1, 3, 4})), ImmortalSet({2}));
    expectSet(emptySet - singleSet, emptySet);
    expect(singleSet - emptySet, singleSet);
    expectSet(multiSet - ImmortalSet({1, 3, 4}), ImmortalSet({2}));
  });

  test('should calculate difference with the given mortal set', () {
    expectSet(emptySet.differenceWithSet(singleSet.toMutableSet()), emptySet);
    expect(singleSet.differenceWithSet({}), singleSet);
    expectSet(multiSet.differenceWithSet({1, 3, 4}), ImmortalSet({2}));
  });

  test('should compare sets', () {
    expect(emptySet.equals(ImmortalSet<int>()), true);
    expect(singleSet.equals(multiSet), false);
    expect(multiSet.equals(ImmortalSet([1, 2, 3])), true);
  });

  test('should check if every element satisfies a test', () {
    expect(emptySet.every((value) => value < 4), true);
    expect(multiSet.every((value) => value < 4), true);
    expect(multiSet.every((value) => value > 2), false);
  });

  test('should expand each element to an immortal set and flatten the result',
      () {
    expectSet(
      singleSet.expand((i) => ImmortalSet({i, i * 1.0})),
      ImmortalSet({1.0}),
    );
    expectSet(
      multiSet.expand((i) => ImmortalSet({i, i * 2})),
      ImmortalSet({1, 2, 4, 3, 6}),
    );
    expectSet(
      singleSet.flatMap((i) => ImmortalSet({i, i * 1.0})),
      ImmortalSet({1.0}),
    );
    expectSet(
      multiSet.flatMap((i) => ImmortalSet({i, i * 2})),
      ImmortalSet({1, 2, 4, 3, 6}),
    );
  });

  test('should expand each element to an iterable and flatten the result', () {
    expectSet(
      singleSet.expandIterable((i) => {i, i * 1.0}),
      ImmortalSet({1.0}),
    );
    expectSet(
      multiSet.expandIterable((i) => {i, i * 2}),
      ImmortalSet({1, 2, 4, 3, 6}),
    );
    expectSet(
      singleSet.flatMapIterable((i) => {i, i * 1.0}),
      ImmortalSet({1.0}),
    );
    expectSet(
      multiSet.flatMapIterable((i) => {i, i * 2}),
      ImmortalSet({1, 2, 4, 3, 6}),
    );
  });

  test('should return elements fulfilling a test', () {
    expectSet(multiSet.filter((value) => value > 1), ImmortalSet({2, 3}));
    expectSet(multiSet.filter((value) => value > 4), emptySet);
    expectSet(multiSet.filter((value) => value > 0), multiSet);
    expectSet(multiSet.where((value) => value > 1), ImmortalSet({2, 3}));
    expectSet(multiSet.where((value) => value > 4), emptySet);
    expectSet(multiSet.where((value) => value > 0), multiSet);
  });

  test('should return elements of a type', () {
    expectSet(ImmortalSet({1, '1', '2'}).filterType<int>(), singleSet);
    expectSet(multiSet.filterType<String>(), ImmortalSet<String>({}));
    expectSet(ImmortalSet({1, '1', '2'}).whereType<int>(), singleSet);
    expectSet(multiSet.whereType<String>(), ImmortalSet<String>({}));
  });

  test('should flatten set of sets', () {
    expectSet(
      ImmortalSet([
        ImmortalSet([1, 2]),
        ImmortalSet([1, 2, 3]),
        ImmortalSet([4]),
      ]).flatten(),
      ImmortalSet([1, 2, 3, 4]),
    );
  });

  test('should flatten set of iterables', () {
    expectSet(
      ImmortalSet([
        [1, 2],
        [1, 2, 3],
        [4],
      ]).flattenIterables(),
      ImmortalSet([1, 2, 3, 4]),
    );
  });

  test('should flatten set of lists', () {
    expectSet(
      ImmortalSet([
        ImmortalList([1, 1, 2]),
        ImmortalList([1, 2, 2, 3]),
        ImmortalList([4]),
      ]).flattenLists(),
      ImmortalSet([1, 2, 3, 4]),
    );
  });

  test('should fold elements', () {
    expect(emptySet.fold(0, max), 0);
    expect(multiSet.fold(0, (v1, v2) => v1 + v2), 6);
    expect(multiSet.fold(0, max), 3);
  });

  test('should execute function for each element', () {
    var callCount = 0;
    var sum = 0;
    void handleValue(value) {
      callCount++;
      sum += value;
    }

    multiSet.forEach(handleValue);
    expect(callCount, 3);
    expect(sum, 6);

    callCount = 0;
    sum = 0;
    emptySet.forEach(handleValue);
    expect(callCount, 0);
    expect(sum, 0);
  });

  test('should calculate intersection', () {
    expectSet(emptySet.intersection(singleSet), emptySet);
    expectSet(
      multiSet.intersection(ImmortalSet({1, 3, 4})),
      ImmortalSet({1, 3}),
    );
    expectSet(emptySet & singleSet, emptySet);
    expectSet(
      multiSet & ImmortalSet({1, 3, 4}),
      ImmortalSet({1, 3}),
    );
  });

  test('should calculate intersection with the given mortal set', () {
    expectSet(emptySet.intersectionWithSet(singleSet.toMutableSet()), emptySet);
    expectSet(multiSet.intersectionWithSet({1, 3, 4}), ImmortalSet({1, 3}));
  });

  test('should return if list is empty', () {
    expect(emptySet.isEmpty, true);
    expect(multiSet.isEmpty, false);
  });

  test('should return if list is not empty', () {
    expect(emptySet.isNotEmpty, false);
    expect(multiSet.isNotEmpty, true);
  });

  test('should return iterator', () {
    final iterator = multiSet.iterator;
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
    expect(emptySet.join(), '');
    expect(multiSet.join(), '123');
    expect(multiSet.join(','), '1,2,3');
  });

  test('should return length', () {
    expect(emptySet.length, 0);
    expect(singleSet.length, 1);
    expect(multiSet.length, 3);
  });

  test('should lookup elements', () {
    expect(multiSet.lookup(3), Optional.of(3));
    expect(multiSet.lookup(4), Optional.empty());
  });

  test('should apply function to each element of the list', () {
    expectSet(
      multiSet.map((value) => value.toString()),
      ImmortalSet({'1', '2', '3'}),
    );
  });

  test('should partition set', () {
    expectSetTuple(
      singleSet.partition((value) => value > 0),
      Tuple2(singleSet, emptySet),
    );
    expectSetTuple(
      multiSet.partition((value) => value > 1),
      Tuple2(ImmortalSet({2, 3}), singleSet),
    );
  });

  test('should remove element', () {
    expect(emptySet.remove(1), emptySet);
    expectSet(singleSet.remove(1), emptySet);
    expectSet(multiSet.remove(2), ImmortalSet({1, 3}));
    expect(multiSet.remove(4), multiSet);
  });

  test('should remove all given elements', () {
    expectSet(emptySet.removeAll(singleSet), emptySet);
    expectSet(singleSet.removeAll(singleSet), emptySet);
    expectSet(multiSet.removeAll(ImmortalSet({2, 3})), singleSet);
    expect(multiSet.removeAll(emptySet), multiSet);
  });

  test('should remove all elements of the given iterable', () {
    expectSet(emptySet.removeIterable({1}), emptySet);
    expectSet(singleSet.removeIterable({1}), emptySet);
    expectSet(multiSet.removeIterable({2, 3}), singleSet);
    expect(multiSet.removeIterable({}), multiSet);
  });

  test('should remove elements fulfilling a test', () {
    expectSet(multiSet.removeWhere((value) => value > 1), singleSet);
    expectSet(multiSet.removeWhere((value) => value > 4), multiSet);
  });

  test('should retain all given elements', () {
    expectSet(emptySet.retainAll(singleSet), emptySet);
    expectSet(multiSet.retainAll(ImmortalSet({4})), emptySet);
    expectSet(multiSet.retainAll(singleSet), singleSet);
    expectSet(multiSet.retainAll(multiSet), multiSet);
  });

  test('should retain all elements of the given iterable', () {
    expectSet(emptySet.retainIterable({1}), emptySet);
    expectSet(multiSet.retainIterable({4}), emptySet);
    expectSet(multiSet.retainIterable({1}), singleSet);
    expectSet(multiSet.retainIterable(multiSet.toMutableSet()), multiSet);
  });

  test('should retain elements fulfilling a test', () {
    expectSet(multiSet.retainWhere((value) => value > 4), emptySet);
    expectSet(multiSet.retainWhere((value) => value < 2), singleSet);
    expectSet(multiSet.retainWhere((value) => value > 0), multiSet);
  });

  test('should return single element', () {
    expect(emptySet.single, Optional.empty());
    expect(singleSet.single, Optional.of(1));
    expect(multiSet.single, Optional.empty());
  });

  test('should return single element fulfilling a test', () {
    expect(multiSet.singleWhere((value) => value > 2), Optional.of(3));
    expect(multiSet.singleWhere((value) => value < 0), Optional.empty());
    expect(multiSet.singleWhere((value) => value > 4), Optional.empty());
  });

  test('should toggle element', () {
    expectSet(emptySet.toggle(1), singleSet);
    expectSet(singleSet.toggle(1), emptySet);
    expectSet(multiSet.toggle(1), ImmortalSet({2, 3}));
  });

  test('should return immortal list', () {
    expectList(emptySet.toList(), ImmortalList<int>());
    expectList(singleSet.toList(), ImmortalList([1]));
    expectList(multiSet.toList(), ImmortalList([1, 2, 3]));
  });

  test('should return list', () {
    expect(emptySet.toMutableList(), []);
    expect(singleSet.toMutableList(), [1]);
    expect(multiSet.toMutableList(), [1, 2, 3]);
  });

  test('should return immortal set', () {
    expect(emptySet.toMutableSet(), <int>{});
    expect(singleSet.toMutableSet(), {1});
    expect(multiSet.toMutableSet(), {1, 2, 3});
  });

  test('should convert set to string', () {
    expect(emptySet.toString(), 'Immortal{}');
    expect(singleSet.toString(), 'Immortal{1}');
    expect(multiSet.toString(), 'Immortal{1, 2, 3}');
  });

  test('should calculate union', () {
    expectSet(emptySet.union(singleSet), singleSet);
    expectSet(
      multiSet.union(ImmortalSet({1, 3, 4})),
      ImmortalSet({1, 2, 3, 4}),
    );
    expect(multiSet.union(emptySet), multiSet);
    expectSet(emptySet + singleSet, singleSet);
    expectSet(
      multiSet + ImmortalSet({1, 3, 4}),
      ImmortalSet({1, 2, 3, 4}),
    );
    expect(multiSet + emptySet, multiSet);
    expectSet(emptySet | singleSet, singleSet);
    expectSet(
      multiSet | ImmortalSet({1, 3, 4}),
      ImmortalSet({1, 2, 3, 4}),
    );
    expect(multiSet | emptySet, multiSet);
  });

  test('should calculate union with the given mortal set', () {
    expectSet(emptySet.unionWithSet(singleSet.toMutableSet()), singleSet);
    expectSet(multiSet.unionWithSet({1, 3, 4}), ImmortalSet({1, 2, 3, 4}));
    expect(multiSet.unionWithSet({}), multiSet);
  });

  test('should update elements fulfilling a test', () {
    int inc(v) => v + 1;
    expectSet(
      multiSet.updateWhere((value) => value > 1, inc),
      ImmortalSet({1, 3, 4}),
    );
    expectSet(multiSet.updateWhere((value) => value < 1, inc), multiSet);
  });
}
