import 'package:flutter/foundation.dart';
import 'package:value_notifier/src/disposable.dart';
import 'package:value_notifier/src/frame.dart';
import 'package:value_notifier/src/own_handle.dart';

import 'idisposable_change_notifier.dart';

class ProxyValueListenable<T> extends IDisposableChangeNotifier
    implements
        IDisposableValueListenable<T>,
        DebugValueNotifierOwnershipChainMember {
  ValueListenableOwnHandle<T> _base;
  ProxyValueListenable(ValueListenable<T> base)
      : _base = ValueListenableOwnHandle(base);

  ValueListenable<T> get base => _base;
  set base(ValueListenable<T> value) {
    if (_base.base == value) {
      return;
    }
    final didValueChange = _base.value != value.value;
    _base.dispose();
    _base = ValueListenableOwnHandle(value);
    if (_hasListeners) {
      _listenToBase();
    }
    if (didValueChange) {
      notifyListeners();
    }
  }

  void _listenToBase() {
    _base.addListener(notifyListeners);
  }

  bool _hasListeners = false;

  @override
  void addListener(VoidCallback listener) {
    if (!_hasListeners) {
      _listenToBase();
    }
    _hasListeners = true;
    super.addListener(listener);
  }

  @override
  void dispose() {
    _base.dispose();
    super.dispose();
  }

  @override
  T get value => _base.value;

  @override
  bool get wasDisposed => _base.wasDisposed;

  @override
  Object? get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(_base, 'ProxyValueListenable');
}
