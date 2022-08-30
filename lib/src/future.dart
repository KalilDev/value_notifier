import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';
import 'package:value_listenables/src/frame.dart';

import 'idisposable_change_notifier.dart';

/// An [ValueListenable] which takes an [Future] and notifies the completed value
/// and throws when it fails.
class FutureValueListenable<T>
    extends IDisposableValueNotifier<AsyncSnapshot<T>>
    implements DebugValueNotifierOwnershipChainMember {
  final Future<T> _future;

  FutureValueListenable(
    this._future, {
    bool eager = false,
  }) : super(eager
            ? const AsyncSnapshot.waiting()
            : const AsyncSnapshot.nothing()) {
    if (eager) {
      _maybeListenToFuture();
    }
  }

  bool _didListenToFuture = false;

  void _maybeListenToFuture() {
    if (_didListenToFuture) {
      return;
    }
    _didListenToFuture = true;
    _setValue(value.inState(ConnectionState.waiting));
    _future.then(_onValue).catchError(_onError);
  }

  void listenToFuture() => _maybeListenToFuture();

  @override
  void addListener(VoidCallback listener) {
    _maybeListenToFuture();
    super.addListener(listener);
  }

  bool _disposed = false;

  void _onValue(T result) {
    if (_disposed) {
      return;
    }
    _setValue(AsyncSnapshot.withData(
      ConnectionState.done,
      result,
    ));
  }

  void _setValue(AsyncSnapshot<T> value) {
    super.value = value;
  }

  @override
  set value(AsyncSnapshot<T> newValue) {
    throw StateError('protected member!');
  }

  void _onError(Object error, [StackTrace? trace]) {
    _setValue(AsyncSnapshot.withError(
      ConnectionState.done,
      error,
      trace ?? StackTrace.current,
    ));
  }

  @override
  void dispose() {
    if (_disposed) {
      throw StateError(
          'Tried to dispose FutureValueListenable more than once!');
    }
    _disposed = true;
    super.dispose();
  }

  @override
  Object get debugOwnershipChainChild => _future;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'FutureValueListenable');

  @override
  String toString() =>
      '$_future.toValueListenable(){${valueToStringOrUndefined(this)}}';
}
