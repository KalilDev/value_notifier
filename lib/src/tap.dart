import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_notifier/src/disposable.dart';
import 'package:value_notifier/src/frame.dart';
import 'package:value_notifier/src/own_handle.dart';

class TappedValueListenable<T> extends IDisposableValueListenable<T>
    implements DebugValueNotifierOwnershipChainMember {
  final ValueListenableOwnHandle<T> _base;
  final ValueChanged<T> _callback;

  TappedValueListenable(
    ValueListenable<T> base,
    this._callback, [
    bool tapInitial = false,
  ]) : _base = ValueListenableOwnHandle(base) {
    if (tapInitial) {
      _onChange();
    }
    _base.addListener(_onChange);
  }

  @override
  void addListener(VoidCallback listener) => _base.addListener(listener);

  void _onChange() {
    _callback(_base.value);
  }

  @override
  void dispose() {
    _base.removeListener(_onChange);
    _base.dispose();
  }

  @override
  void removeListener(VoidCallback listener) => _base.removeListener(listener);

  @override
  T get value => _base.value;

  @override
  bool get wasDisposed => _base.wasDisposed;

  @override
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'TappedValueListenable');
}
