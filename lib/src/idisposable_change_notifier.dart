import 'package:flutter/foundation.dart';

import 'disposable.dart';

class IDisposableChangeNotifier extends ChangeNotifier implements IDisposable {
  bool _wasDisposed = false;

  @override
  bool get wasDisposed => _wasDisposed;

  @override
  void dispose() {
    super.dispose();
    _wasDisposed = true;
  }
}

class IDisposableValueNotifier<T> extends IDisposableChangeNotifier
    implements IDisposableValueListenable<T> {
  /// Creates a [IDisposableChangeNotifier] that wraps this value.
  IDisposableValueNotifier(this._value);

  /// The current value stored in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  T get value => _value;
  T _value;
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
