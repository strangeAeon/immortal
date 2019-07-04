import 'package:optional/optional.dart';

import '../immortal.dart';

/// An immutable collection of objects in which each object can occur only once
/// according to the `==` operator.
///
/// Operations on this set never modify the original instance but instead return
/// new instances created from mutable sets where the operations are applied to.
///
/// Internally a [LinkedHashSet] is used, regardless of what type of set is
/// passed to the constructor.
class ImmortalSet<T> {
  /// Creates an [ImmortalSet] that contains all elements of [iterable].
  ///
  /// All the elements of [iterable] should be instances of [T].
  /// The [iterable] itself can have any type.
  ///
  /// The set considers elements that are equal (using the `==` operator) to be
  /// indistinguishable and requires them to have a compatible `hashCode`
  /// implementation.
  /// It is allowed although not advised to use `null` as value.
  ImmortalSet([Iterable<T> iterable]) : _set = Set<T>.from(iterable ?? []);

  ImmortalSet._internal(this._set);

  final Set<T> _set;

  /// Returns a copy of this set where [value] is added to.
  ///
  /// If [value] (or an equal value) was already present in the set, the set is
  /// returned unchanged.
  ///
  /// Example:
  ///
  ///     var set = ImmortalSet();
  ///     final time1 = DateTime.fromMillisecondsSinceEpoch(0);
  ///     final time2 = DateTime.fromMillisecondsSinceEpoch(0);
  ///     // time1 and time2 are equal, but not identical.
  ///     expect(time1, time2);
  ///     expect(identical(time1, time2), false);
  ///     set = set.add(time1);
  ///     // A value equal to time2 exists already in the set, and the call to
  ///     // add does not expand the copy even further.
  ///     set = set.add(time2);
  ///     expect(set.length, 1);
  ///     expect(set.contains(time1), true);
  ///     expect(set.contains(time2), true);
  ImmortalSet<T> add(T value) {
    final newSet = toMutableSet();
    if (newSet.add(value)) {
      return ImmortalSet._internal(newSet);
    }
    return this;
  }

  /// Returns a copy of this set where all elements of [other] are added.
  ///
  /// If [other] is empty, the set is returned unchanged.
  ImmortalSet<T> addAll(ImmortalSet<T> other) =>
      addIterable(other.toMutableSet());

  /// Returns a copy of this set where all elements of [elements] are added.
  ///
  /// See [addAll].
  /// It iterates over [elements], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> addIterable(Iterable<T> elements) {
    if (elements.isEmpty) {
      return this;
    }
    return ImmortalSet._internal(toMutableSet()..addAll(elements));
  }

  /// Checks whether any element of this set satisfies the given [predicate].
  ///
  /// Returns `true` if any element makes [predicate] return `true`, otherwise
  /// returns false.
  bool any(bool Function(T element) predicate) => _set.any(predicate);

  /// Returns a copy of this set casting all elements to instances of [R].
  ///
  /// If this set contains only instances of [R], the new set will be created
  /// correctly, otherwise an exception will be thrown.
  ImmortalSet<R> cast<R>() => ImmortalSet(_set.cast<R>());

  /// Returns `true` if [value] is in the set according to the `==` operator.
  bool contains(Object value) => _set.contains(value);

  /// Returns whether this set contains all the elements of [other].
  bool containsAll(ImmortalSet<Object> other) =>
      containsIterable(other.toMutableSet());

  /// Returns whether this set contains all the elements of the iterable
  /// [other].
  ///
  /// See [containsAll].
  /// It iterates over [other], which must therefore not change during the
  /// iteration.
  bool containsIterable(Iterable<Object> other) => _set.containsAll(other);

  /// Returns a copy of this set.
  ImmortalSet<T> copy() => ImmortalSet(_set);

  /// Returns a new set with the elements of this set that are not in [other].
  ///
  /// That is, the returned set contains all the elements of this set that are
  /// not elements of [other] according to `other.contains`.
  ///
  /// If [other] is empty, the set is returned unchanged.
  ImmortalSet<T> difference(ImmortalSet<Object> other) =>
      differenceWithSet(other.toMutableSet());

  /// Returns a new set with the elements of this set that are not in the set
  /// [other].
  ///
  /// See [difference].
  /// It iterates over [other], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> differenceWithSet(Set<Object> other) {
    if (other.isEmpty) {
      return this;
    }
    return ImmortalSet(_set.difference(other));
  }

  /// Checks whether every element of this set satisfies the given [predicate].
  ///
  /// Returns `false` if any element makes [predicate] return `false`, otherwise
  /// returns `true`.
  bool every(bool Function(T element) predicate) => _set.every(predicate);

  /// Returns a new set expanding each element of this set into a set of zero or
  /// more elements.
  ///
  /// Example:
  ///
  ///     final pairs = ImmortalSet({
  ///       ImmortalSet({1, 2}),
  ///       ImmortalSet({3, 4}),
  ///     });
  ///     final flattened = pairs.flatMap((pair) => pair);
  ///     print(flattened); // => Immortal{1, 2, 3, 4};
  ///
  ///     final input = ImmortalSet({1, 2, 3});
  ///     final timesTwo = input.flatMap((i) => ImmortalSet({i, i * 2}));
  ///     print(timesTwo); // => Immortal{1, 2, 4, 3, 6};
  ImmortalSet<R> expand<R>(ImmortalSet<R> Function(T element) f) =>
      expandIterable((element) => f(element).toMutableSet());

  /// Returns a new set expanding each element of this set into an iterable of
  /// zero or more elements.
  ///
  /// See [expand].
  /// The iterables returnd by [f] are iterated over and must therefore not
  /// change during the iteration.
  ImmortalSet<R> expandIterable<R>(Iterable<R> Function(T element) f) =>
      ImmortalSet(_set.expand(f));

  /// Returns a new set with all elements of this set that satisfy the given
  /// [predicate].
  ///
  /// See [where].
  ImmortalSet<T> filter(bool Function(T element) predicate) => where(predicate);

  /// Returns a new set with all elements of this set that have type [R].
  ///
  /// See [whereType].
  ImmortalSet<R> filterType<R>() => whereType<R>();

  /// Returns a new set expanding each element of this set into a set of zero or
  /// more elements.
  ///
  /// See [expand].
  ImmortalSet<R> flatMap<R>(ImmortalSet<R> Function(T element) f) => expand(f);

  /// Returns a new set expanding each element of this set into an iterable of
  /// zero or more elements.
  ///
  /// See [expand].
  /// The iterables returnd by [f] are iterated over and must therefore not
  /// change during the iteration.
  ImmortalSet<R> flatMapIterable<R>(Iterable<R> Function(T element) f) =>
      expandIterable(f);

  /// Reduces the set to a single value by iteratively combining each element of
  /// this set with an existing value.
  ///
  /// Uses [initialValue] as the initial value,
  /// then iterates through the elements and updates the value with
  /// each element using the [combine] function, as if by:
  ///
  ///     var value = initialValue;
  ///     for (E element in this) {
  ///       value = combine(value, element);
  ///     }
  ///     return value;
  ///
  /// Example of calculating the sum of a set:
  ///
  ///     set.fold(0, (prev, element) => prev + element);
  R fold<R>(R initialValue, R Function(R previousValue, T element) combine) =>
      _set.fold(initialValue, combine);

  /// Applies the function [f] to each element of this set.
  void forEach(void Function(T element) f) => _set.forEach(f);

  /// Returns a new set which is the intersection between this set and [other].
  ///
  /// That is, the returned set contains all the elements of this set that are
  /// also elements of [other] according to `other.contains`.
  ImmortalSet<T> intersection(ImmortalSet<Object> other) =>
      intersectionWithSet(other.toMutableSet());

  /// Returns a new set which is the intersection between this set and the set
  /// [other].
  ///
  /// See [intersection].
  /// It iterates over [other], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> intersectionWithSet(Set<Object> other) =>
      ImmortalSet(_set.intersection(other));

  /// Returns `true` if there are no elements in this collection.
  bool get isEmpty => _set.isEmpty;

  /// Returns `true` if there is at least one element in this collection.
  bool get isNotEmpty => _set.isNotEmpty;

  /// Provides an iterator that iterates over the elements of this set.
  Iterator<T> get iterator => _set.iterator;

  /// Converts each element to a [String] and concatenates the strings.
  ///
  /// Iterates through elements of this set,
  /// converts each one to a [String] by calling [Object.toString],
  /// and then concatenates the strings, with the
  /// [separator] string interleaved between the elements.
  String join([String separator = '']) => _set.join(separator);

  /// Returns the number of elements in this set.
  int get length => _set.length;

  /// Returns an [Optional] containing an element equal to [object] if there is
  /// one in this set, otherwise returns [Optional.empty].
  ///
  /// Checks whether [object] is in the set, like [contains], and if so,
  /// returns the object in the set wrapped in an [Optional], otherwise returns
  /// [Optional.empty].
  ///
  /// This lookup can not distinguish between an object not being in the set or
  /// being the `null` value.
  /// The method [contains] can be used if the distinction is important.
  Optional<T> lookup(Object object) => Optional.ofNullable(_set.lookup(object));

  /// Returns a new set with elements that are created by calling [f] on each
  /// element of this set.
  ImmortalSet<R> map<R>(R Function(T e) f) => ImmortalSet(_set.map(f));

  /// Returns a copy of this set where [value] is removed from if present,
  /// otherwise the set is returned unchanged.
  ImmortalSet<T> remove(Object value) {
    final newSet = toMutableSet();
    if (newSet.remove(value)) {
      return ImmortalSet._internal(newSet);
    }
    return this;
  }

  /// Returns a copy of this set where each element in [other] is removed
  /// from.
  ///
  /// If [other] is empty, the set is returned unchanged.
  ImmortalSet<T> removeAll(ImmortalSet<Object> other) =>
      removeIterable(other.toMutableSet());

  /// Returns a copy of this set where each element in the iterable [elements]
  /// is removed from.
  ///
  /// See [removeAll].
  /// It iterates over [elements], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> removeIterable(Iterable<Object> elements) {
    if (elements.isEmpty) {
      return this;
    }
    return ImmortalSet._internal(toMutableSet()..removeAll(elements));
  }

  /// Returns a copy of this set where all values that satisfy the given
  /// [predicate] are removed from.
  ImmortalSet<T> removeWhere(bool Function(T element) predicate) =>
      ImmortalSet._internal(toMutableSet()..removeWhere(predicate));

  /// Returns a copy of this set where are all elements that are not in
  /// [other] are removed from.
  ///
  /// Checks for each element of [other] whether there is an element in this
  /// set that is equal to it (according to [contains]), and if so, the
  /// equal element in this set is retained in the copy, and elements that are
  /// not equal to any element in [other] are removed from the copy.
  ImmortalSet<T> retainAll(ImmortalSet<Object> other) =>
      retainIterable(other.toMutableSet());

  /// Returns a copy of this set where are all elements that are not in the
  /// iterable [elements] are removed from.
  ///
  /// See [retainAll].
  /// It iterates over [elements], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> retainIterable(Iterable<Object> elements) =>
      ImmortalSet._internal(toMutableSet()..retainAll(elements));

  /// Returns a copy of this set where all values that fail to satisfy the given
  /// [predicate] are removed from.
  ImmortalSet<T> retainWhere(bool Function(T element) predicate) =>
      ImmortalSet._internal(toMutableSet()..retainWhere(predicate));

  /// Returns an [Optional] containing the only element of the set if it has
  /// exactly one element, otherwise returns [Optional.empty].
  ///
  /// This lookup can not distinguish between not having exactly one element
  /// and containing only the `null` value.
  /// Methods like [length] can be used if the distinction is important.
  Optional<T> get single {
    if (length != 1) {
      return Optional.empty();
    }
    return Optional.ofNullable(_set.single);
  }

  /// Returns an [Optional] containing the only element that satisfies the given
  /// [predicate] if there is exactly one, otherwise returns [Optional.empty].
  ///
  /// Checks elements to see if `predicate(element)` returns `true`.
  /// If exactly one element satisfies [predicate], that element is returned
  /// wrapped in an [Optional].
  /// If none or more than one matching element is found, an [Optional.empty] is
  /// returned.
  ///
  /// If the `null` value satisfies the given [predicate], this lookup can not
  /// distinguish between not having exactly one element satisfying the
  /// predicate and only containing the `null` value satisfying the predicate.
  /// Methods like [contains] can be used if the distinction is important.
  Optional<T> singleWhere(bool Function(T element) predicate) =>
      Optional.ofNullable(_set.singleWhere(predicate, orElse: () => null));

  /// Returns an [ImmortalList] containing the elements of this set.
  ImmortalList<T> toList() => ImmortalList(_set.toList());

  /// Returns a mutable [List] containing the elements of this set.
  ///
  /// The list is fixed-length if [growable] is `false`.
  List<T> toMutableList({bool growable = true}) =>
      _set.toList(growable: growable);

  /// Returns a mutable [LinkedHashSet] containing the same elements as this
  /// set.
  Set<T> toMutableSet() => _set.toSet();

  @override
  String toString() => 'Immortal${_set.toString()}';

  /// Returns a new set which contains all the elements of this set and [other].
  ///
  /// That is, the returned set contains all the elements of this set and all
  /// the elements of [other].
  ///
  /// If [other] is empty, the set is returned unchanged.
  ImmortalSet<T> union(ImmortalSet<T> other) =>
      unionWithSet(other.toMutableSet());

  /// Returns a new set which contains all the elements of this set and the set
  /// [other].
  ///
  /// See [union].
  /// It iterates over [other], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> unionWithSet(Set<T> other) {
    if (other.isEmpty) {
      return this;
    }
    return ImmortalSet(_set.union(other));
  }

  /// Returns a new set with all elements of this set that satisfy the given
  /// [predicate].
  ImmortalSet<T> where(bool Function(T element) predicate) =>
      ImmortalSet(_set.where(predicate));

  /// Returns a new set with all elements of this set that have type [R].
  ImmortalSet<R> whereType<R>() => ImmortalSet(_set.whereType<R>());
}
