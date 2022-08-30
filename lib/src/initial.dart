import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';
import 'package:value_listenables/src/frame.dart';
import 'package:value_listenables/src/own_handle.dart';

/// An [ValueListenable] which takes an initial value and yields every new value
/// from another [ValueListenable], while taking ownership of it.
class InitialValueListenable<T> extends ValueNotifier<T>
    implements
        IDisposableValueListenable<T>,
        DebugValueNotifierOwnershipChainMember {
  final ValueListenableOwnHandle<T> _base;
  final T? _debugInitial;

  InitialValueListenable(ValueListenable<T> base, T initial)
      : _base = ValueListenableOwnHandle(base),
        _debugInitial = kDebugMode ? initial : null,
        super(initial);
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
    value = _base.value;
  }

  @override
  void dispose() {
    _base.dispose();
    super.dispose();
  }

  @override
  bool get wasDisposed => _base.wasDisposed;

  @override
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'InitialValueListenable');
  @override
  String toString() =>
      '$_base.withInitial($_debugInitial}){${valueToStringOrUndefined(this)}}';
}
