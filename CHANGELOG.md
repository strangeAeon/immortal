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
