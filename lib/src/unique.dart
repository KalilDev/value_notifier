import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';
import 'package:value_listenables/src/frame.dart';
import 'package:value_listenables/src/own_handle.dart';

import 'idisposable_change_notifier.dart';

typedef Equals<T> = bool Function(T, T);

/// An [ValueListenable] which takes another [ValueListenable] and dedupes the
/// notifications according to the provided [Equals] function.
class UniqueValueListenable<T> extends IDisposableValueNotifier<T>
    implements DebugValueNotifierOwnershipChainMember {
  final ValueListenableOwnHandle<T> _base;
  final Equals<T> _equals;
  UniqueValueListenable(
    ValueListenable<T> base, [
    this._equals = defaultEquals,
  ])  : _base = ValueListenableOwnHandle(base),
        super(base.value);

  static bool defaultEquals(Object? a, Object? b) => a == b;

  bool _didListenToBase = false;
  void _maybeListenToBase() {
    if (_didListenToBase) {
      return;
    }
    _didListenToBase = true;
    _base.addListener(_onBase);
  }

  @override
  void addListener(VoidCallback listener) {
    _maybeListenToBase();
    super.addListener(listener);
  }

  void _onBase() {
    if (_equals(value, _base.value)) {
      return;
    }
    value = _base.value;
  }

  @override
  void dispose() {
    _base.dispose();
    super.dispose();
  }

  @override
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'UniqueValueListenable');

  @override
  String toString() =>
      '$_base.unique(${_equals == defaultEquals ? '' : '$_equals'}){${valueToStringOrUndefined(this)}}';
}
