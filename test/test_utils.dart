import 'package:immortal/src/utils.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void expectCollection(DeeplyComparable actual, DeeplyComparable expected) {
  expect(actual.equals(expected), true);
}

void expectCollectionTuple<T1, T2>(
  Tuple2<DeeplyComparable, DeeplyComparable> actual,
  Tuple2<DeeplyComparable, DeeplyComparable> expected,
) {
  expectCollection(actual.item1, expected.item1);
  expectCollection(actual.item2, expected.item2);
}
