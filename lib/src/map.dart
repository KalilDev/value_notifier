import 'package:flutter/foundation.dart';
import 'package:value_notifier/src/frame.dart';

import 'disposable.dart';
import 'own_handle.dart';

/// An [ValueListenable] which maps the values in another [ValueListenable] and
/// takes ownership of it.
class MappedValueListenable<T, T1>
    implements
        IDisposableValueListenable<T1>,
        DebugValueNotifierOwnershipChainMember {
  MappedValueListenable(
    ValueListenable<T> base,
    this._mapper,
  ) : _base = ValueListenableOwnHandle(base);

  final ValueListenableOwnHandle<T> _base;
  final T1 Function(T) _mapper;

  @override
  void addListener(VoidCallback listener) => _base.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _base.removeListener(listener);

  @override
  T1 get value => _mapper(_base.value);

  @override
  void dispose() {
    _base.dispose();
  }

  @override
  bool get wasDisposed => _base.wasDisposed;

  @override
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'MappedValueListenable');
}
