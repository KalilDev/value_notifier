import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';

import 'frame.dart';

class SingleValueListenable<T> extends IDisposableValueListenable<T>
    implements DebugValueNotifierOwnershipChainMember {
  SingleValueListenable(this._value);
  T? _value;
  bool _wasDisposed = false;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override

  /// Null out the reference to the [_value] to avoid leakage.
  void dispose() {
    assert(!_wasDisposed);
    _value = null;
    _wasDisposed = true;
  }

  @override
  T get value =>
      TraceableValueNotifierException.tryReturn(() => _value as T, this);

  @override
  bool get wasDisposed => _wasDisposed;

  @override
  Object get debugOwnershipChainChild => value as Object;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'SingleValueListenable');

  @override
  String toString() =>
      '$value.toValueListenable(){${valueToStringOrUndefined(this)}}';
}
