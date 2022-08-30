import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';

import 'frame.dart';
import 'idisposable_change_notifier.dart';
import 'own_handle.dart';
import 'where.dart';

/// An [ValueListenable] which filters the notifications according to the
/// provided [Predicate], keeping the previous value that complies with it.
class WhereKeepingPreviousValueListenable<T> extends IDisposableValueNotifier<T>
    implements DebugValueNotifierOwnershipChainMember {
  final Predicate<T> _predicate;
  final ValueListenableOwnHandle<T> _base;
  final T Function() initial;
  WhereKeepingPreviousValueListenable(
    ValueListenable<T> base,
    this._predicate, {
    required this.initial,
  })  : _base = ValueListenableOwnHandle(base),
        super(_predicate(base.value) ? base.value : initial());

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
      ValueNotifierOwnershipFrame(this, 'WhereKeepingPreviousValueListenable');

  @override
  String toString() =>
      '$_base.whereKeepingPrevious($_predicate, initial: $initial){${valueToStringOrUndefined(this)}}';
}
