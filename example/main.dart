import 'package:immortal/immortal.dart';

void main() {
  listExample();
  setExample();
  mapExample();
}

void listExample() {
  final list = ImmortalList([1, 2, 3]);
  final modifiedList = list
      .add(4)
      .followedBy(ImmortalList([1, 2]))
      .where((value) => value.isEven)
      .map((value) => value * 2)
      .skip(1)
      .take(1);
  print(list);         // prints "Immortal[1, 2, 3]"
  print(modifiedList); // prints "Immortal[8]"
}

void setExample() {
  final set = ImmortalSet({1, 2, 3});
  final modifiedSet = set
      .add(4)
      .union(ImmortalSet({1, 2}))
      .where((value) => value.isEven)
      .map((value) => value * 2)
      .remove(4);
  print(set);         // prints "Immortal{1, 2, 3}"
  print(modifiedSet); // prints "Immortal{8}"
}

void mapExample() {
  final map = ImmortalMap({1: 'a', 2: 'b', 3: 'c'});
  final modifiedMap = map
      .add(4, 'd')
      .mapKeys((key, _) => key * 2)
      .putIfAbsent(4, () => 'e')
      .removeWhere((key, value) => key < 2 || value != 'd')
      .update(8, (value) => value.toUpperCase());
  print(map);         // prints "Immortal{1: 'a', 2: 'b', 3: 'c'}"
  print(modifiedMap); // prints "Immortal{8: 'D'}"
}
