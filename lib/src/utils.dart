import 'package:optional/optional.dart';

/// Interface used by types that allow deep comparisons between two instances.
abstract class DeeplyComparable {
  /// Checks whether this object is deeply equal to [other].
  bool equals(dynamic other);
}

/// Interface used by types that allow merging of two instances.
abstract class Mergeable<T> {
  /// Merges this object with [other].
  T merge(T other);
}

/// Helper function that returns the given [value] unchanged.
T identity<T>(T value) => value;

/// Helper function to check if the given [value] is true.
// ignore: avoid_positional_boolean_parameters
bool isTrue(bool value) => value ?? false;

/// Helper function that always returns null.
T returnNull<T>() => null;

/// Compares two values by applying deep comparison if possible - otherwise an
/// equality check using the `==` operator is performed.
bool Function(T) equalTo<T>(T value) => (otherValue) =>
    value is DeeplyComparable ? value.equals(otherValue) : otherValue == value;

/// Helper function that negates the results of the given [predicate].
bool Function(T) not<T>(bool Function(T) predicate) => (v) => !predicate(v);

/// Helper function that returns an [Optional] containing the result of
/// [getValue] if the given [condition] is true.
Optional<T> getValueIf<T>(
  // ignore: avoid_positional_boolean_parameters
  bool condition,
  T Function() getValue,
) =>
    condition ? Optional.ofNullable(getValue()) : const Optional.empty();
