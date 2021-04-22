import 'dart:math';

import 'package:optional/optional.dart';
import 'package:tuple/tuple.dart';

import '../immortal.dart';
import 'utils.dart';

class _Range {
  const _Range(this.start, this.end);

  final int start;
  final int end;

  bool get isEmpty => start == end;

  bool get isNotEmpty => !isEmpty;

  bool spansWholeList(int length) => start == 0 && end == length;
}

/// An immutable indexable collection of objects with a length.
///
/// Operations on this list never modify the original instance but instead
/// return new instances created from mutable lists where the operations are
/// applied to.
///
/// ImmortalLists are [Iterable]. Iteration occurs over values in index order.
///
/// Internally a fixed-length [List] is used, regardless of what type of list is
/// passed to the constructor.
class ImmortalList<T>
    implements Iterable<T>, DeeplyComparable, Mergeable<ImmortalList<T>> {
  /// Creates an [ImmortalList] that contains all elements of [iterable].
  ///
  /// The [Iterator] of [iterable] provides the order of the elements.
  ///
  /// All the elements in [iterable] should be instances of [T].
  /// The [iterable] itself may have any type.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalList([Iterable<T> iterable = const []])
      : _list = List<T>.from(
          iterable,
          growable: false,
        );

  ImmortalList._internal(Iterable<T> iterable) : _list = iterable as List<T>;

  /// Creates an empty [ImmortalList].
  factory ImmortalList.empty() => ImmortalList<T>();

  /// Creates an [ImmortalList] of the given [length] with [fillValue] at each
  /// position.
  ///
  /// Will return an empty list if [length] is negative.
  ///
  /// You can use [ImmortalList.generate] to create a list with a new object at
  /// each position.
  factory ImmortalList.filled(int length, T fillValue) =>
      ImmortalList._internal(List.filled(
        max(length, 0),
        fillValue,
        growable: false,
      ));

  /// Creates an [ImmortalList] that contains all elements of [iterable].
  ///
  /// See [new ImmortalList].
  factory ImmortalList.from(Iterable<T> iterable) => ImmortalList(iterable);

  /// Generates an [ImmortalList] of values.
  ///
  /// Creates a list with [length] positions and fills it with values created by
  /// calling [valueGenerator] for each index in the range `0` .. `length - 1`
  /// in increasing order.
  ///
  /// Will return an empty list if [length] is negative.
  factory ImmortalList.generate(
    int length,
    T Function(int index) valueGenerator,
  ) =>
      ImmortalList._internal(List.generate(
        max(length, 0),
        valueGenerator,
        growable: false,
      ));

  /// Creates an [ImmortalList] that contains all elements of [iterable].
  ///
  /// See [new ImmortalList].
  factory ImmortalList.of(Iterable<T> iterable) => ImmortalList(iterable);

  /// Creates an [ImmortalList] by casting all elements of [iterable] to
  /// instances of [R].
  ///
  /// See [cast].
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  static ImmortalList<R> castFrom<T, R>(Iterable<T> iterable) =>
      ImmortalList(iterable.cast<R>());

  final List<T> _list;

  bool _isValidIndex(int index) => index >= 0 && index < length;

  ImmortalList<T> _mutateAsList(Iterable<T> Function(List<T>) f) =>
      ImmortalList._internal(f(toList()));

  ImmortalList<T> _mutateAsListIf(
    bool condition,
    Iterable<T> Function(List<T>) f,
  ) =>
      condition ? _mutateAsList(f) : this;

  int _validIndex(int index, {int start = 0, int? end}) =>
      max(start, min(index, end ?? length - 1));

  int _validIndexOrEnd(int index, {int start = 0}) =>
      _validIndex(index, start: start, end: length);

  _Range _validRange(int start, int end) {
    final validStart = _validIndexOrEnd(start);
    final validEnd = _validIndexOrEnd(end, start: validStart);
    return _Range(validStart, validEnd);
  }

  _Range _validRangeWithOtherList(int start, int end, int otherListLength) {
    final validStart = _validIndexOrEnd(start);
    final validEnd = _validIndex(
      end,
      start: validStart,
      end: min(length, otherListLength + validStart),
    );
    return _Range(validStart, validEnd);
  }

  R _withRange<R>(int start, int end, R Function(_Range) f) =>
      f(_validRange(start, end));

  /// Returns a copy of this list concatenating [iterable].
  ///
  /// See [addAll].
  ImmortalList<T> operator +(Iterable<T> iterable) => addAll(iterable);

  /// Returns a copy of this list where all values in [iterable] are removed
  /// from if present.
  ///
  /// See [removeAll].
  ImmortalList<T> operator -(Iterable<Object?> iterable) => removeAll(iterable);

  /// Returns the [index]th element wrapped by an [Optional] if this element
  /// exists, otherwise returns [Optional.empty].
  ///
  /// See [elementAtAsOptional].
  Optional<T> operator [](int index) => elementAtAsOptional(index);

  /// Returns a copy of this list where [value] is added to the end.
  ImmortalList<T> add(T value) => _mutateAsList((list) => list..add(value));

  /// Returns a copy of this list where all elements of [iterable] are added to
  /// the end.
  ///
  /// If [iterable] is empty, the list is returned unchanged.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalList<T> addAll(Iterable<T> iterable) =>
      _mutateAsListIf(iterable.isNotEmpty, (list) => list..addAll(iterable));

  /// Returns a copy of this list where [value] is added to the end if it is
  /// not present yet.
  ///
  /// Otherwise the list is returned unchanged.
  ImmortalList<T> addIfAbsent(T value) => contains(value) ? this : add(value);

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] by [value], or adds [value] to the end of the list if no
  /// element satisfying [predicate] was found.
  ///
  /// See [addOrSetWhere].
  ImmortalList<T> addOrPutWhere(
    bool Function(T value) predicate,
    T value,
  ) =>
      addOrSetWhere(predicate, value);

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] by [value], or adds [value] to the end of the list if no
  /// element satisfying [predicate] was found.
  ///
  /// See [addOrSetWhere].
  ImmortalList<T> addOrReplaceWhere(
    bool Function(T value) predicate,
    T value,
  ) =>
      addOrSetWhere(predicate, value);

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] by [value], or adds [value] to the end of the list if no
  /// element satisfying [predicate] was found.
  ImmortalList<T> addOrSetWhere(
    bool Function(T value) predicate,
    T value,
  ) =>
      any(predicate) ? setWhere(predicate, value) : add(value);

  /// Returns a copy of this list by applying [update] on each element that
  /// fulfills the given [predicate], or adds the result of [ifAbsent] to the
  /// list if no element satisfying [predicate] was found.
  ImmortalList<T> addOrUpdateWhere(
    bool Function(T value) predicate,
    T Function(T value) update,
    T Function() ifAbsent,
  ) =>
      any(predicate) ? updateWhere(predicate, update) : add(ifAbsent());

  /// Checks whether any element of this list satisfies the given [predicate].
  ///
  /// Checks every element in iteration order, and returns `true` if any of them
  /// make [predicate] return `true`, otherwise returns `false`.
  @override
  bool any(bool Function(T value) predicate) => _list.any(predicate);

  /// Checks whether any element and its respective index satisfies the given
  /// [predicate].
  ///
  /// See [any].
  bool anyIndexed(bool Function(int index, T value) predicate) =>
      mapIndexed(predicate).any(isTrue);

  /// Returns an [ImmortalMap] using the indices of this list as keys and the
  /// corresponding objects as values.
  ///
  /// Example:
  /// ```dart
  /// final words = ImmortalList(['fee', 'fi', 'fo', 'fum']);
  /// final map = words.asMap();
  /// map[0].value + map[1].value; // 'feefi'
  /// map.keys.toList();           // [0, 1, 2, 3]
  /// ```
  ImmortalMap<int, T> asMap() => ImmortalMap(_list.asMap());

  /// Returns an [ImmortalMap] using the given [keyGenerator] and concatenating
  /// values with the same key.
  ///
  /// Iterates over all elements in iteration order and calculates the key for
  /// each element by applying [keyGenerator] to its value. The list of all
  /// values with the same key in iteration order is used as the value of the
  /// generated key in the resulting map.
  ImmortalMap<K, ImmortalList<T>> asMapOfLists<K>(
          K Function(T value) keyGenerator) =>
      fold(
        ImmortalMap<K, ImmortalList<T>>(),
        (map, value) => map.update(
          keyGenerator(value),
          (list) => list.add(value),
          ifAbsent: () => ImmortalList([value]),
        ),
      );

  /// Returns an [ImmortalMap] using the given [keyGenerator].
  ///
  /// Iterates over all elements in iteration order and creates the key for each
  /// element by applying [keyGenerator] to its value.
  /// If a key is already present in the map, the corresponding value is
  /// overwritten.
  ImmortalMap<K, T> asMapWithKeys<K>(K Function(T value) keyGenerator) =>
      ImmortalMap.fromEntries(
          map((value) => MapEntry(keyGenerator(value), value)));

  /// Returns an [ImmortalMap] generating keys by applying the given function
  /// [keyGenerator] to each value and its respective index.
  ///
  /// See [asMapWithKeys].
  ImmortalMap<K, T> asMapWithKeysIndexed<K>(
    K Function(int index, T value) keyGenerator,
  ) =>
      ImmortalMap.fromEntries(mapIndexed(
        (index, value) => MapEntry(keyGenerator(index, value), value),
      ));

  /// Returns a copy of this list casting all elements to instances of [R].
  ///
  /// If this list contains only instances of [R] the new list will be created
  /// correctly, otherwise an exception is thrown.
  @override
  ImmortalList<R> cast<R>() => ImmortalList(_list.cast<R>());

  /// Returns a copy of this list concatenating [iterable].
  ///
  /// See [addAll].
  ImmortalList<T> concatenate(Iterable<T> iterable) => addAll(iterable);

  /// Returns `true` if the list contains an element equal to [element].
  ///
  /// Equality is determined using the `==` operator.
  @override
  bool contains(Object? element) => _list.contains(element);

  /// Returns a copy of this list.
  ImmortalList<T> copy() => ImmortalList(_list);

  /// Returns the [index]th element.
  ///
  /// The [index] must be non-negative and less than [length].
  /// Index zero represents the first element (so `elementAt(0)` is equivalent
  /// to `first`).
  @override
  T elementAt(int index) => _list.elementAt(index);

  /// Returns the [index]th element wrapped by an [Optional] if this element
  /// exists, otherwise returns [Optional.empty].
  ///
  /// If the index passed is invalid, [Optional.empty] is returned as well.
  ///
  /// Index zero represents the first element (so `elementAt(0)` is equivalent
  /// to `first`).
  ///
  /// This lookup can not distinguish between handling and invalid [index] and
  /// containing the value `null` at the requested index.
  /// Methods like [contains] or [length] can be used if the distinction is
  /// important.
  Optional<T> elementAtAsOptional(int index) =>
      getValueIf(_isValidIndex(index), () => _list.elementAt(index));

  /// Checks whether this list is equal to [other].
  ///
  /// First an identity check is performed, using [operator ==]. If this fails,
  /// it is checked if [other] is an [ImmortalList] and all contained values of
  /// the two lists are compared in iteration order using their respective `==`
  /// operators.
  ///
  /// To solely test if two lists are identical, the operator `==` can be used.
  @override
  bool equals(dynamic other) =>
      this == other ||
      other is ImmortalList<T> &&
          length == other.length &&
          mapIndexed((index, value) =>
              other[index].map(equalTo(value)).orElse(false)).every(isTrue);

  /// Checks whether every element of this list satisfies the given [predicate].
  ///
  /// Returns `false` if any element makes [predicate] return `false`, otherwise
  /// returns `true`.
  @override
  bool every(bool Function(T value) predicate) => _list.every(predicate);

  /// Checks whether all elements and their respective indices satisfy the given
  /// [predicate].
  ///
  /// See [every].
  bool everyIndexed(bool Function(int index, T value) predicate) =>
      mapIndexed(predicate).every(isTrue);

  /// Returns a new list expanding each element of this list into a list of zero
  /// or more elements by applying [f] to each element and its respective index
  /// and concatenating the resulting lists.
  ///
  /// See [expand].
  ImmortalList<R> expandIndexed<R>(
    Iterable<R> Function(int index, T value) f,
  ) =>
      mapIndexed(f).expand(identity);

  /// Returns a new list expanding each element of this list into an iterable of
  /// zero or more elements.
  ///
  /// Example:
  /// ```dart
  /// final pairs = ImmortalList([
  ///   ImmortalList([1, 2]),
  ///   ImmortalList([3, 4]),
  /// ]);
  /// final flattened = pairs.flatMap((pair) => pair);
  /// print(flattened); // => Immortal[1, 2, 3, 4];
  ///
  /// final input = ImmortalList([1, 2, 3]);
  /// final duplicated = input.flatMap((i) => ImmortalList([i, i]));
  /// print(duplicated); // => Immortal[1, 1, 2, 2, 3, 3]
  /// ```
  /// The iterables returnd by [f] are iterated over and must therefore not
  /// change during the iteration.
  @override
  ImmortalList<R> expand<R>(Iterable<R> Function(T value) f) =>
      ImmortalList(_list.expand(f));

  /// Returns a copy of this list setting the objects in the range [start]
  /// inclusive to [end] exclusive to the given [fillValue].
  ///
  /// The provided range, given by [start] and [end], will be adjusted to fit
  /// inside the boundaries of the list if necessary, i.e. to fulfill
  /// `0 <= start <= end <= len`, where `len` is this list's [length].
  ///
  /// If the resulting range is empty, the list is returned unchanged.
  ///
  /// The resulting list will have the same length as the original list.
  ///
  /// Example:
  /// ```dart
  /// final list = ImmortalList([1, 2, 3]);
  /// final filledList = list.fillRange(0, 2, 4);
  /// print(filledList); //  Immortal[4, 4, 3]
  /// ```
  ImmortalList<T> fillRange(int start, int end, [T? fillValue]) => _withRange(
      start,
      end,
      (range) => _mutateAsListIf(
          range.isNotEmpty,
          (list) => list
            ..fillRange(
              range.start,
              range.end,
              fillValue,
            )));

  /// Returns a new list with all elements of this list that satisfy the given
  /// [predicate].
  ///
  /// See [where].
  ImmortalList<T> filter(bool Function(T value) predicate) => where(predicate);

  /// Returns a new list containing all elements that satisfy the given
  /// [predicate] with their respective indices.
  ///
  /// See [where].
  ImmortalList<T> filterIndexed(bool Function(int index, T value) predicate) =>
      whereIndexed(predicate);

  /// Returns a new list with all elements of this list that have type [R].
  ///
  /// See [whereType].
  ImmortalList<R> filterType<R>() => whereType<R>();

  /// Returns the first element.
  ///
  /// Throws a [StateError] if this list is empty.
  /// Otherwise returns the first element in the iteration order,
  /// equivalent to `elementAt(0)`.
  @override
  T get first => _list.first;

  /// Returns an [Optional] containing the first element of the list if the list
  /// is not empty, otherwise returns [Optional.empty].
  ///
  /// Returns the first element in the iteration order, equivalent to
  /// `elementAt(0)`.
  ///
  /// This lookup can not distinguish between the list being empty and
  /// containing the `null` value as first element.
  /// Methods like [contains] or [length] can be used if the distinction is
  /// important.
  Optional<T> get firstAsOptional => getValueIf(isNotEmpty, () => _list.first);

  /// Returns the first element that satisfies the given predicate [predicate].
  ///
  /// Iterates through elements and returns the first to satisfy [predicate].
  ///
  /// If no element satisfies [predicate], the result of invoking the [orElse]
  /// function is returned.
  /// If [orElse] is omitted, it defaults to throwing a [StateError].
  @override
  T firstWhere(bool Function(T value) predicate, {T Function()? orElse}) =>
      _list.firstWhere(predicate, orElse: orElse);

  /// Returns an [Optional] containing the first element that satisfies the
  /// given [predicate], or [Optional.empty] if none was found.
  ///
  /// Iterates through all elements and returns the first to satisfy
  /// [predicate].
  ///
  /// If no element satisfies [predicate], an [Optional.empty] is returned.
  ///
  /// If the `null` value satisfies the given [predicate], this lookup can not
  /// distinguish between not having any element satisfying the predicate and
  /// containing the `null` value satisfying the predicate.
  /// Methods like [contains] or [indexWhere] can be used if the distinction is
  /// important.
  Optional<T> firstWhereAsOptional(bool Function(T value) predicate) {
    try {
      return Optional.ofNullable(_list.firstWhere(predicate));
      // ignore: avoid_catching_errors
    } on Error {
      return const Optional.empty();
    }
  }

  /// Returns a new list expanding each element of this list into an iterable of
  /// zero or more elements.
  ///
  /// See [expand].
  ImmortalList<R> flatMap<R>(Iterable<R> Function(T value) f) => expand(f);

  /// Returns a new list expanding each element of this list into an interable
  /// of zero or more elements by applying [f] to each element and its
  /// respective index and concatenating the resulting lists.
  ///
  /// See [expand].
  ImmortalList<R> flatMapIndexed<R>(
    Iterable<R> Function(int index, T value) f,
  ) =>
      expandIndexed(f);

  /// Flattens a list of iterables by concatenating the values in iteration
  /// order.
  ///
  /// If this list contains only instances of [Iterable<R>] the new list will be
  /// created correctly, otherwise an exception is thrown.
  ///
  /// The iterables are iterated over and must therefore not change during the
  /// iteration.
  ImmortalList<R> flatten<R>() => cast<Iterable<R>>().expand<R>(identity);

  /// Reduces the list to a single value by iteratively combining each element
  /// of this list with an existing value.
  ///
  /// Uses [initialValue] as the initial value, then iterates through the
  /// elements and updates the value with each element using the [combine]
  /// function, as if by:
  /// ```dart
  /// var value = initialValue;
  /// for (E element in this) {
  ///   value = combine(value, element);
  /// }
  /// return value;
  /// ```
  /// Example of calculating the sum of a list:
  /// ```dart
  /// list.fold(0, (prev, element) => prev + element);
  /// ```
  @override
  R fold<R>(R initialValue, R Function(R previousResult, T value) combine) =>
      _list.fold(initialValue, combine);

  /// Returns a copy of this list concatenating [iterable].
  ///
  /// See [addAll].
  ImmortalList<T> followedBy(Iterable<T> iterable) => addAll(iterable);

  /// Applies the function [f] to each element of this list in iteration order.
  @override
  void forEach(void Function(T value) f) => _list.forEach(f);

  /// Applies the function [f] to each element and its index of this list in
  /// iteration order.
  ///
  /// See [forEach].
  void forEachIndexed(void Function(int index, T value) f) => mapIndexed(f);

  /// Returns a copy of this list that contains all elements in the range
  /// [start] inclusive to [end] exclusive.
  ///
  /// The provided range, given by [start] and [end], will be adjusted to fit
  /// inside the boundaries of the list if necessary, i.e. to fulfill
  /// `0 <= start <= end <= len`, where `len` is this list's [length].
  ///
  /// If the resulting range covers the whole list, it is returned unchanged.
  ///
  /// Example:
  /// ```dart
  /// final colors = ImmortalList(['red', 'green', 'blue', 'cyan', 'pink']);
  /// final range = colors.getRange(1, 4);
  /// range.join(', ');  // 'green, blue, cyan'
  /// ```
  ImmortalList<T> getRange(int start, int end) => _withRange(
      start,
      end,
      (range) => range.spansWholeList(length)
          ? this
          : ImmortalList(_list.getRange(range.start, range.end)));

  /// Returns the first index of [value] in this list.
  ///
  /// Searches the list from index [start] to the end of the list.
  /// The first time an object [:o:] is encountered so that [:o == value:], the
  /// index of [:o:] is returned.
  /// ```dart
  /// final notes = ImmortalList(['do', 're', 'mi', 're']);
  /// notes.indexOf('re');    // 1
  /// notes.indexOf('re', 2); // 3
  /// ```
  /// Returns -1 if [value] is not found.
  /// ```dart
  /// notes.indexOf('fa');    // -1
  /// ```
  int indexOf(T value, [int start = 0]) => _list.indexOf(value, start);

  /// Returns the first index in the list that satisfies the given [predicate].
  ///
  /// Searches the list from index [start] to the end of the list.
  ///
  /// The first time an object `o` is encountered so that `predicate(o)` is
  /// `true`, the index of `o` is returned.
  /// ```dart
  /// final notes = ImmortalList(['do', 're', 'mi', 're']);
  /// notes.indexWhere((note) => note.startsWith('r'));    // 1
  /// notes.indexWhere((note) => note.startsWith('r'), 2); // 3
  /// ```
  /// Returns -1 if no element fulfilling [predicate] was found.
  /// ```dart
  /// notes.indexWhere((note) => note.startsWith('k'));    // -1
  /// ```
  int indexWhere(bool Function(T value) predicate, [int start = 0]) =>
      _list.indexWhere(predicate, start);

  /// Returns all indices of [lookupValue] in this list.
  ImmortalList<int> indicesOf(T lookupValue) =>
      indicesWhere(equalTo(lookupValue));

  /// Returns all indices in the list that satisfy the given [predicate].
  ImmortalList<int> indicesWhere(bool Function(T value) predicate) =>
      mapIndexed((index, value) => predicate(value) ? index : -1)
          .where(not(equalTo(-1)));

  /// Returns a copy of this list where [value] is inserted at position [index].
  ///
  /// All objects at or after the index are shifted towards the end of the list.
  ///
  /// The provided [index] is adjusted to fit inside the boundaries of the list,
  /// i.e. to fulfill `0 <= index <= length`.
  ImmortalList<T> insert(int index, T value) => _mutateAsList(
        (list) => list..insert(_validIndexOrEnd(index), value),
      );

  /// Returns a copy of this list where all objects of [iterable] are inserted
  /// at position [index].
  ///
  /// All later objects are shifted towards the end of the list.
  ///
  /// The provided [index] is adjusted to fit inside the boundaries of the list,
  /// i.e. to fulfill `0 <= index <= length`.
  ///
  /// This returned list might be longer than the original list.
  /// The list is returned unchanged if [iterable] is empty.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalList<T> insertAll(int index, Iterable<T> iterable) => _mutateAsListIf(
        iterable.isNotEmpty,
        (list) => list..insertAll(_validIndexOrEnd(index), iterable),
      );

  /// Returns `true` if there are no elements in this list.
  @override
  bool get isEmpty => _list.isEmpty;

  /// Returns `true` if there is at least one element in this list.
  @override
  bool get isNotEmpty => _list.isNotEmpty;

  /// Returns a new `Iterator` that allows iterating the elements of this list
  /// in index order.
  ///
  /// Each time `iterator` is read, it returns a new iterator,
  /// which can be used to iterate through all the elements again.
  /// The iterators of the same list can be stepped through independently and
  /// return the same elements in the same order.
  @override
  Iterator<T> get iterator => _list.iterator;

  /// Converts each element to a [String] and concatenates the strings.
  ///
  /// Iterates through elements of this list, converts each one to a [String] by
  /// calling [Object.toString], and then concatenates the strings, with the
  /// [separator] string interleaved between the elements.
  @override
  String join([String separator = '']) => _list.join(separator);

  /// Returns the last element.
  ///
  /// Throws a [StateError] if this list is empty.
  /// Otherwise returns the last element in the iteration order,
  /// equivalent to `elementAt(length - 1)`.
  @override
  T get last => _list.last;

  /// Returns an [Optional] containing the last element of the list if the list
  /// is not empty, otherwise returns [Optional.empty].
  ///
  /// Returns the last element in the iteration order.
  ///
  /// This lookup can not distinguish between the list being empty and
  /// containing the `null` value as last element.
  /// Methods like [contains] or [length] can be used if the distinction is
  /// important.
  Optional<T> get lastAsOptional => getValueIf(isNotEmpty, () => _list.last);

  /// Returns the last index of [value] in this list.
  ///
  /// Searches the list backwards from index [start] to 0.
  /// If [start] is not provided, this method searches from the end of the list.
  ///
  /// The first time an object [:o:] is encountered so that [:o == value:], the
  /// index of [:o:] is returned.
  /// ```dart
  /// final notes = ImmortalList(['do', 're', 'mi', 're']);
  /// notes.lastIndexOf('re');    // 3
  /// notes.lastIndexOf('re', 2); // 1
  /// ```
  /// Returns -1 if [value] is not found.
  /// ```dart
  /// notes.lastIndexOf('fa');    // -1
  /// ```
  int lastIndexOf(T value, [int? start]) => _list.lastIndexOf(value, start);

  /// Returns the last index in the list that satisfies the given [predicate].
  ///
  /// Searches the list from index [start] to 0.
  /// If [start] is not provided, this method searches from the end of the list.
  ///
  /// The first time an object `o` is encountered so that `predicate(o)` is
  /// `true`, the index of `o` is returned.
  /// ```dart
  /// final notes = ImmortalList(['do', 're', 'mi', 're']);
  /// notes.lastIndexWhere((note) => note.startsWith('r'));    // 3
  /// notes.lastIndexWhere((note) => note.startsWith('r'), 2); // 1
  /// ```
  /// Returns -1 if no element fulfilling [predicate] was found.
  /// ```dart
  /// notes.lastIndexWhere((note) => note.startsWith('k'));    // -1
  /// ```
  int lastIndexWhere(bool Function(T value) predicate, [int? start]) =>
      _list.lastIndexWhere(predicate, start);

  /// Returns the last element that satisfies the given predicate [predicate].
  ///
  /// Iterates through elements and returns the last one to satisfy [predicate].
  ///
  /// If no element satisfies [predicate], the result of invoking the [orElse]
  /// function is returned.
  /// If [orElse] is omitted, it defaults to throwing a [StateError].
  @override
  T lastWhere(bool Function(T value) predicate, {T Function()? orElse}) =>
      _list.lastWhere(predicate, orElse: orElse);

  /// Returns an [Optional] containing the last element that satisfies the given
  /// [predicate], or [Optional.empty] if none was found.
  ///
  /// Iterates through elements and returns the last one to satisfy [predicate].
  ///
  /// If no element satisfies [predicate], an [Optional.empty] is returned.
  ///
  /// If the `null` value satisfies the given [predicate], this lookup can not
  /// distinguish between not having any element satisfying the predicate and
  /// containing the `null` value satisfying the predicate.
  /// Methods like [contains] or [lastIndexWhere] can be used if the distinction
  /// is important.
  Optional<T> lastWhereAsOptional(bool Function(T value) predicate) {
    try {
      return Optional.ofNullable(_list.lastWhere(predicate));
      // ignore: avoid_catching_errors
    } on Error {
      return const Optional.empty();
    }
  }

  /// Returns the number of objects in this list.
  @override
  int get length => _list.length;

  /// Returns a new list with elements that are created by calling [f] on each
  /// element of this list in iteration order.
  @override
  ImmortalList<R> map<R>(R Function(T value) f) => ImmortalList(_list.map(f));

  /// Returns a new list with elements that are created by calling [f] on each
  /// element of this list and its respective index in iteration order.
  ///
  /// See [map].
  ImmortalList<R> mapIndexed<R>(R Function(int index, T value) f) =>
      ImmortalList(_list
          .asMap()
          .map((index, value) => MapEntry(index, f(index, value)))
          .values);

  /// Returns a copy of this list concatenating [other].
  ///
  /// See [addAll].
  @override
  ImmortalList<T> merge(Iterable<T> other) => addAll(other);

  /// Returns a tuple of two new lists by splitting the list into two depending
  /// on the result of the given [predicate].
  ///
  /// The first list will contain all elements that satisfy [predicate] and the
  /// remaining elements will produce the second list. The iteration order is
  /// preserved in both lists.
  Tuple2<ImmortalList<T>, ImmortalList<T>> partition(
    bool Function(T value) predicate,
  ) =>
      Tuple2(where(predicate), removeWhere(predicate));

  /// Returns a copy of this list replacing the value at the given [index] with
  /// [value].
  ///
  /// See [set].
  ImmortalList<T> put(int index, T value) => set(index, value);

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] by [value].
  ///
  /// See [setWhere].
  ImmortalList<T> putWhere(bool Function(T value) predicate, T value) =>
      setWhere(predicate, value);

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] with its respective index by [value].
  ///
  /// See [setWhere].
  ImmortalList<T> putWhereIndexed(
    bool Function(int index, T value) predicate,
    T value,
  ) =>
      setWhereIndexed(predicate, value);

  /// Reduces the list to a single value by iteratively combining each element
  /// of this list using the provided function [combine].
  ///
  /// The list must have at least one element.
  /// If it has only one element, that element is returned.
  ///
  /// Otherwise this method starts with the first element from the iterator,
  /// and then combines it with the remaining elements in iteration order,
  /// as if by:
  /// ```dart
  /// E value = list.first;
  /// list.skip(1).forEach((element) {
  ///   value = combine(value, element);
  /// });
  /// return value;
  /// ```
  /// Example of calculating the sum of a list:
  /// ```dart
  /// list.reduce((value, element) => value + element);
  /// ```
  @override
  T reduce(T Function(T value, T element) combine) => _list.reduce(combine);

  /// Returns a copy of this list where all occurrences of [element] are
  /// removed.
  ImmortalList<T> remove(Object? element) => removeAll([element]);

  /// Returns a copy of this list where the first element is removed if the
  /// list is not empty.
  ///
  /// Empty lists are returned unchanged.
  ImmortalList<T> removeFirst() => isNotEmpty ? skip(1) : this;

  /// Returns a copy of this list where the first occurrence of [element] is
  /// removed from if present.
  ///
  /// If [element] is not present in the list, the list is returned unchanged.
  ///
  /// Use [remove] to remove all occurrences of a value.
  ImmortalList<T> removeFirstOccurrence(Object? element) =>
      _mutateAsListIf(contains(element), (list) => list..remove(element));

  /// Returns a copy of this list where all values in [iterable] are removed
  /// from if present.
  ///
  /// All occurrences of the values in [iterable] are removed.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalList<T> removeAll(Iterable<Object?> iterable) => _mutateAsListIf(
      iterable.isNotEmpty, (list) => list..removeWhere(iterable.contains));

  /// Returns a copy of this list removing the object at position [index] if
  /// present.
  ///
  /// All later objects are moved down by one position if an element was
  /// removed.
  ///
  /// The provided [index] is adjusted to fit inside the boundaries of the list,
  /// i.e. to fulfill `0 <= index < length`.
  /// Empty lists are returned unchanged.
  ImmortalList<T> removeAt(int index) =>
      _mutateAsListIf(isNotEmpty, (list) => list..removeAt(_validIndex(index)));

  /// Returns a copy of this list removing the last object if there is one,
  /// otherwise the list is returned unchanged.
  ImmortalList<T> removeLast() =>
      _mutateAsListIf(isNotEmpty, (list) => list..removeLast());

  /// Returns a copy of this list where the last occurrence of [element] is
  /// removed from if present.
  ///
  /// If [element] is not present in the list, the list is returned unchanged.
  ///
  /// Use [remove] to remove all occurrences of a value.
  ImmortalList<T> removeLastOccurrence(T element) {
    final lastIndex = lastIndexOf(element);
    if (lastIndex >= 0) {
      return removeAt(lastIndex);
    }
    return this;
  }

  /// Returns a copy of this list where the objects in the range [start]
  /// inclusive to [end] exclusive are removed from.
  ///
  /// The provided range, given by [start] and [end], will be adjusted to fit
  /// inside the boundaries of the list if necessary, i.e. to fulfill
  /// `0 <= start <= end <= len`, where `len` is this list's [length].
  ///
  /// If the resulting range is empty, the list is returned unchanged.
  ImmortalList<T> removeRange(int start, int end) => _withRange(
      start,
      end,
      (range) => _mutateAsListIf(
            range.isNotEmpty,
            (list) => list..removeRange(range.start, range.end),
          ));

  /// Returns a copy of this list where all values that satisfy the given
  /// [predicate] are removed from.
  ///
  /// An object [:o:] satisfies [predicate] if [:predicate(o):] is `true`.
  ///
  /// Example:
  /// ```dart
  /// final numbers = ImmortalList(['one', 'two', 'three', 'four']);
  /// final removed = numbers.removeWhere((item) => item.length == 3);
  /// removed.join(', '); // 'three, four'
  /// ```
  ImmortalList<T> removeWhere(bool Function(T value) predicate) =>
      _mutateAsList((list) => list..removeWhere(predicate));

  /// Returns a copy of this list replacing the value at the given [index] with
  /// [value].
  ///
  /// See [set].
  ImmortalList<T> replaceAt(int index, T value) => set(index, value);

  /// Returns a copy of this list where all objects in the range [start]
  /// inclusive to [end] exclusive are removed from and replaced by the contents
  /// of [iterable].
  ///
  /// Example:
  /// ```dart
  /// final list = ImmortalList([1, 2, 3, 4, 5]);
  /// final replaced = list.replaceRange(1, 4, ImmortalList([6, 7]));
  /// list.join(', '); // '1, 6, 7, 5'
  /// ```
  /// The provided range, given by [start] and [end], will be adjusted to fit
  /// inside the boundaries of the list if necessary, i.e. to fulfill
  /// `0 <= start <= end <= len`, where `len` is this list's [length].
  ///
  /// The resulting list might be longer than the original list.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalList<T> replaceRange(int start, int end, Iterable<T> iterable) =>
      _withRange(
          start,
          end,
          (range) => _mutateAsList((list) => list
            ..replaceRange(
              range.start,
              range.end,
              iterable,
            )));

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] by [value].
  ///
  /// See [setWhere].
  ImmortalList<T> replaceWhere(bool Function(T value) predicate, T value) =>
      setWhere(predicate, value);

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] with its respective index by [value].
  ///
  /// See [setWhere].
  ImmortalList<T> replaceWhereIndexed(
    bool Function(int index, T value) predicate,
    T value,
  ) =>
      setWhereIndexed(predicate, value);

  /// Returns a copy of this list where all values that fail to satisfy the
  /// given [predicate] are removed from.
  ///
  /// An object [:o:] satisfies [predicate] if [:predicate(o):] is `true`.
  ///
  /// Example:
  /// ```dart
  /// final numbers = ImmortalList(['one', 'two', 'three', 'four']);
  /// final retained = numbers.retainWhere((item) => item.length == 3);
  /// retained.join(', '); // 'one, two'
  /// ```
  ImmortalList<T> retainWhere(bool Function(T value) predicate) =>
      _mutateAsList((list) => list..retainWhere(predicate));

  /// Returns a list containing the objects of this list in reverse order.
  ImmortalList<T> get reversed => ImmortalList(_list.reversed);

  /// Returns a copy of this list replacing the value at the given [index] with
  /// [value].
  ///
  /// The provided [index] is adjusted to fit inside the boundaries of the list,
  /// i.e. to fulfill `0 <= index < length`.
  ///
  /// The resulting list will have the same length as the original list.
  /// Empty lists are returned unchanged.
  ImmortalList<T> set(int index, T value) =>
      _mutateAsListIf(isNotEmpty, (list) => list..[_validIndex(index)] = value);

  /// Returns a copy of this list replacing the objects starting at position
  /// [index] with the objects of [iterable].
  ///
  /// Example:
  /// ```dart
  /// final list = ImmortalList(['a', 'b', 'c']);
  /// final newList = list.setAll(1, ImmortalList(['bee', 'sea']));
  /// newList.join(', '); // 'a, bee, sea'
  /// ```
  /// The provided [index] is adjusted to fit inside the boundaries of the list,
  /// i.e. to fulfill `0 <= index <= length`.
  /// As the list [iterable] has to fit inside these boundaries as well, it will
  /// be shortened as necessary, so that the resulting list will have the same
  /// length as the original one.
  ///
  /// If [iterable] is empty, the list is returned unchanged.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalList<T> setAll(int index, Iterable<T> iterable) =>
      _mutateAsListIf(iterable.isNotEmpty, (list) {
        final validIndex = _validIndexOrEnd(index);
        return list
          ..setAll(
            validIndex,
            iterable.take(length - validIndex),
          );
      });

  /// Returns a copy of this list where the objects in the range [start]
  /// inclusive to [end] exclusive are replaced by the objects of [iterable]
  /// while skipping [skipCount] objects first.
  ///
  /// Example:
  /// ```dart
  /// final list1 = ImmortalList([1, 2, 3, 4]);
  /// final list2 = ImmortalList([5, 6, 7, 8, 9]);
  /// // Copies the 4th and 5th items in list2 as the 2nd and 3rd
  /// // items of list1.
  /// final newList = list1.setRange(1, 3, list2, 3);
  /// newList.join(', '); // '1, 8, 9, 4'
  /// ```
  /// The provided range, given by [start] and [end], will be adjusted to fit
  /// inside the boundaries of the list if necessary, i.e. to fulfill
  /// `0 <= start <= end <= len`, where `len` is this list's [length].
  /// If the list [iterable] is not long enough to fill the range, the range
  /// will be shortened accordingly.
  ///
  /// If the resulting range or [iterable] is empty, the list is returned
  /// unchanged.
  ///
  /// The resulting list will have the same length as the original list.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalList<T> setRange(
    int start,
    int end,
    Iterable<T> iterable, [
    int skipCount = 0,
  ]) {
    final range = _validRangeWithOtherList(start, end, iterable.length);
    return _mutateAsListIf(
        iterable.isNotEmpty && range.isNotEmpty,
        (list) => list
          ..setRange(
            range.start,
            range.end,
            iterable,
            skipCount,
          ));
  }

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] by [newValue].
  ImmortalList<T> setWhere(bool Function(T value) predicate, T newValue) =>
      map((value) => predicate(value) ? newValue : value);

  /// Returns a copy of this list replacing each element that fulfills the given
  /// [predicate] with its respective index by [newValue].
  ///
  /// See [setWhere].
  ImmortalList<T> setWhereIndexed(
    bool Function(int index, T value) predicate,
    T newValue,
  ) =>
      mapIndexed(
        (index, value) => predicate(index, value) ? newValue : value,
      );

  /// Returns a copy of this list randomly shuffling the elements.
  ImmortalList<T> shuffle([Random? random]) =>
      _mutateAsList((list) => list..shuffle(random));

  /// Checks that this list has only one element, and returns that element.
  ///
  /// Throws a [StateError] if this list is empty or has more than one element.
  @override
  T get single => _list.single;

  /// Returns an [Optional] containing the only element of this list if it has
  /// exactly one element, otherwise returns [Optional.empty].
  ///
  /// This lookup can not distinguish between the list being empty and
  /// containing the `null` value as only element.
  /// Methods like [contains] or [length] can be used if the distinction is
  /// important.
  Optional<T> get singleAsOptional =>
      getValueIf(length == 1, () => _list.single);

  /// Returns the single element of this list that satisfies [predicate].
  ///
  /// Checks elements to see if `predicate(element)` returns true.
  /// If exactly one element satisfies [predicate], that element is returned.
  /// If more than one matching element is found, throws [StateError].
  /// If no matching element is found, returns the result of [orElse].
  /// If [orElse] is omitted, it defaults to throwing a [StateError].
  @override
  T singleWhere(bool Function(T value) predicate, {T Function()? orElse}) =>
      _list.singleWhere(predicate, orElse: orElse);

  /// Returns an [Optional] containing the only element satisfying the given
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
  /// predicate and containing only the `null` value satisfying the predicate.
  /// Methods like [contains] can be used if the distinction is important.
  Optional<T> singleWhereAsOptional(bool Function(T value) predicate) {
    try {
      return Optional.ofNullable(_list.singleWhere(predicate));
      // ignore: avoid_catching_errors
    } on Error {
      return const Optional.empty();
    }
  }

  /// Returns a copy of this list that contains all but the fist [count]
  /// elements.
  ///
  /// The new list is created by iterating over this list skipping past the
  /// initial [count] elements.
  /// If this list has fewer than [count] elements, then the resulting list is
  /// empty.
  ///
  /// If the passed [count] is zero or negative, the list is returned unchanged.
  @override
  ImmortalList<T> skip(int count) =>
      count <= 0 ? this : ImmortalList(_list.skip(count));

  /// Returns a copy of this list containing all elements except the leading
  /// elements while the given [predicate] is satisfied.
  ///
  /// The new list is created by iterating over this list skipping over all
  /// initial elements where `predicate(element)` returns `true`.
  /// If all elements satisfy [predicate] the resulting list is empty,
  /// otherwise it iterates the remaining elements in their original order,
  /// starting with the first element for which `predicate(element)` returns
  /// `false`.
  @override
  ImmortalList<T> skipWhile(bool Function(T value) predicate) =>
      ImmortalList(_list.skipWhile(predicate));

  /// Returns a copy of this list sorting the elements according to the order
  /// specified by the [compare] function.
  ///
  /// The [compare] function must act as a [Comparator].
  /// ```dart
  /// final numbers = ImmortalList(['two', 'three', 'four']);
  /// // Sort from shortest to longest.
  /// final sorted = numbers.sort((a, b) => a.length.compareTo(b.length));
  /// print(sorted);  // Immortal[two, four, three]
  /// ```
  /// If [compare] is omitted, [Comparable.compare] is used.
  /// ```dart
  /// final nums = ImmortalList([13, 2, -11]);
  /// final sorted = nums.sort();
  /// print(sorted);  // [-11, 2, 13]
  /// ```
  /// A [Comparator] may compare objects as equal (return zero), even if they
  /// are distinct objects.
  /// The sort function is not guaranteed to be stable, so distinct objects that
  /// compare as equal may occur in any order in the result:
  /// ```dart
  /// final numbers = ImmortalList(['one', 'two', 'three', 'four']);
  /// final sorted = numbers.sort((a, b) => a.length.compareTo(b.length));
  /// print(sorted);  // [one, two, four, three] OR [two, one, four, three]
  /// ```
  ImmortalList<T> sort([int Function(T value, T otherValue)? compare]) =>
      _mutateAsList((list) => list..sort(compare));

  /// Returns a copy of this containing all elements between [start] and [end].
  /// ```dart
  /// final colors = ImmortalList(['red', 'green', 'blue', 'orange']);
  /// print(colors.sublist(1, 3)); // Immortal[green, blue]
  /// ```
  /// If [end] is omitted, it defaults to the [length] of this list.
  /// ```dart
  /// print(colors.sublist(1)); // Immortal[green, blue, orange]
  /// ```
  /// The provided range, given by [start] and [end], will be adjusted to fit
  /// inside the boundaries of the list if necessary, i.e. to fulfill
  /// `0 <= start <= end <= len`, where `len` is this list's [length].
  ///
  /// If the resulting range covers the whole list, it will be returned
  /// unchanged.
  ImmortalList<T> sublist(int start, [int? end]) => _withRange(
      start,
      end ?? length,
      (range) => range.spansWholeList(length)
          ? this
          : ImmortalList._internal(_list.sublist(range.start, range.end)));

  /// Returns a copy of this list containing the [count] first elements.
  ///
  /// The returned list may contain fewer than [count] elements if this list
  /// contains fewer than [count] elements.
  ///
  /// Returns an empty list if [count] is zero or negative.
  ///
  /// If [count] is equal to or grater than the list's length, the list is
  /// returned unchanged.
  @override
  ImmortalList<T> take(int count) => count >= length
      ? this
      : ImmortalList(count <= 0 ? <T>[] : _list.take(count));

  /// Returns a copy of this list containing the leading elements satisfying the
  /// given [predicate].
  @override
  ImmortalList<T> takeWhile(bool Function(T value) predicate) =>
      ImmortalList(_list.takeWhile(predicate));

  /// Creates a mutable [List] containing the elements of this list.
  ///
  /// The elements are in iteration order.
  /// The list is fixed-length if [growable] is `false`.
  @override
  List<T> toList({bool growable = true}) => _list.toList(growable: growable);

  /// Creates an [ImmortalSet] containing the same elements as this list.
  ///
  /// The set may contain fewer elements than this list if the list contains an
  /// element more than once, or it contains one or more elements that are equal
  /// in respect to the `==` operator.
  ImmortalSet<T> toImmortalSet() => ImmortalSet(_list.toSet());

  /// Creates a mutable [Set] containing the same elements as this list.
  ///
  /// The set may contain fewer elements than this list if the list contains an
  /// element more than once, or it contains one or more elements that are equal
  /// in respect to the `==` operator.
  /// The order of the elements in the set is not guaranteed to be the same
  /// as for the iterable.
  @override
  Set<T> toSet() => _list.toSet();

  /// A string representation of this object.
  ///
  /// See [Object.toString].
  @override
  String toString() => 'Immortal${_list.toString()}';

  /// Returns a copy of this list replacing the value at the given [index] by
  /// applying the function [update] to its value.
  ///
  /// If there is no element at the provided [index], the list is returned
  /// unchanged.
  /// The resulting list will have the same length as the original list.
  ImmortalList<T> updateAt(int index, T Function(T value) update) =>
      elementAtAsOptional(index)
          .map(
            (value) => set(index, update(value)),
          )
          .orElse(this);

  /// Returns a copy of this list by applying [update] on each element that
  /// fulfills the given [predicate].
  ImmortalList<T> updateWhere(
    bool Function(T value) predicate,
    T Function(T value) update,
  ) =>
      map((value) => predicate(value) ? update(value) : value);

  /// Returns a copy of this list by applying [update] on each element and its
  /// respective index that fulfill the given [predicate].
  ///
  /// See [updateWhere].
  ImmortalList<T> updateWhereIndexed(
    bool Function(int index, T value) predicate,
    T Function(int index, T value) update,
  ) =>
      mapIndexed((index, value) =>
          predicate(index, value) ? update(index, value) : value);

  /// Returns a new list with all elements of this list that satisfy the given
  /// [predicate].
  ///
  /// The matching elements have the same order in the returned list as they
  /// have in [iterator].
  @override
  ImmortalList<T> where(bool Function(T value) predicate) =>
      ImmortalList(_list.where(predicate));

  /// Returns a new list containing all elements that satisfy the given
  /// [predicate] with their respective indices.
  ///
  /// See [where].
  ImmortalList<T> whereIndexed(bool Function(int index, T value) predicate) =>
      asMap().where(predicate).values;

  /// Returns a new list with all elements of this list that have type [R].
  ///
  /// The matching elements have the same order in the returned list as they
  /// have in [iterator].
  @override
  ImmortalList<R> whereType<R>() => ImmortalList(_list.whereType<R>());

  /// Returns a new list consisting of tuples with elements from this list and
  /// the [iterable].
  ///
  /// The element at index `i` of the resulting list will consist of the
  /// elements at index `i` from this list and [iterable].
  /// If this list and [iterable] have different lengths, the iteration will
  /// stop at the length of the shorter one, so that there are always two
  /// values for building the tuples.
  ///
  /// It iterates over [iterable], which must therefore not change during the
  /// iteration.
  ImmortalList<Tuple2<T, R>> zip<R>(Iterable<R> iterable) =>
      take(iterable.length).mapIndexed((index, value) => Tuple2<T, R>(
            elementAt(index),
            iterable.elementAt(index),
          ));
}
