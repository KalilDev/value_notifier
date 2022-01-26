import 'package:flutter/foundation.dart';
import 'package:value_notifier/src/disposable.dart';
import 'package:value_notifier/src/frame.dart';

import 'idisposable_change_notifier.dart';
import 'own_handle.dart';

/// An [ValueListenable] which performs the monadic bind operation to another
/// [ValueListenable], while taking the ownership of it and the bound objects.
class BoundValueListenable<T, T1> extends IDisposableChangeNotifier
    implements
        IDisposableValueListenable<T1>,
        DebugValueNotifierOwnershipChainMember {
  BoundValueListenable(ValueListenable<T> base, this._mapper)
      : _base = ValueListenableOwnHandle(base);

  final ValueListenableOwnHandle<T> _base;
  final ValueListenable<T1> Function(T) _mapper;

  void _onMapped() {
    notifyListeners();
  }

  void _onBase() {
    _listenToMapped(_mapper(_base.value));
  }

  void _listenToMapped(ValueListenable<T1> newMapped) {
    if (newMapped == _mapped?.base) {
      return;
    }
    if (_mapped != null) {
      _mapped!.removeListener(_onMapped);
      _mapped!.dispose();
    }
    _mapped = ValueListenableOwnHandle(newMapped);
    newMapped.addListener(_onMapped);
    notifyListeners();
  }

  var _isBaseBeingListened = false;

  void _listenIfNeeded() {
    if (_isBaseBeingListened) {
      return;
    }
    _base.addListener(_onBase);
    _isBaseBeingListened = true;
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _listenIfNeeded();
  }

  ValueListenableOwnHandle<T1>? _mapped;

  void _ensureMapped() {
    if (_mapped != null) {
      return;
    }
    _listenToMapped(_mapper(_base.value));
  }

  @override
  T1 get value {
    _ensureMapped();
    return _mapped!.value;
  }

  @override
  void dispose() {
    _mapped?.dispose();
    _base.dispose();
    super.dispose();
  }

  @override
  // TODO: base and mapped!
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'BoundValueListenable');
}
