import 'dart:async';

import 'package:flutter/foundation.dart';
import 'frame.dart';

import 'idisposable_change_notifier.dart';
import 'own_handle.dart';

class _CancellableFuture<T> {
  final Future<T> _future;

  _CancellableFuture(this._future) {
    _future.then(_onFutureValue);
  }
  void _onFutureValue(T value) => _callbacks?.forEach((cb) => cb(value));

  List<FutureOr<void> Function(T)>? _callbacks = [];
  void then(FutureOr<void> Function(T) fn) {
    _callbacks?.add(fn);
  }

  void cancel() {
    _callbacks = null;
  }
}

/// An [ValueListenable] which takes another [ValueListenable] and debounces it.
class DebouncedValueNotifier<T> extends IDisposableValueNotifier<T>
    implements DebugValueNotifierOwnershipChainMember {
  final ValueListenableOwnHandle<T> _base;

  /// The time to delay.
  final Duration wait;

  /// Specify invoking on the leading edge of the timeout.
  final bool leading;

  /// The maximum time that is allowed to be delayed before it's notified.
  final Duration? maxWait;

  /// Specify invoking on the trailing edge of the timeout.
  final bool trailing;
  DebouncedValueNotifier(
    ValueListenable<T> base, {
    required this.wait,
    this.leading = false,
    this.maxWait,
    this.trailing = true,
  })  : _base = ValueListenableOwnHandle(base),
        super(base.value);

  static bool defaultEquals(Object? a, Object? b) => a == b;

  DateTime? _bounceStartTime;
  _CancellableFuture<void>? _bounceFuture;
  bool get _isBouncing => _bounceStartTime != null;

  Future<void> get _waitFut => Future.delayed(wait);
  Future<void> get _maxWaitFut =>
      Future.delayed(maxWait! - DateTime.now().difference(_bounceStartTime!));

  void _startBounce() {
    _bounceStartTime = DateTime.now();
    _bounceFuture = _CancellableFuture(Future.any([
      _waitFut,
      if (maxWait != null) _maxWaitFut,
    ]))
      ..then(_onWaitFinish);
    if (leading) {
      value = _base.value;
    }
  }

  void _onResetBounce() {
    _bounceFuture!.cancel();
    _bounceFuture = _CancellableFuture(Future.any([
      _waitFut,
      if (maxWait != null) _maxWaitFut,
    ]))
      ..then(_onWaitFinish);
  }

  void _finishBounce() {
    _bounceStartTime = null;
    _bounceFuture?.cancel();
    _bounceFuture = null;
    if (trailing) {
      value = _base.value;
    }
  }

  void _onWaitFinish(_) {
    _finishBounce();
  }

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
    if (!_isBouncing) {
      _startBounce();
    } else {
      _onResetBounce();
    }
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
      ValueNotifierOwnershipFrame(this, 'DebouncedValueNotifier');

  @override
  String toString() =>
      '$_base.debounced(wait: $wait, maxWait: $maxWait, leading: $leading, trailing: $trailing){${valueToStringOrUndefined(this)}}';
}
