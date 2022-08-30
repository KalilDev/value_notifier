import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';
import 'package:value_listenables/src/frame.dart';

/// An handle to an [Listenable] which takes ownership of the object,
/// disposing it when done.
class ListenableOwnHandle extends IDisposableListenable
    implements DebugValueNotifierOwnershipChainMember {
  Listenable? _base;

  Listenable? get base => _base;

  ListenableOwnHandle(this._base) {
    assert(() {
      final currentOwner = _debugOwner[_base!];
      if (currentOwner != null) {
        throw StateError(
            'Tried to own the Listenable $_base, but it is already '
            'being owned by $currentOwner');
      }
      _debugOwner[_base!] = this;
      return true;
    }());
  }
  static final Expando<ListenableOwnHandle> _debugOwner = Expando();

  @override
  void addListener(VoidCallback listener) => _base!.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _base!.removeListener(listener);

  Object? _debugDisposedBase;

  @override

  /// Dispose the base, remove the current ownership, so that we dont risk
  /// leaking an reference to [this] on debug mode, and null out the base so we
  /// dont leak a reference to it on release, but keeping a reference on
  /// [_debugDisposedBase] in debug mode for easier debugging of unexpected
  /// disposals.
  void dispose() {
    if (_base == null) {
      throw StateError(
          'Tried to dispose an ValueListenableHandle more than once!');
    }
    final base = _base!;
    IDisposable.tryDispose(_base!, () {
      assert(() {
        print('Could not dispose the ValueListener $base, of type '
            '${base.runtimeType}. If you wish it was disposed, wrap the object '
            'in an IDisposable or an ChangeNotifier!');
        return true;
      }());
    });
    assert(() {
      _debugOwner[_base!] = null;
      _debugDisposedBase = _base;
      //print('disposed $_base');
      return true;
    }());
    _base = null;
  }

  @override
  bool get wasDisposed => _base == null;

  @override
  Object get debugOwnershipChainChild => _debugDisposedBase ?? _base!;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame.handle(this, 'ListenableOwnHandle');
}

/// An handle to an [ValueListenable] which takes ownership of the object,
/// disposing it when done.
class ValueListenableOwnHandle<T> extends ListenableOwnHandle
    implements IDisposableValueListenable<T> {
  @override
  ValueListenable<T>? get base => super.base as ValueListenable<T>?;

  ValueListenableOwnHandle(ValueListenable<T> base) : super(base);

  @override
  T get value => TraceableValueNotifierException.tryReturn(
      () => BaseAlreadyDisposedException.checkNotDisposed(
            base,
            _debugDisposedBase as ValueListenable<T>?,
            this,
          ).value,
      this);

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'ValueListenableOwnHandle');

  @override
  String toString() =>
      '${_debugDisposedBase ?? _base}.takeOwnership(){${valueToStringOrUndefined(this)}}';
}
