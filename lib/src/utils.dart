import 'package:optional/optional.dart';

abstract class DeeplyComparable {
  /// Checks whether this object is deeply equal to [other].
  bool equals(dynamic other);
}

T identity<T>(T value) => value;

// ignore: avoid_positional_boolean_parameters
bool isTrue(bool value) => value ?? false;

T returnNull<T>() => null;

bool Function(T) equalTo<T>(T value) => (otherValue) =>
    value is DeeplyComparable ? value.equals(otherValue) : otherValue == value;

bool Function(T) not<T>(bool Function(T) f) => (v) => !f(v);

Optional<T> getValueIf<T>(
  // ignore: avoid_positional_boolean_parameters
  bool condition,
  T Function() getValue,
) =>
    condition ? Optional.ofNullable(getValue()) : Optional.empty();
