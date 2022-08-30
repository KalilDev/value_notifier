import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';

import 'frame.dart';
import 'idisposable_change_notifier.dart';
import 'own_handle.dart';

typedef Predicate<T> = bool Function(T);

/// An [ValueListenable] which filters the notifications according to the
/// provided [Predicate], discarding the non-conforming values
class WhereValueListenable<T> extends IDisposableValueNotifier<T?>
    implements DebugValueNotifierOwnershipChainMember {
  final Predicate<T> _predicate;
  final ValueListenableOwnHandle<T> _base;
  final T? onFalse;

  WhereValueListenable(
    ValueListenable<T> base,
    this._predicate, {
    this.onFalse,
  })  : _base = ValueListenableOwnHandle(base),
        super(_predicate(base.value) ? base.value : onFalse);

  bool _didListenToBase = false;
  void _maybeListenToBase() {
    if (_didListenToBase) {
      return;
    }
    _didListenToBase = true;
    _base.addListener(_onBase);
  }

  void _onBase() {
    if (!_predicate(_base.value)) {
      value = onFalse;
      return;
    }
    value = _base.value;
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
      ValueNotifierOwnershipFrame(this, 'WhereValueListenable');

  @override
  String toString() =>
      '$_base.where($_predicate}){${valueToStringOrUndefined(this)}}';
}
