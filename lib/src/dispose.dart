import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/frame.dart';
import 'package:value_listenables/src/handle.dart';

import '../value_listenables.dart';
import 'own_handle.dart';

abstract class IDisposableValueListenableProxyBase<T> extends IDisposableBase
    with DebugValueNotifierOwnershipChainMember
    implements IDisposableListenable {
  final ValueListenableOwnHandle<T> _base;

  IDisposableValueListenableProxyBase(ValueListenable<T> base)
      : _base = ValueListenableOwnHandle(base);

  T get baseValue =>
      TraceableValueNotifierException.tryReturn(() => _base.value, this);

  @override
  Object? get debugOwnershipChainChild => _base;

  @override
  void addListener(VoidCallback listener) => _base.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _base.removeListener(listener);

  @override
  void dispose() {
    _base.dispose();
    super.dispose();
  }
}

class AndDisposeValueListenable<T>
    extends IDisposableValueListenableProxyBase<T>
    implements IDisposableValueListenable<T> {
  final Object _toBeDisposed;

  AndDisposeValueListenable(ValueListenable<T> base, this._toBeDisposed)
      : super(base);

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'AndDisposeValueListenable');

  @override
  T get value => baseValue;

  @override
  void dispose() {
    IDisposable.disposeObj(_toBeDisposed);
    super.dispose();
  }
}

class AndDisposeAllValueListenable<T>
    extends IDisposableValueListenableProxyBase<T>
    implements IDisposableValueListenable<T> {
  final List<Object> _toBeDisposed;

  AndDisposeAllValueListenable(
      ValueListenable<T> base, Iterable<Object> toBeDisposed)
      : _toBeDisposed = toBeDisposed.toList(),
        super(base);

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'AndDisposeValueListenable');

  @override
  T get value => baseValue;

  @override
  void dispose() {
    IDisposable.disposeAll(_toBeDisposed);
    super.dispose();
  }
}
