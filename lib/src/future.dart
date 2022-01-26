import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:value_notifier/src/disposable.dart';
import 'package:value_notifier/src/frame.dart';

import 'idisposable_change_notifier.dart';

/// An [ValueListenable] which takes an [Future] and notifies the completed value
/// and throws when it fails.
class FutureValueListenable<T> extends IDisposableValueNotifier<T?>
    implements DebugValueNotifierOwnershipChainMember {
  final Future<T> _future;

  FutureValueListenable(this._future) : super(null);
  bool _didListenToFuture = false;

  void _maybeListenToFuture() {
    if (_didListenToFuture) {
      return;
    }
    _didListenToFuture = true;
    _future.then(_onValue).catchError(_onError);
  }

  @override
  void addListener(VoidCallback listener) {
    _maybeListenToFuture();
    super.addListener(listener);
  }

  bool _disposed = false;

  void _onValue(T value) {
    if (_disposed) {
      return;
    }
    this.value = value;
  }

  void _onError(Object error, [StackTrace? trace]) {
    Error.throwWithStackTrace(error, trace ?? StackTrace.current);
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
}
