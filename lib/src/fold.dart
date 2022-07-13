import 'package:flutter/foundation.dart';

import 'frame.dart';
import 'idisposable_change_notifier.dart';
import 'own_handle.dart';

/// An [ValueListenable] which filters the notifications according to the
/// provided [Predicate], keeping the previous value that complies with it.
class FoldValueListenable<T, T1> extends IDisposableValueNotifier<T1>
    implements DebugValueNotifierOwnershipChainMember {
  final ValueListenableOwnHandle<T> _base;
  final T1 initial;
  final T1 Function(T1, T) _fold;
  FoldValueListenable(ValueListenable<T> base, this.initial, this._fold)
      : _base = ValueListenableOwnHandle(base),
        super(initial);

  bool _didListenToBase = false;
  void _maybeListenToBase() {
    if (_didListenToBase) {
      return;
    }
    _didListenToBase = true;
    _base.addListener(_onBase);
  }

  void _onBase() {
    value = _fold(value, _base.value);
  }

  @override
  void addListener(VoidCallback listener) {
    _maybeListenToBase();
    super.addListener(listener);
  }

  @override
  void dispose() {
    if (_didListenToBase) {
      _didListenToBase = false;
      _base.dispose();
    }
    super.dispose();
  }

  @override
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'FoldValueListenable');

  @override
  String toString() =>
      '$_base.fold($initial, fn){${valueToStringOrUndefined(this)}}';
}
