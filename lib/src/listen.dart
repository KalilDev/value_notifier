import 'package:flutter/material.dart';
import 'package:value_notifier/src/frame.dart';
import 'package:value_notifier/src/handle.dart';

import 'disposable.dart';
import 'own_handle.dart';

class ListenerListenable extends IDisposableListenable
    implements DebugValueNotifierOwnershipChainMember {
  final IDisposableListenable _base;
  final VoidCallback _callback;

  ListenerListenable(
    Listenable base,
    this._callback, {
    bool tapInitial = false,
    bool takeOwnership = false,
  }) : _base =
            takeOwnership ? ListenableOwnHandle(base) : ListenableHandle(base) {
    if (tapInitial) {
      _onChange();
    }
    _base.addListener(_onChange);
  }

  @override
  void addListener(VoidCallback listener) => _base.addListener(listener);

  void _onChange() {
    _callback();
  }

  @override
  void dispose() {
    _base.removeListener(_onChange);
    _base.dispose();
  }

  @override
  void removeListener(VoidCallback listener) => _base.removeListener(listener);

  @override
  bool get wasDisposed => _base.wasDisposed;

  @override
  Object get debugOwnershipChainChild => _base;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'ListenerListenable');
}
