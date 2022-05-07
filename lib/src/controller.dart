import 'package:flutter/material.dart';

import 'disposable.dart';
import 'package:flutter/foundation.dart';
import 'proxy.dart';
import 'event_notifier.dart';

/// An handle to an controller, which is used to signal to the classes that
/// use it, that they do not own the controller being passed to them.
///
/// This handle provides NO guarantees, only an api which communicates the
/// intent and ownership model via the types.
class ControllerHandle<T extends ControllerBase<T>> {
  const ControllerHandle(this.unwrap);

  final T unwrap;

  @override
  int get hashCode => unwrap.hashCode;

  @override
  bool operator ==(other) {
    if (identical(other, this)) {
      return true;
    }
    if (other is ControllerHandle<T>) {
      return unwrap == other.unwrap;
    }
    return false;
  }
}

/// An controller that is [IDisposable] has an [init] method and follows the
/// following contract:
/// - State or actions that will be used outside of this controller will be
///   exposed via [ValueListenable] objects which do not own the state or any
///   underlying resource in the controller.
/// - Every [ValueListenable] exposed must not be owned by anyone else,
///   therefore, the caller of an getter will hold exclusive ownership to the
///   returned [ValueListenable]
/// - Owns every object it exposes via [ValueListenable]s.
/// - Owns every object it uses.
/// - Do not perform actions on other controllers which are not direct children.
/// - Disposes everything it owns.
/// - States exposed via [ValueListenable] objects are referentially
///   transparent. Those with side effects must be wrapped and managed
///   internally and an safe api must be exposed. This can be achieved with one
///   of:
///   * late final stateful [ValueListenable]s while exposing an view getter.
///   * [ProxyValueListenable] being managed internally while exposing an view
///     getter.
///   * Using an [ValueNotifier] and manually updating it, while exposing an
///     view getter. (Not recommended as this is an very imperative api, this
///     contract is put in place to encourage declarative controllers).
///
/// To ensure an consistent usage of this api, try creating the controller
/// classes with the members in the following order:
/// 1. Final fields, preferrably in the order: [ValueNotifier],
///    [EventNotifier], [ActionNotifier], [ControllerBase] and other objects.
/// 2. Public constructors
/// 3. Public subcontroller handle getters
/// 3. Public view getters to the fields
/// 4. Public composed getters (which use map, bind, where, etc...)
/// 5. Public methods for interacting with the controller
/// 6. [init] and [dispose] overrides
/// 7. Private implementation details in any sensible order
abstract class ControllerBase<Self extends ControllerBase<Self>>
    extends IDisposableBase
    with DebugChildManagerMixin, DebugSingleOwnerManagerMixin {
  ControllerBase() {
    assert(this is Self);
  }
  static T create<T extends ControllerBase<T>>(
    T Function() factory, {
    void Function(T)? registerPreInit,
    void Function(T)? register,
    bool init = true,
  }) {
    final controller = factory();
    registerPreInit?.call(controller);
    if (init) {
      controller.init();
    }
    register?.call(controller);
    return controller;
  }

  @mustCallSuper
  void init() {}

  @override
  void dispose() {
    disposeParentManager();
    disposeChildManager();
    super.dispose();
  }

  late final ControllerHandle<Self> handle = ControllerHandle(this as Self);

  @override
  T addChild<T extends DebugSingleOwnerManagerMixin>(T child) {
    assert(child is! SubcontrollerBase, 'Use addSubcontroller');
    return defaultAddChild(child);
  }

  @override
  T removeChild<T extends DebugSingleOwnerManagerMixin>(T child) {
    assert(child is! SubcontrollerBase, 'Use addSubcontroller');
    return defaultRemoveChild(child);
  }

  T addSubcontroller<T extends SubcontrollerBase<Self, T>>(T child) =>
      defaultAddChild(child);

  T removeSubcontroller<T extends SubcontrollerBase<Self, T>>(T child) =>
      defaultRemoveChild(child);
}

typedef DebugOwnershipRootMixin = DebugChildManagerMixin;
typedef DebugOwnershipLeafMixin = DebugSingleOwnerManagerMixin;

abstract class IHaveAnSingleOwner {}

abstract class IHaveChildren<ChildBaseType> {
  @protected
  T addChild<T extends ChildBaseType>(T child);

  @protected
  T removeChild<T extends ChildBaseType>(T child);
}

mixin DebugSingleOwnerManagerMixin on IDisposable
    implements IHaveAnSingleOwner {
  bool? _debugParentManagerDisposed = kDebugMode ? false : null;
  Object? _debugParent;
  bool _debugSetParent(Object parent) {
    assert(_debugParentManagerDisposed != true && _debugParent == null);
    return true;
  }

  bool _debugRemoveParent(Object parent) {
    assert(_debugParentManagerDisposed != true && _debugParent == parent);
    assert(() {
      _debugParent = null;
      return true;
    }());
    return true;
  }

  void disposeParentManager() {
    assert(_debugParentManagerDisposed != true && _debugParent != null);
    assert(() {
      _debugParent = null;
      _debugParentManagerDisposed = true;
      return true;
    }());
  }
}
mixin DebugChildManagerMixin<ChildBaseType extends DebugSingleOwnerManagerMixin>
    implements IHaveChildren<ChildBaseType> {
  bool? _debugChildManagerDisposed = kDebugMode ? false : null;
  final List<ChildBaseType>? _debugChildren = kDebugMode ? [] : null;
  @override
  T defaultAddChild<T extends ChildBaseType>(T child) {
    assert(!_debugChildren!.contains(child));
    assert(child._debugSetParent(this));
    assert(() {
      _debugChildren!.add(child);
      return true;
    }());
    return child;
  }

  T defaultRemoveChild<T extends ChildBaseType>(T child) {
    assert(_debugChildren!.contains(child));
    assert(child._debugRemoveParent(this));
    assert(() {
      _debugChildren!.remove(child);
      return true;
    }());
    return child;
  }

  void disposeChildManager() {
    assert(!_debugChildManagerDisposed!);
    assert(
        _debugChildren!.every((child) => child._debugParentManagerDisposed!));
    assert(_debugChildren!.every((child) => child.wasDisposed));
    assert(_debugChildManagerDisposed = true);
  }
}

// An controller base for controllers that only exist inside the [Parent]
abstract class SubcontrollerBase<Parent extends ControllerBase<Parent>,
    Self extends SubcontrollerBase<Parent, Self>> extends ControllerBase<Self> {
  Parent? get _debugParent => super._debugParent as Parent?;
  set _debugParent(Object? parent) {
    assert(parent is Parent?);
    _debugParent = parent as Parent?;
  }
}
