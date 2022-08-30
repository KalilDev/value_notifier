import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';

import 'idisposable_change_notifier.dart';

abstract class CollectionValueNotifier<T, It extends Iterable<T>,
        WrappedIt extends Iterable<T>> extends IDisposableChangeNotifier
    implements IDisposableValueListenable<WrappedIt>, Iterable<T> {
  final It _base;

  CollectionValueNotifier(this._base);
  WrappedIt _wrap(It iterable);
  @override
  late final WrappedIt value = _wrap(_base);

  void mutate(void Function(It) fn) {
    fn(_base);
    notifyListeners();
  }

  @override
  bool any(bool Function(T element) test) => _base.any(test);

  @override
  Iterable<R> cast<R>() => _base.cast();

  @override
  bool contains(Object? element) => _base.contains(element);

  @override
  T elementAt(int index) => _base.elementAt(index);

  @override
  bool every(bool Function(T element) test) => _base.every(test);

  @override
  Iterable<T1> expand<T1>(Iterable<T1> Function(T element) toElements) =>
      _base.expand(toElements);

  @override
  T get first => _base.first;

  @override
  T firstWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _base.firstWhere(
        test,
        orElse: orElse,
      );

  @override
  T1 fold<T1>(
          T1 initialValue, T1 Function(T1 previousValue, T element) combine) =>
      _base.fold(
        initialValue,
        combine,
      );

  @override
  Iterable<T> followedBy(Iterable<T> other) => _base.followedBy(other);

  @override
  void forEach(void Function(T element) action) => _base.forEach(action);

  @override
  bool get isEmpty => _base.isEmpty;

  @override
  bool get isNotEmpty => _base.isNotEmpty;

  @override
  Iterator<T> get iterator => _base.iterator;

  @override
  String join([String separator = ""]) => _base.join(separator);

  @override
  T get last => _base.last;

  @override
  T lastWhere(bool Function(T element) test, {T Function()? orElse}) =>
      _base.lastWhere(
        test,
        orElse: orElse,
      );

  @override
  int get length => _base.length;

  @override
  Iterable<T1> map<T1>(T1 Function(T e) toElement) => _base.map(toElement);

  @override
  T reduce(T Function(T value, T element) combine) => _base.reduce(combine);

  @override
  T get single => _base.single;

  @override
  T singleWhere(
    bool Function(T element) test, {
    T Function()? orElse,
  }) =>
      _base.singleWhere(
        test,
        orElse: orElse,
      );

  @override
  Iterable<T> skip(int count) => _base.skip(count);

  @override
  Iterable<T> skipWhile(bool Function(T value) test) => _base.skipWhile(test);

  @override
  Iterable<T> take(int count) => _base.take(count);

  @override
  Iterable<T> takeWhile(bool Function(T value) test) => _base.takeWhile(test);

  @override
  List<T> toList({bool growable = true}) => _base.toList(growable: growable);

  @override
  Set<T> toSet() => _base.toSet();

  @override
  Iterable<T> where(bool Function(T element) test) => _base.where(test);

  @override
  Iterable<T> whereType<T>() => _base.whereType();

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CollectionValueNotifier<T>')}{$_base}';
}

class ListQueueValueNotifier<T> extends QueueValueNotifier<T> {
  ListQueueValueNotifier._(ListQueue<T> value) : super._(value);
  factory ListQueueValueNotifier([int? initialCapacity]) =>
      ListQueueValueNotifier._(ListQueue(initialCapacity));
  factory ListQueueValueNotifier.of(Iterable<T> elements) =>
      ListQueueValueNotifier._(ListQueue.of(elements));
}

class DoubleLinkedQueueValueNotifier<T> extends QueueValueNotifier<T> {
  DoubleLinkedQueueValueNotifier._(DoubleLinkedQueue<T> value) : super._(value);
  factory DoubleLinkedQueueValueNotifier([int? initialCapacity]) =>
      DoubleLinkedQueueValueNotifier._(DoubleLinkedQueue());
  factory DoubleLinkedQueueValueNotifier.of(Iterable<T> elements) =>
      DoubleLinkedQueueValueNotifier._(DoubleLinkedQueue.of(elements));
}

abstract class QueueValueNotifier<T>
    extends CollectionValueNotifier<T, Queue<T>, Iterable<T>>
    implements Queue<T> {
  QueueValueNotifier._(Queue<T> base) : super(base);
  factory QueueValueNotifier() = ListQueueValueNotifier<T>;
  factory QueueValueNotifier.of(Iterable<T> elements) =
      ListQueueValueNotifier<T>.of;

  @override
  Iterable<T> _wrap(Queue<T> iterable) => iterable;

  // TODO
  Queue<T1> cast<T1>() => _base.cast();

  //
  // Mutating metohds.
  //

  @override
  void add(T value) {
    _base.add(value);
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    _base.addAll(iterable);
    notifyListeners();
  }

  @override
  void addFirst(T value) {
    _base.addFirst(value);
    notifyListeners();
  }

  @override
  void addLast(T value) {
    _base.addLast(value);
    notifyListeners();
  }

  @override
  void clear() {
    _base.clear();
    notifyListeners();
  }

  @override
  bool remove(Object? value) {
    final didRemove = _base.remove(value);
    if (didRemove) {
      notifyListeners();
    }
    return didRemove;
  }

  @override
  T removeFirst() {
    final v = _base.removeFirst();
    notifyListeners();
    return v;
  }

  @override
  T removeLast() {
    final v = _base.removeLast();
    notifyListeners();
    return v;
  }

  @override
  void removeWhere(bool Function(T element) test) {
    _base.removeWhere(test);
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(T element) test) {
    _base.retainWhere(test);
    notifyListeners();
  }
}

abstract class SetValueNotifier<T>
    extends CollectionValueNotifier<T, Set<T>, UnmodifiableSetView<T>>
    implements Set<T> {
  SetValueNotifier._(Set<T> base) : super(base);
  factory SetValueNotifier() = LinkedHashSetValueNotifier<T>;
  factory SetValueNotifier.identity() = LinkedHashSetValueNotifier<T>.identity;
  factory SetValueNotifier.of(Iterable<T> elements) =
      LinkedHashSetValueNotifier<T>.of;

  @override
  UnmodifiableSetView<T> _wrap(Set<T> iterable) =>
      UnmodifiableSetView(iterable);

  // TODO
  Set<T1> cast<T1>() => _base.cast();

  //
  // Mutating metohds.
  //

  @override
  bool add(T value) {
    final didAdd = _base.add(value);
    if (didAdd) {
      notifyListeners();
    }
    return didAdd;
  }

  @override
  void addAll(Iterable<T> elements) {
    _base.addAll(elements);
    notifyListeners();
  }

  @override
  void clear() {
    _base.clear();
    notifyListeners();
  }

  @override
  bool remove(Object? value) {
    final didRemove = _base.remove(value);
    if (didRemove) {
      notifyListeners();
    }
    return didRemove;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    _base.removeAll(elements);
    notifyListeners();
  }

  @override
  void removeWhere(bool Function(T element) test) {
    _base.removeWhere(test);
    notifyListeners();
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    _base.retainAll(elements);
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(T element) test) {
    _base.retainWhere(test);
    notifyListeners();
  }

  //
  // Non mutating, proxy metohds.
  //

  @override
  bool containsAll(Iterable<Object?> other) => _base.containsAll(other);

  @override
  Set<T> difference(Set<Object?> other) => _base.difference(other);

  @override
  Set<T> intersection(Set<Object?> other) => _base.intersection(other);

  @override
  T? lookup(Object? object) => _base.lookup(object);

  @override
  Set<T> union(Set<T> other) => _base.union(other);
}

class HashSetValueNotifier<T> extends SetValueNotifier<T> {
  HashSetValueNotifier._(HashSet<T> value) : super._(value);

  factory HashSetValueNotifier({
    bool Function(T, T)? equals,
    int Function(T)? hashCode,
    bool Function(dynamic)? isValidKey,
  }) =>
      HashSetValueNotifier._(HashSet(
        equals: equals,
        hashCode: hashCode,
        isValidKey: isValidKey,
      ));
  factory HashSetValueNotifier.identity() =>
      HashSetValueNotifier._(HashSet.identity());
  factory HashSetValueNotifier.of(Iterable<T> elements) =>
      HashSetValueNotifier._(
        HashSet.of(elements),
      );
}

class LinkedHashSetValueNotifier<T> extends SetValueNotifier<T> {
  LinkedHashSetValueNotifier._(LinkedHashSet<T> value) : super._(value);

  factory LinkedHashSetValueNotifier({
    bool Function(T, T)? equals,
    int Function(T)? hashCode,
    bool Function(dynamic)? isValidKey,
  }) =>
      LinkedHashSetValueNotifier._(LinkedHashSet(
        equals: equals,
        hashCode: hashCode,
        isValidKey: isValidKey,
      ));
  factory LinkedHashSetValueNotifier.identity() =>
      LinkedHashSetValueNotifier._(LinkedHashSet.identity());
  factory LinkedHashSetValueNotifier.of(Iterable<T> elements) =>
      LinkedHashSetValueNotifier._(
        LinkedHashSet.of(elements),
      );
}

class SplayTreeSetValueNotifier<T> extends SetValueNotifier<T> {
  SplayTreeSetValueNotifier._(SplayTreeSet<T> value) : super._(value);

  factory SplayTreeSetValueNotifier([
    int Function(T key1, T key2)? compare,
    bool Function(dynamic potentialKey)? isValidKey,
  ]) =>
      SplayTreeSetValueNotifier._(SplayTreeSet(
        compare,
        isValidKey,
      ));
  factory SplayTreeSetValueNotifier.of(Iterable<T> elements,
          [int Function(T key1, T key2)? compare,
          bool Function(dynamic potentialKey)? isValidKey]) =>
      SplayTreeSetValueNotifier._(SplayTreeSet.of(
        elements,
        compare,
        isValidKey,
      ));
}

class ListValueNotifier<T>
    extends CollectionValueNotifier<T, List<T>, UnmodifiableListView<T>>
    implements List<T> {
  ListValueNotifier._(List<T> value) : super(value);
  factory ListValueNotifier.empty() => ListValueNotifier._([]);
  factory ListValueNotifier.filled(int length, T fill) =>
      ListValueNotifier._(List.filled(length, fill));
  factory ListValueNotifier.generate(int length, T Function(int) generator) =>
      ListValueNotifier._(
        List.generate(
          length,
          generator,
        ),
      );
  factory ListValueNotifier.of(Iterable<T> elements) => ListValueNotifier._(
        List.of(elements),
      );

  @override
  UnmodifiableListView<T> _wrap(List<T> list) => UnmodifiableListView(list);

  // TODO
  List<T1> cast<T1>() => _base.cast();

  //
  // Mutating metohds.
  //

  @override
  set length(int value) {
    _base.length = value;
    notifyListeners();
  }

  @override
  void operator []=(int index, T value) {
    _base[index] = value;
    notifyListeners();
  }

  @override
  void addAll(Iterable<T> iterable) {
    _base.addAll(iterable);
    notifyListeners();
  }

  @override
  void insert(int index, T value) {
    _base.insert(index, value);
    notifyListeners();
  }

  @override
  T removeAt(int index) {
    final v = _base.removeAt(index);
    notifyListeners();
    return v;
  }

  @override
  T removeLast() {
    final v = _base.removeLast();
    notifyListeners();
    return v;
  }

  @override
  bool remove(Object? element) {
    final didRemove = _base.remove(value);
    if (didRemove) {
      notifyListeners();
    }
    return didRemove;
  }

  @override
  void removeRange(int start, int end) {
    _base.removeRange(start, end);
    notifyListeners();
  }

  @override
  void removeWhere(bool Function(T element) test) {
    _base.removeWhere(test);
    notifyListeners();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> newContents) {
    _base.replaceRange(start, end, newContents);
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(T element) test) {
    _base.retainWhere(test);
    notifyListeners();
  }

  @override
  void shuffle([Random? random]) {
    _base.shuffle(random);
    notifyListeners();
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    _base.setAll(index, iterable);
    notifyListeners();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    _base.setRange(start, end, iterable, skipCount);
    notifyListeners();
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    _base.sort(compare);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _base.insertAll(index, iterable);
    notifyListeners();
  }

  @override
  void fillRange(int start, int end, [T? fill]) {
    _base.fillRange(start, end, fill);
    notifyListeners();
  }

  @override
  void add(T value) {
    _base.add(value);
    notifyListeners();
  }

  @override
  void clear() {
    _base.clear();
    notifyListeners();
  }

  @override
  set first(T value) {
    _base.first = value;
    notifyListeners();
  }

  @override
  set last(T value) {
    _base.last = value;
    notifyListeners();
  }

  //
  // Non mutating, proxy metohds.
  //

  @override
  T operator [](int index) {
    return _base[index];
  }

  @override
  List<T> operator +(List<T> other) => _base + other;

  @override
  Map<int, T> asMap() => _base.asMap();

  @override
  Iterable<T> getRange(int start, int end) => _base.getRange(start, end);

  @override
  int indexOf(T element, [int start = 0]) => _base.indexOf(element, start);

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) =>
      _base.indexWhere(test, start);

  @override
  int lastIndexOf(T element, [int? start]) => _base.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) =>
      _base.lastIndexWhere(test, start);

  @override
  Iterable<T> get reversed => _base.reversed;

  @override
  List<T> sublist(int start, [int? end]) => _base.sublist(start, end);
}
