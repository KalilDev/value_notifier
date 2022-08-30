import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';

import 'frame.dart';
import 'idisposable_change_notifier.dart';

/// An [ValueListenable] which takes an [Stream] and notifies the values, and
/// throws the errors on it.
class StreamValueListenable<T>
    extends IDisposableValueNotifier<AsyncSnapshot<T>>
    implements DebugValueNotifierOwnershipChainMember {
  final Stream<T> _stream;
  final bool cancelOnError;
  final VoidCallback? onDone;

  StreamValueListenable(
    this._stream, {
    this.cancelOnError = false,
    this.onDone,
    bool eager = false,
  }) : super(eager
            ? const AsyncSnapshot.waiting()
            : const AsyncSnapshot.nothing()) {
    if (eager) {
      _maybeListenToStream();
    }
  }
  bool _didListenToStream = false;

  StreamSubscription<T>? _subs;
  void _maybeListenToStream() {
    if (_didListenToStream) {
      return;
    }
    _didListenToStream = true;
    _subs = _stream.listen(
      _onData,
      onError: _onError,
      cancelOnError: cancelOnError,
      onDone: onDone,
    );
  }

  void pause([Future<void>? resumeSignal]) {
    _maybeListenToStream();
    _subs!.pause(resumeSignal);
  }

  void resume() {
    _maybeListenToStream();
    _subs!.resume();
  }

  bool get isPaused {
    _maybeListenToStream();
    return _subs!.isPaused;
  }

  bool _canceled = false;

  Future<void> cancel() {
    _maybeListenToStream();
    if (_canceled) {
      throw StateError(
          'Tried to cancel an StreamValueListenable more than once!');
    }
    _canceled = true;
    return _subs!.cancel();
  }

  @override
  void addListener(VoidCallback listener) {
    _maybeListenToStream();
    super.addListener(listener);
  }

  bool _disposed = false;

  void _setValue(AsyncSnapshot<T> value) {
    super.value = value;
  }

  @override
  set value(AsyncSnapshot newValue) {
    throw StateError('protected member!');
  }

  void _onData(T value) {
    if (_disposed) {
      return;
    }
    _setValue(AsyncSnapshot.withData(
      ConnectionState.active,
      value,
    ));
  }

  void _onError(Object error, [StackTrace? trace]) {
    _setValue(AsyncSnapshot.withError(
      cancelOnError ? ConnectionState.done : ConnectionState.active,
      error,
      trace ?? StackTrace.current,
    ));
  }

  @override
  void dispose() {
    if (_disposed) {
      throw StateError(
          'Tried to dispose StreamValueListenable more than once!');
    }
    _disposed = true;
    if (!_canceled) {
      _subs!.cancel();
      _canceled = true;
    }
    _subs = null;
    super.dispose();
  }

  @override
  Object get debugOwnershipChainChild => _stream;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'StreamValueListenable');

  @override
  String toString() =>
      '$_stream.toValueListenable(cancelOnError: $cancelOnError, onDone: $onDone){${valueToStringOrUndefined(this)}}';
}
