import 'package:optional/optional.dart';
import 'package:test/test.dart';

import 'package:immortal/src/utils.dart' as utils;

import 'test_data.dart';

class EvenOdd {
  const EvenOdd(this.value);

  final int value;

  @override
  bool operator ==(Object other) =>
      other is EvenOdd && value.isOdd == other.value.isOdd;

  @override
  int get hashCode => value.isOdd.hashCode;
}

void main() {
  test('should return identity', () {
    expect(utils.identity(1), 1);
    expect(utils.identity(1), 1.0);
    expect(utils.identity('foobar'), 'foobar');
    expect(utils.identity(null), null);
    expect(utils.identity(EvenOdd(2)), EvenOdd(4));
    expect(utils.identity(EvenOdd(3)), isNot(EvenOdd(4)));
  });

  test('should return if true', () {
    expect(utils.isTrue(true), true);
    expect(utils.isTrue(false), false);
    expect(utils.isTrue(null), false);
  });

  test('should return null', () {
    expect(utils.returnNull(), null);
  });

  test('should compare to value', () {
    expect(utils.equalTo(1)(1), true);
    expect(utils.equalTo(1)(2), false);
    expect(utils.equalTo('foo')('foo'), true);
    expect(utils.equalTo('foo')('bar'), false);
    expect(utils.equalTo(EvenOdd(2))(EvenOdd(4)), true);
    expect(utils.equalTo(EvenOdd(2))(EvenOdd(3)), false);
  });

  test('should negate', () {
    expect(utils.not(utils.isTrue)(false), true);
    expect(utils.not(utils.isTrue)(true), false);
  });

  test('should conditionally wrap value in optional', () {
    expect(utils.getValueIf<int>(false, yields(10)), Optional.empty());
    expect(utils.getValueIf<int>(true, yields(10)), Optional.of(10));
    expect(utils.getValueIf<int>(true, yields(null)), Optional.empty());
  });
}
