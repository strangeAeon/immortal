import 'package:optional/optional.dart';
import 'package:tuple/tuple.dart';

import '../immortal.dart';
import 'utils.dart';

/// An immutable collection of objects in which each object can occur only once
/// according to the `==` operator.
///
/// Operations on this set never modify the original instance but instead return
/// new instances created from mutable sets where the operations are applied to.
///
/// Internally a [LinkedHashSet] is used, regardless of what type of set is
/// passed to the constructor.
class ImmortalSet<T> implements DeeplyComparable, Mergeable<ImmortalSet<T>> {
  /// Creates an [ImmortalSet] that contains all elements of [iterable].
  ///
  /// All the elements of [iterable] should be instances of [T].
  /// The [iterable] itself can have any type.
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ///
  /// The set considers elements that are equal (using the `==` operator) to be
  /// indistinguishable and requires them to have a compatible `hashCode`
  /// implementation.
  ImmortalSet([Iterable<T> iterable = const []]) : _set = Set<T>.from(iterable);

  ImmortalSet._internal(Iterable<T> iterable) : _set = iterable as Set<T>;

  /// Creates an empty [ImmortalSet].
  factory ImmortalSet.empty() => ImmortalSet<T>();

  /// Creates an [ImmortalSet] as copy of [other].
  ///
  /// See [ImmortalSet.of].
  factory ImmortalSet.from(ImmortalSet<T> other) => ImmortalSet.of(other);

  /// Creates an [ImmortalSet] that contains all elements of [iterable].
  ///
  /// See [ImmortalSet.ofIterable].
  factory ImmortalSet.fromIterable(Iterable<T> iterable) =>
      ImmortalSet(iterable);

  /// Creates an [ImmortalSet] as copy of [other].
  ///
  /// See [copy].
  factory ImmortalSet.of(ImmortalSet<T> other) => other.copy();

  /// Creates an [ImmortalSet] that contains all elements of [iterable].
  ///
  /// All the elements of [iterable] should be instances of [T].
  /// The [iterable] itself can have any type.
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ///
  /// The set considers elements that are equal (using the `==` operator) to be
  /// indistinguishable and requires them to have a compatible `hashCode`
  /// implementation.
  factory ImmortalSet.ofIterable(Iterable<T> iterable) => ImmortalSet(iterable);

  /// Returns a copy of [other] casting all elements to instances of [R].
  ///
  /// See [castFromIterable].
  static ImmortalSet<R> castFrom<T, R>(ImmortalSet<T> other) => other.cast<R>();

  /// Creates an [ImmortalSet] by casting all elements of [iterable] to
  /// instances of [R].
  ///
  /// If [iterable] contains only instances of [R], the set will be created
  /// correctly, otherwise an exception will be thrown.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  static ImmortalSet<R> castFromIterable<T, R>(Iterable<T> iterable) =>
      ImmortalSet(iterable.cast<R>());

  final Set<T> _set;

  ImmortalSet<T> _mutateAsSet(Set<T> Function(Set<T>) f) =>
      ImmortalSet._internal(f(toMutableSet()));

  ImmortalSet<T> _mutateAsSetIf(bool condition, Set<T> Function(Set<T>) f) =>
      condition ? _mutateAsSet(f) : this;

  /// Returns a new set which contains all the elements of this set and [other].
  ///
  /// See [union].
  ImmortalSet<T> operator +(ImmortalSet<T> other) => union(other);

  /// Returns a new set which contains all the elements of this set and [other].
  ///
  /// See [union].
  ImmortalSet<T> operator |(ImmortalSet<T> other) => union(other);

  /// Returns a new set with the elements of this set that are not in [other].
  ///
  /// See [difference].
  ImmortalSet<T> operator -(ImmortalSet<Object?> other) => difference(other);

  /// Returns a new set which is the intersection between this set and [other].
  ///
  /// See [intersection].
  ImmortalSet<T> operator &(ImmortalSet<Object?> other) => intersection(other);

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

  /// Returns a copy of this set where all elements of [iterable] are added.
  ///
  /// See [addAll].
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> addIterable(Iterable<T> iterable) =>
      _mutateAsSetIf(iterable.isNotEmpty, (set) => set..addAll(iterable));

  /// Returns a copy of this set where all elements of [list] are added.
  ///
  /// See [addAll].
  ImmortalSet<T> addList(ImmortalList<T> list) =>
      addIterable(list.toMutableList());

  /// Returns a copy of this set replacing each element that fulfills the given
  /// [predicate] by [value], or adds [value] to the set if no element
  /// satisfying [predicate] was found.
  ///
  /// As each element can only be present once in the set, this is equivalent
  /// to removing all elements fulfilling [predicate] and adding [value] to the
  /// set.
  ImmortalSet<T> addOrReplaceWhere(
    bool Function(T value) predicate,
    T value,
  ) =>
      any(predicate) ? replaceWhere(predicate, value) : add(value);

  /// Returns a copy of this set by applying [update] on each element that
  /// fulfills the given [predicate], or adds the result of [ifAbsent] to the
  /// set if no element satisfying [predicate] was found.
  ImmortalSet<T> addOrUpdateWhere(
    bool Function(T value) predicate,
    T Function(T value) update,
    T Function() ifAbsent,
  ) =>
      any(predicate) ? updateWhere(predicate, update) : add(ifAbsent());

  /// Checks whether any element of this set satisfies the given [predicate].
  ///
  /// Returns `true` if any element makes [predicate] return `true`, otherwise
  /// returns false.
  bool any(bool Function(T value) predicate) => _set.any(predicate);

  /// Returns an [ImmortalMap] using the given [keyGenerator].
  ///
  /// Iterates over all elements and creates the key for each element by
  /// applying [keyGenerator] to its value.
  /// If a key is already present in the map, the corresponding value is
  /// overwritten.
  ImmortalMap<K, T> asMapWithKeys<K>(K Function(T value) keyGenerator) =>
      ImmortalMap.fromEntries(toList().map(
        (value) => MapEntry(keyGenerator(value), value),
      ));

  /// Returns a copy of this set casting all elements to instances of [R].
  ///
  /// If this set contains only instances of [R], the new set will be created
  /// correctly, otherwise an exception will be thrown.
  ImmortalSet<R> cast<R>() => ImmortalSet(_set.cast<R>());

  /// Returns `true` if [element] is in the set according to the `==` operator.
  bool contains(Object? element) => _set.contains(element);

  /// Returns whether this set contains all the elements of [other].
  bool containsAll(ImmortalSet<Object?> other) =>
      containsIterable(other.toMutableSet());

  /// Returns whether this set contains all the elements of [iterable].
  ///
  /// See [containsAll].
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  bool containsIterable(Iterable<Object?> iterable) =>
      _set.containsAll(iterable);

  /// Returns a copy of this set.
  ImmortalSet<T> copy() => ImmortalSet(_set);

  /// Returns a new set with the elements of this set that are not in [other].
  ///
  /// That is, the returned set contains all the elements of this set that are
  /// not elements of [other] according to `other.contains`.
  ///
  /// If [other] is empty, the set is returned unchanged.
  ImmortalSet<T> difference(ImmortalSet<Object?> other) =>
      differenceWithSet(other.toMutableSet());

  /// Returns a new set with the elements of this set that are not in the set
  /// [other].
  ///
  /// See [difference].
  /// It iterates over [other], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> differenceWithSet(Set<Object?> other) =>
      other.isEmpty ? this : ImmortalSet._internal(_set.difference(other));

  /// Checks whether this set is equal to [other].
  ///
  /// First an identity check is performed, using [ImmortalSet.==]. If this
  /// fails, it is checked if [other] is an [ImmortalSet] and all contained
  /// values of the two sets are compared using their respective `==`
  /// operators.
  ///
  /// To solely test if two sets are identical, the operator `==` can be used.
  @override
  bool equals(dynamic other) =>
      this == other ||
      other is ImmortalSet<T> &&
          length == other.length &&
          every(other.contains);

  /// Checks whether every element of this set satisfies the given [predicate].
  ///
  /// Returns `false` if any element makes [predicate] return `false`, otherwise
  /// returns `true`.
  bool every(bool Function(T value) predicate) => _set.every(predicate);

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
  ImmortalSet<R> expand<R>(ImmortalSet<R> Function(T value) f) =>
      expandIterable((value) => f(value).toMutableSet());

  /// Returns a new set expanding each element of this set into an iterable of
  /// zero or more elements.
  ///
  /// See [expand].
  /// The iterables returnd by [f] are iterated over and must therefore not
  /// change during the iteration.
  ImmortalSet<R> expandIterable<R>(Iterable<R> Function(T value) f) =>
      ImmortalSet(_set.expand(f));

  /// Returns a new set with all elements of this set that satisfy the given
  /// [predicate].
  ///
  /// See [where].
  ImmortalSet<T> filter(bool Function(T value) predicate) => where(predicate);

  /// Returns a new set with all elements of this set that have type [R].
  ///
  /// See [whereType].
  ImmortalSet<R> filterType<R>() => whereType<R>();

  /// Returns a new set expanding each element of this set into a set of zero or
  /// more elements.
  ///
  /// See [expand].
  ImmortalSet<R> flatMap<R>(ImmortalSet<R> Function(T value) f) => expand(f);

  /// Returns a new set expanding each element of this set into an iterable of
  /// zero or more elements.
  ///
  /// See [expandIterable].
  ImmortalSet<R> flatMapIterable<R>(Iterable<R> Function(T value) f) =>
      expandIterable(f);

  /// Flattens a set of [ImmortalSet]s by combining their values to a single
  /// set.
  ///
  /// If this set contains only instances of [ImmortalSet<R>] the new set will
  /// be created correctly, otherwise an exception is thrown.
  ImmortalSet<R> flatten<R>() => cast<ImmortalSet<R>>().expand<R>(identity);

  /// Flattens a set of iterables by combining their values to a single set.
  ///
  /// If this set contains only instances of [Iterable<R>] the new set will be
  /// created correctly, otherwise an exception is thrown.
  ///
  /// See [flatten].
  /// The iterable values are iterated over and must therefore not change
  /// during the iteration.
  ImmortalSet<R> flattenIterables<R>() =>
      cast<Iterable<R>>().expandIterable<R>(identity);

  /// Flattens a set of [ImmortalList]s by combining their values to a single
  /// set.
  ///
  /// If this set contains only instances of [ImmortalList<R>] the new set will
  /// be created correctly, otherwise an exception is thrown.
  ImmortalSet<R> flattenLists<R>() =>
      cast<ImmortalList<R>>().expand<R>((value) => value.toSet());

  /// Reduces the set to a single value by iteratively combining each element of
  /// this set with an existing value.
  ///
  /// Uses [initialValue] as the initial value, then iterates through the
  /// elements and updates the value with each element using the [combine]
  /// function, as if by:
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
  R fold<R>(R initialValue, R Function(R previousResult, T value) combine) =>
      _set.fold(initialValue, combine);

  /// Applies the function [f] to each element of this set.
  void forEach(void Function(T value) f) => _set.forEach(f);

  /// Returns a new set which is the intersection between this set and [other].
  ///
  /// That is, the returned set contains all the elements of this set that are
  /// also elements of [other] according to `other.contains`.
  ImmortalSet<T> intersection(ImmortalSet<Object?> other) =>
      intersectionWithSet(other.toMutableSet());

  /// Returns a new set which is the intersection between this set and the set
  /// [other].
  ///
  /// See [intersection].
  /// It iterates over [other], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> intersectionWithSet(Set<Object?> other) =>
      ImmortalSet._internal(_set.intersection(other));

  /// Returns `true` if there are no elements in this collection.
  bool get isEmpty => _set.isEmpty;

  /// Returns `true` if there is at least one element in this collection.
  bool get isNotEmpty => _set.isNotEmpty;

  /// Provides an iterator that iterates over the elements of this set.
  Iterator<T> get iterator => _set.iterator;

  /// Converts each element to a [String] and concatenates the strings.
  ///
  /// Iterates through elements of this set, converts each one to a [String] by
  /// calling [Object.toString], and then concatenates the strings, with the
  /// [separator] string interleaved between the elements.
  String join([String separator = '']) => _set.join(separator);

  /// Returns the number of elements in this set.
  int get length => _set.length;

  /// Returns an [Optional] containing an element equal to [element] if there is
  /// one in this set, otherwise returns [Optional.empty].
  ///
  /// Checks whether [element] is in the set, like [contains], and if so,
  /// returns the object in the set wrapped in an [Optional], otherwise returns
  /// [Optional.empty].
  ///
  /// This lookup can not distinguish between an object not being in the set or
  /// being the `null` value.
  /// The method [contains] can be used if the distinction is important.
  Optional<T> lookup(Object? element) =>
      Optional.ofNullable(_set.lookup(element));

  /// Returns a new set with elements that are created by calling [f] on each
  /// element of this set.
  ImmortalSet<R> map<R>(R Function(T value) f) => ImmortalSet(_set.map(f));

  /// Returns a new set which contains all the elements of this set and [other].
  ///
  /// See [union].
  @override
  ImmortalSet<T> merge(ImmortalSet<T> other) => union(other);

  /// Returns a tuple of two new sets by splitting the set into two depending on
  /// the result of the given [predicate].
  ///
  /// The first set will contain all elements that satisfy [predicate] and the
  /// remaining elements will produce the second set.
  Tuple2<ImmortalSet<T>, ImmortalSet<T>> partition(
    bool Function(T value) predicate,
  ) =>
      Tuple2(where(predicate), removeWhere(predicate));

  /// Returns a copy of this set where [element] is removed from if present,
  /// otherwise the set is returned unchanged.
  ImmortalSet<T> remove(Object? element) {
    final newSet = toMutableSet();
    if (newSet.remove(element)) {
      return ImmortalSet._internal(newSet);
    }
    return this;
  }

  /// Returns a copy of this set where each element in [other] is removed from.
  ///
  /// If [other] is empty, the set is returned unchanged.
  ImmortalSet<T> removeAll(ImmortalSet<Object?> other) =>
      removeIterable(other.toMutableSet());

  /// Returns a copy of this set where each element in the [iterable] is
  /// removed from.
  ///
  /// See [removeAll].
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> removeIterable(Iterable<Object?> iterable) =>
      _mutateAsSetIf(iterable.isNotEmpty, (set) => set..removeAll(iterable));

  /// Returns a copy of this set where all values that satisfy the given
  /// [predicate] are removed from.
  ImmortalSet<T> removeWhere(bool Function(T value) predicate) =>
      _mutateAsSet((set) => set..removeWhere(predicate));

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] by [newValue].
  ///
  /// As each element can only be present once in the set, this is equivalent to
  /// removing all elements satisfying [predicate] and adding [newValue] if at
  /// least one element was removed.
  ImmortalSet<T> replaceWhere(
    bool Function(T value) predicate,
    T newValue,
  ) =>
      map((value) => predicate(value) ? newValue : value);

  /// Returns a copy of this set where are all elements that are not in [other]
  /// are removed from.
  ///
  /// Checks for each element of [other] whether there is an element in this set
  /// that is equal to it (according to [contains]), and if so, the equal
  /// element in this set is retained in the copy, and elements that are not
  /// equal to any element in [other] are removed from the copy.
  ImmortalSet<T> retainAll(ImmortalSet<Object?> other) =>
      retainIterable(other.toMutableSet());

  /// Returns a copy of this set where are all elements that are not in
  /// [iterable] are removed from.
  ///
  /// See [retainAll].
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalSet<T> retainIterable(Iterable<Object?> iterable) =>
      _mutateAsSet((set) => set..retainAll(iterable));

  /// Returns a copy of this set where all values that fail to satisfy the given
  /// [predicate] are removed from.
  ImmortalSet<T> retainWhere(bool Function(T value) predicate) =>
      _mutateAsSet((set) => set..retainWhere(predicate));

  /// Returns an [Optional] containing the only element of the set if it has
  /// exactly one element, otherwise returns [Optional.empty].
  ///
  /// This lookup can not distinguish between not having exactly one element and
  /// containing only the `null` value.
  /// Methods like [length] can be used if the distinction is important.
  Optional<T> get single => getValueIf(length == 1, () => _set.single);

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
  Optional<T> singleWhere(bool Function(T value) predicate) {
    try {
      return Optional.ofNullable(_set.singleWhere(predicate));
      // ignore: avoid_catching_errors
    } on Error {
      return const Optional.empty();
    }
  }

  /// Returns a copy of this set by toggling the presence of [value].
  ///
  /// If [value] is already contained, it will be removed from the resulting
  /// copy, otherwise it is added.
  ImmortalSet<T> toggle(T value) =>
      contains(value) ? remove(value) : add(value);

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
  ImmortalSet<T> unionWithSet(Set<T> other) =>
      other.isEmpty ? this : ImmortalSet._internal(_set.union(other));

  /// Returns a copy of this set by applying [update] to all elements that
  /// fulfill the given [predicate].
  ImmortalSet<T> updateWhere(
    bool Function(T value) predicate,
    T Function(T value) update,
  ) =>
      map((value) => predicate(value) ? update(value) : value);

  /// Returns a new set with all elements of this set that satisfy the given
  /// [predicate].
  ImmortalSet<T> where(bool Function(T value) predicate) =>
      ImmortalSet(_set.where(predicate));

  /// Returns a new set with all elements of this set that have type [R].
  ImmortalSet<R> whereType<R>() => ImmortalSet(_set.whereType<R>());
}
