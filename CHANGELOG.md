## 3.0.0

* Update dependencies:
  * optional: ^6.1.0
* Update dev dependencies:
  * effective_dart: ^1.3.2
  * test: ^1.20.1

## 3.0.0-nullsafety

* Extend `ImmortalList` to implement `Iterable`
  * **(Breaking change)** Adjust transformation methods of `ImmortalList`:
    * Rename previous `toSet` to `toImmortalSet`
    * Add new `toSet` to return mutable `Set`
    * Rename `toMutableList` to `toList`
  * **(Breaking change)** Change return type from `Optional<T>` to `T` for `ImmortalList` methods as required to implement the `Iterable` interface and provide alternative versions using `Optional<T>`:
    * `elementAt` > `elementAtAsOptional`
    * `first` > `firstAsOptional`
    * `firstWhere` > `firstWhereAsOptional`
    * `last` > `lastAsOptional`
    * `lastWhere` > `lastWhereAsOptional`
    * `single` > `singleAsOptional`
    * `singleWhere` > `singleWhereAsOptional`
  * **(Breaking change)** Combine equivalent methods handling `ImmortalList` and `Iterable` to all allow `Iterable` and remove obsolete versions:
    * `ImmortalList`:
      * ~~`ImmortalList.fromIterable`~~ > `ImmortalList.from`
      * ~~`ImmortalList.ofIterable`~~ > `ImmortalList.of`
      * ~~`ImmortalList.castFromIterable`~~ > `ImmortalList.castFrom`
      * ~~`addIterable`~~ > `addAll`
      * ~~`concatenateIterable`~~ > `concatenate`
      * ~~`expandIterable`~~ > `expand`
      * ~~`flatMapIterable`~~ > `flatMap`
      * ~~`flatMapIterableIndexed`~~ > `flatMapIndexed`
      * ~~`flattenIterables`~~ > `flatten`
      * ~~`followedByIterable`~~ > `followedBy`
      * ~~`insertIterable`~~ > `insertAll`
      * ~~`removeIterable`~~ > `removeAll`
      * ~~`replaceRangeIterable`~~ > `replaceRange`
      * ~~`setIterable`~~ > `setAll`
      * ~~`setRangeIterable`~~ > `setRange`
      * ~~`zipIterable`~~ > `zip`
    * `ImmortalSet`:
      * ~~`addList`~~ > `addIterable`
      * ~~`flattenLists`~~ > `flattenIterables`
    * `ImmortalMap`:
      * ~~`ImmortalMap.fromEntriesIterable`~~ > `ImmortalMap.fromEntries`
      * ~~`ImmortalMap.fromList`~~ > `ImmortalMap.fromIterable`
      * ~~`ImmortalMap.fromLists`~~ > `ImmortalMap.fromIterables`
      * ~~`ImmortalMap.fromPairsIterable`~~ > `ImmortalMap.fromPairs`
      * ~~`addEntriesIterable`~~ > `addEntries`
      * ~~`addPairsIterable`~~ > `addPairs`
      * ~~`removeValuesIterable`~~ > `removeValues`
  * **(Breaking change)** Rename further functions to keep naming consistent:
    * `ImmortalSet`:
      * ~~`toList`~~ > `toImmortalList`
      * ~~`toMutableList`~~ > `toList`
      * ~~`toMutableSet`~~ > `toSet`
    * `ImmortalMap`:
      * ~~`ImmortalMap.fromMutable`~~ > `ImmortalMap.fromMap`
      * ~~`ImmortalMap.ofMutable`~~ > `ImmortalMap.ofMap`
      * ~~`ImmortalMap.castFromMutable`~~ > `ImmortalMap.castFromMap`
      * ~~`flattenMutables`~~ > `flattenMaps`
      * ~~`toMutableMap`~~ > `toMap`
  * Relax parameter types from `ImmortalList` to `Iterable`:
    * `ImmortalList`:
      * operators `+`, `-`
      * method `merge`
  * Extend `ImmortalList` functionality:
    * Add method `reduce`
* Migrate to dart null-safety
  * Change parameter type annotations from generic types or `Object` to `Object?`:
    * `ImmortalList`: operator `-`, `contains`, `remove`, `removeFirstOccurrence`, `removeAll`, `removeLastOccurrence`
    * `ImmortalSet`: operators `-` and `&`, `contains`, `containsAll`, `containsIterable`, `difference`, `differenceWithSet`, `intersection`, `intersectionWithSet`, `lookup`, `remove`, `removeAll`, `removeIterable`, `retainAll`, `retainIterable`
    * `ImmortalMap`: operator `[]`, `containsKey`, `containsValue`, `get`, `getKeysForValue`, `keysForValue`, `lookup`, `lookupKeysForValue`, `remove`, `removeAll`, `removeIterable`, `removeValue`, `removeValues`

## 2.1.2-nullsafety

* Update dependencies:
  * optional: ^6.0.0-nullsafety.0
  * tuple: ^2.0.0
* Update dev dependencies:
  * effective_dart: ^1.3.1
  * test: ^1.16.8

## 2.1.1

* Update dependencies:
  * optional v5.0.0
* Update dev dependencies:
  * effective_dart: v1.2.2
  * test v1.14.7

## 2.1.0

* Extend list functionality:
  * methods: `addIfAbsent`, `addOrPutWhere`, `addOrReplaceWhere`, `addOrSetWhere`, `addOrUpdateWhere`
* Extend set functionality:
  * methods: `addOrReplaceWhere`, `addOrUpdateWhere`, `replaceWhere`
* Update dependencies:
  * optional v4.1.0
  * tuple v1.0.3

## 2.0.0

* Extend list functionality:
  * methods: `asMapOfLists`, `merge`, `remove`, `removeFirst`, `removeLastOccurrence`
  * Rename previous `remove` to `removeFirstOccurrence`
* Extend set functionality:
  * methods: `addList`, `merge`
* Extend map functionality:
  * methods: `keysWhere`, `merge`, `singleKeyWhere`, `singleValueWhere`, `singleWhere`, `valuesWhere`
  * Change return types of `getKeysForValue`, `keys`, `keysForValue`, `lookupKeysForValue` from lists to sets
  * Change parameter type of `removeAll` from list to set
  * Remove deprecated method `removeAllValues`
* All collections:
  * Perform deep comparison in `equals` by adding `DeeplyComparable` interface

## 1.2.0

* Extend list functionality:
  * methods: `anyIndexed`, `asMapWithKeys`, `asMapWithKeysIndexed`, `everyIndexed`, `expandIndexed`, `expandIterableIndexed`, `filterIndexed`, `flatMapIndexed`, `flatMapIterableIndexed`, `flatten`, `flattenIterables`, `indicesOf`, `indicesWhere`, `putWhere`, `putWhereIndexed`, `replaceAt`, `replaceWhere`, `replaceWhereIndexed`, `setWhere`, `setWhereIndexed`, `updateAt`, `updateWhere`, `updateWhereIndexed`, `whereIndexed`
* Extend set functionality:
  * methods: `asMapWithKeys`, `flatten`, `flattenIterables`, `flattenLists`, `updateWhere`
* Extend map functionality:
  * methods: `addEntryIfAbsent`, `any`, `anyKey`, `anyValue`, `every`, `everyKey`, `everyValue`, `filter`, `filterKeys`, `filterValues`, `flatten`, `flattenMutables`, `get`, `getKeysForValue`, `keysForValue`, `lookupKeysForValue`, `put`, `putEntryIfAbsent`, `putWhere`, `removeWhereKey`, `removeWhereValue`, `replace`, `replaceEntry`, `replaceKey`, `replaceWhere`, `set`, `setEntry`, `setEntryIfAbsent`, `setIfAbsent`, `setWhere`, `single`, `singleKey`, `singleValue`, `updateEntry`, `updateKey`, `updateWhere`, `where`, `whereKey`, `whereValue`
  * Rename `removeAllValues` to `removeValues` and mark `removeAllValues` as deprecated

## 1.1.0

* Extend list functionality:
  * methods: `mapIndexed`, `removeAll`, `removeIterable`, `partition`, `zip`, `zipIterable`, `forEachIndexed`, `equals`
  * operators: `-`
  * factories: `empty`, `filled`, `from`, `fromIterable`, `generate`, `of`, `ofIterable`, `castFrom`, `castFromIterable`
* Extend set functionality:
  * methods: `toggle`, `partition`, `equals`
  * operators: `+`, `-`, `|`, `&`
  * factories: `empty`, `from`, `fromIterable`, `of`, `ofIterable`, `castFrom`, `castFromIterable`
* Extend map functionality:
  * methods: `mapEntries`, `removeAll`, `removeIterable`, `removeAllValues`, `removeValuesIterable`, `addPair`, `addPairs`, `addPairsIterable`, `pairs`, `equals`
  * operators: `+`
  * factories: `empty`, `from`, `fromEntries`, `fromEntriesIterable`, `fromLists`, `fromIterables`, `fromPairs`, `fromPairsIterable`, `fromMutable`, `of`, `ofMutable`, `castFrom`, `castFromMutable`, `fromList`, `fromIterable`

## 1.0.0

* Initial release
