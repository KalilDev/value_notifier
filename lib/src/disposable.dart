import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

abstract class IInitable {
  @mustCallSuper
  void init();
}

abstract class IInitAndDispose implements IInitable, IDisposable {
  static T create<T extends IInitAndDispose>(
    T Function() factory, {
    bool init = true,
  }) {
    final object = factory();
    if (init) {
      object.init();
    }
    return object;
  }
}

class IDisposableAlreadyDisposedException implements Exception {
  final IDisposable? disposed;

  const IDisposableAlreadyDisposedException(this.disposed);
  static T checkNotDisposed<T>(
    T object,
  ) =>
      object is IDisposable
          ? object.wasDisposed
              ? (throw IDisposableAlreadyDisposedException(object))
              : object
          : object;

  @override
  String toString() =>
      '$runtimeType: The object $disposed was already disposed before usage';
}

class IInitAndDisposeBase = Object with IInitableMixin, IDisposableMixin;

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

  /// Return a [IDisposable] that does not do anything.
  static IDisposable none() => _NoneIDisposable();
}

class _NoneIDisposable extends IDisposableBase {}

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

abstract class IDisposableBase = Object with IDisposableMixin;

mixin IInitableMixin implements IInitable {
  bool _wasInited = false;

  @override
  void init() {
    assert(!_wasInited);
    _wasInited = true;
  }
}

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
