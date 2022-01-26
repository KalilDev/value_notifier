import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

abstract class IDisposable {
  bool get wasDisposed;
  @mustCallSuper
  void dispose();

  /// Return a [IDisposable] that disposes every value in [disposables] when
  /// disposed.
  ///
  /// The list must not be changed after this method has been called. Doing so
  /// will lead to memory leaks, exceptions or hanging resources.
  static MergingIDisposable merge(List<Object> disposables) =>
      MergingIDisposable(disposables);

  static void disposeAll(List<Object> objects) {
    for (final object in objects) {
      disposeObj(object);
    }
  }

  static void disposeObj(Object object) {
    if (object is ChangeNotifier) {
      object.dispose();
    } else if (object is IDisposable) {
      object.dispose();
    }
  }

  static void tryDispose(Object object, VoidCallback onFail) {
    if (object is ChangeNotifier) {
      object.dispose();
    } else if (object is IDisposable) {
      object.dispose();
    } else {
      onFail();
    }
  }
}

class MergingIDisposable extends IDisposableBase {
  final List<Object> _disposables;

  MergingIDisposable._(this._disposables);
  factory MergingIDisposable(Iterable<Object> disposables) =>
      MergingIDisposable._(List.from(disposables));

  void add(Object disposable) => _disposables.add(disposable);

  @override
  void dispose() {
    IDisposable.disposeAll(_disposables);
    super.dispose();
  }
}

class IDisposableBase = Object with IDisposableMixin;

mixin IDisposableMixin implements IDisposable {
  bool _wasDisposed = false;

  @override
  bool get wasDisposed => _wasDisposed;

  @override
  void dispose() {
    assert(!_wasDisposed);
    _wasDisposed = true;
  }
}

abstract class IDisposableValueListenable<T>
    implements ValueListenable<T>, IDisposableListenable {}

abstract class IDisposableListenable implements Listenable, IDisposable {}
