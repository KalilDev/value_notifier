import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_listenables/src/disposable.dart';
import 'package:value_listenables/src/frame.dart';
import 'package:value_listenables/src/own_handle.dart';

/// An [ValueListenable] which takes an [ValueListenable] to an nullable type
/// and yields an default value when it is null. Also takes ownership to the
/// parent [ValueListenable].
class DefaultValueListenable<T> extends IDisposableValueListenable<T>
    implements DebugValueNotifierOwnershipChainMember {
  final T _defaultValue;
  final ValueListenableOwnHandle<T?> _base;

  DefaultValueListenable(
    ValueListenable<T?> base,
    this._defaultValue,
  ) : _base = ValueListenableOwnHandle(base);

  @override
  void addListener(VoidCallback listener) => _base.addListener(listener);
  @override
  void removeListener(VoidCallback listener) => _base.removeListener(listener);

  @override
  T get value => TraceableValueNotifierException.tryReturn(
      () => _base.value ?? _defaultValue, this);

  @override
  void dispose() => _base.dispose();

  @override
  bool get wasDisposed => _base.wasDisposed;

  @override
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'DefaultValueListenable');

  @override
  String toString() =>
      '$_base.withDefault($_defaultValue){${valueToStringOrUndefined(this)}}';
}
