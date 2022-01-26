import 'package:flutter/foundation.dart';
import 'package:value_notifier/src/disposable.dart';
import 'package:value_notifier/src/frame.dart';
import 'package:value_notifier/src/own_handle.dart';

/// An [ValueListenable] which casts another [ValueListenable]'s value to the
/// type [T1], and takes the ownership of the parent [ValueListenable].
class CastValueListenable<T, T1> extends IDisposableValueListenable<T1>
    implements IDisposable, DebugValueNotifierOwnershipChainMember {
  final ValueListenableOwnHandle<T> _base;

  CastValueListenable(ValueListenable<T> base)
      : _base = ValueListenableOwnHandle(base);

  @override
  void addListener(VoidCallback listener) => _base.addListener(listener);

  @override
  void dispose() => _base.dispose();

  @override
  void removeListener(VoidCallback listener) => _base.removeListener(listener);

  @override
  T1 get value => _base.value as T1;

  @override
  bool get wasDisposed => _base.wasDisposed;

  @override
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'CastValueListenable');
}
