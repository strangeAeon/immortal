import 'package:immortal/immortal.dart';

// Lists
final ImmortalList<int> emptyList = ImmortalList<int>();
final ImmortalList<int> list1 = ImmortalList([1]);
final ImmortalList<int> list123 = ImmortalList([1, 2, 3]);

// Sets
final ImmortalSet<int> emptySet = ImmortalSet<int>();
final ImmortalSet<int> set1 = ImmortalSet({1});
final ImmortalSet<int> set123 = ImmortalSet({1, 2, 3});

// Maps
final ImmortalMap<String, int> emptyMap = ImmortalMap<String, int>();
final ImmortalMap<String, int> mapA1 = ImmortalMap({'a': 1});
final ImmortalMap<String, int> mapA1B2C3 = ImmortalMap({
  'a': 1,
  'b': 2,
  'c': 3,
});

bool isOdd(int value) => value.isOdd;
String toString(Object value) => value.toString();
int inc(int value) => value + 1;
int add(int a, int b) => a + b;
int multiply(int a, int b) => a * b;
bool matchingAll<T>(T _, [__]) => true;
bool matchingNone<T>(T _, [__]) => false;
bool Function(T) matching<T>(T value) => (otherValue) => otherValue == value;
bool Function(A, B) matchingValue<A, B>(B value) =>
    (_, otherValue) => otherValue == value;
T Function([X, Y]) yields<T, X, Y>(T value) => ([_, __]) => value;
