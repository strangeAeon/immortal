# immortal

[![pub package](https://img.shields.io/pub/v/immortal.svg)](https://pub.dartlang.org/packages/immortal)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)

Trve immutable wrapper classes for Dart collections.

## Usage

### Getting started

Add `immortal` as dependency in your `pubspec.yaml`:

```yaml
dependencies:
  ...
  immortal: ^2.1.1
```

Import `immortal`:

```dart
import 'package:immortal/immortal.dart';
```

### Examples

- Lists

  ```dart
  final immortalList = ImmortalList([1, 2, 3]);
  final modifiedList = immortalList
      .add(4)
      .where((value) => value.isEven)
      .map((value) => value * 2);
  print(immortalList); // prints "Immortal[1, 2, 3]"
  print(modifiedList); // prints "Immortal[4, 8]"
  ```

- Sets

  ```dart
  final immortalSet = ImmortalSet({1, 2, 3});
  final modifiedSet = immortalSet
      .union(ImmortalSet({1, 2}))
      .remove(1);
  print(immortalSet); // prints "Immortal{1, 2, 3}"
  print(modifiedSet); // prints "Immortal{2, 3}"
  ```

- Maps

  ```dart
  final immortalMap = ImmortalMap({1: 'a', 2: 'b', 3: 'c'});
  final modifiedMap = immortalMap
      .putIfAbsent(2, () => 'e')
      .update(1, (value) => value.toUpperCase());
  print(immortalMap); // prints "Immortal{1: 'a', 2: 'b', 3: 'c'}"
  print(modifiedMap); // prints "Immortal{1: 'A', 2: 'b', 3: 'c'}"
  ```

- [A more elaborate example](https://pub.dev/packages/immortal/example)

### API reference

For a complete list of all functions defined on the `immortal` collections see the [API reference](https://pub.dev/documentation/immortal/latest/immortal/immortal-library.html).

## Introduction

This library provides a more functional wrapper around the `dart:core` collections `List`, `Set` and `Map` called `ImmortalList`, `ImmortalSet` and `ImmortalMap`.

It is designed with usability and readability in mind while staying close to the method names of their mutable counterparts.
This should make switching from mutable to `Immortal` collections in existing applications fairly easy.

In order to reach complete immutability, the elements have to be immutable as well.

If you want to go fully functional, however, you should consider using e.g. `dartz` instead.

The key objectives for this library are the following:

- Mutation methods return new instances instead of throwing exceptions
- No builder pattern to create new instances
- Optionals for nullable return values or at least providing alternatives using optionals (e.g. for list methods required to implement the `Iterable` interface like `first` there is an alternative `firstAsOptional`)
- High fault tolerance in general, e.g. list indices passed as parameters are adjusted to fit inside the list's boundaries (except for list methods required to implement the `Iterable` interface, but alternatives using optionals are provided as stated above)
- Return the same instance if no changes were made in mutation methods (there is still some potential to improve and extend this in future updates of this library)
- No assumptions about the order of elements in a set: `ImmortalSet` does not implement the `Iterable` interface and provides methods like `elementAt`, `first`, `skip` etc. even though the underlying implementation of Dart's `Set` might do so.
- Provide more common names in addition to the Dart method names, like `flatMap` for `expand` (this is something that might be extended in future updates as well)
- Addition of useful methods missing in `dart:core`, e.g. `mapKeys` and `mapValues` on `ImmortalMap` (this is again something that might be extended in future library updates).
- Encourage further usage of immutable collections by prefering `Immortal` parameters.
- Encourage comparison by identity only by not overriding the `==` operator. To compare collections by their content `equals` methods are provided.
- Designed to write elegant code - not neccessarily the most performant. But immutability usually comes with a price anyways 🤷 (this might still be improved in future versions of this library)

## Motivation

Yet another implementation of immutable collections for Dart..?

I was never fully satisfied with other libraries that provide immutable collections for Dart. They either do not provide mutation methods to create new, modified instances or only do so by the usage of the builder pattern.
This way they are often cumbersome to use and I felt I had to write too much code in order to perform simple tasks such as adding or updating a single element.

So I decided to write my own.

The main purpose of use for me is inside Redux or other component states in Flutter applications. I want to write short and simple reducer functions while being able to check for identity alone when I want to find out if the state has changed. As checks for state changes usually happen a lot more frequently (to find out if a component has to be rebuilt) as actual changes to the state, the performance of creating and updating instances was not my main focus while writing this library.

## Why `Immortal`?

I wanted to prevent name clashes with other libraries - and I just think the name is fitting and cool 🤘

> In eternity and time the same still the tundra lay untouched
