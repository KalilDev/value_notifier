import 'package:flutter/foundation.dart';
import 'package:value_listenables/src/disposable.dart';
import 'package:value_listenables/src/frame.dart';

import 'idisposable_change_notifier.dart';
import 'own_handle.dart';

/// An [ValueListenable] which performs the monadic bind operation to another
/// [ValueListenable], while taking the ownership of it and the bound objects.
class BoundValueListenable<T, T1> extends IDisposableChangeNotifier
    implements
        IDisposableValueListenable<T1>,
        DebugValueNotifierOwnershipChainMember {
  BoundValueListenable(
      ValueListenable<T> base, this._mapper, this._canBindEagerly)
      : _base = ValueListenableOwnHandle(base);

  final ValueListenableOwnHandle<T> _base;
  final ValueListenable<T1> Function(T) _mapper;
  final bool _canBindEagerly;

  void _onMapped() {
    notifyListeners();
  }

  void _onBase() {
    _listenToMapped(
      _mapper(_base.value),
      true,
    );
  }

  void _listenToMapped(ValueListenable<T1> newMapped, bool notify) {
    if (newMapped == _activeMapped?.base) {
      return;
    }
    if (_activeMapped != null) {
      _activeMapped!.removeListener(_onMapped);
      _activeMapped!.dispose();
    }
    assert(_activeMapped?.wasDisposed ?? true);
    assert(
        newMapped is! IDisposable || !((newMapped as IDisposable).wasDisposed));
    _activeMapped = ValueListenableOwnHandle(newMapped);
    _activeMapped!.addListener(_onMapped);
    if (wasDisposed) {
      return;
    }
    if (notify) {
      notifyListeners();
    }
  }

  var _isBaseBeingListened = false;

  void _listenIfNeeded() {
    if (_isBaseBeingListened) {
      return;
    }
    _base.addListener(_onBase);
    _isBaseBeingListened = true;
    if (_canBindEagerly) {
      _ensureMappedIsActive(_mapper(_base.value));
    }
  }

  bool _didAddListeners = false;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _didAddListeners = true;
    _listenIfNeeded();
  }

  void _ensureMappedIsActive(ValueListenable<T1> mapped) {
    // because of the nature of the synchronous code around valueListenable, we
    // may be called to listen on a mapped object after meing disposed.
    if (wasDisposed) {
      return;
    }
    _listenToMapped(mapped, false);
  }

  ValueListenableOwnHandle<T1>? _activeMapped;

  @override
  T1 get value {
    if (_activeMapped == null) {
      // Call the mapper directly so that we do not listen to the object, as
      // calling value without disposing the object would leak the [_mapped]
      // object.
      return TraceableValueNotifierException.tryReturn(
              () => _mapper(_base.value), this)
          .value;
    }
    // Do not call the mapper directly, because calling it may produce mapped
    // objects that are unique but must be called only once per base
    // notification, which is handled by _onBase and _onMapped.
    return _activeMapped!.value;
  }

  @override
  void dispose() {
    _activeMapped?.dispose();
    _base.dispose();
    super.dispose();
  }

  @override
  // TODO: base and mapped!
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'BoundValueListenable');

  @override
  String toString() =>
      '$_base.bind($_mapper){${valueToStringOrUndefined(this)}}';
}
