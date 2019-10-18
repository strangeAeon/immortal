import 'package:optional/optional.dart';

T identity<T>(T value) => value;

// ignore: avoid_positional_boolean_parameters
bool isTrue(bool value) => value ?? false;

T returnNull<T>() => null;

bool Function(T) equalTo<T>(T value) => (otherValue) => otherValue == value;

bool Function(T) not<T>(bool Function(T) f) => (v) => !f(v);

Optional<T> getValueIf<T>(
  // ignore: avoid_positional_boolean_parameters
  bool condition,
  T Function() getValue,
) =>
    condition ? Optional.ofNullable(getValue()) : Optional.empty();
