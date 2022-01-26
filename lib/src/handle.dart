import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_notifier/src/frame.dart';

import 'disposable.dart';

class ListenableHandle extends ChangeNotifier
    implements IDisposableListenable, DebugValueNotifierOwnershipChainMember {
  Listenable? _base;
  Listenable? get base => _base;

  ListenableHandle(Listenable base) : _base = base;

  bool _didListen = false;
  @override
  void addListener(VoidCallback listener) {
    _maybeListenToBase();
    super.addListener(listener);
  }

  void _maybeListenToBase() {
    if (_didListen) {
      return;
    }
    if (_base == null) {
      throw StateError(
          'Tried to listen to the ValueListenable after calling dispose!');
    }
    _base!.addListener(notifyListeners);
    _didListen = true;
  }

  @override

  /// Dispose without disposing the base, only null out the reference so that it
  /// does not leak, but keep the object alive as we dont own it, we only own a
  /// view to it.
  void dispose() {
    if (_base == null) {
      throw StateError(
          'Tried to call dispose on the ValueListenable more than once!');
    }
    if (_didListen) {
      final base = _base;
      if (base is IDisposable) {
        // Only remove the listener if the base was not disposed.
        final baseCasted = base as IDisposable;
        if (!baseCasted.wasDisposed) {
          base!.removeListener(notifyListeners);
        }
      } else {
        // We cannot know for sure if the base was disposed or not.
        // Remove the listener anyway, but catch flutter errors that would
        // arise in debug mode
        if (kDebugMode) {
          try {
            base!.removeListener(notifyListeners);
          } on FlutterError {
            // ignore
            print('swallowed an object already disposed error');
          }
        } else {
          base!.removeListener(notifyListeners);
        }
      }
      _didListen = false;
    }
    _base = null;
    super.dispose();
  }

  @override
  bool get wasDisposed => _base == null;

  @override
  Object get debugOwnershipChainChild => _base!;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'ListenableHandle', false);
}

/// An handle to an [ValueListenable] which does not take the ownership of the
/// object.
class ValueListenableHandle<T> extends ListenableHandle
    implements IDisposableValueListenable<T> {
  ValueListenableHandle(ValueListenable<T> base) : super(base);

  @override
  T get value => (base as ValueListenable<T>?)!.value;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'ValueListenableHandle', false);
}
