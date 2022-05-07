import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:value_notifier/src/extensions.dart';

import '../controller.dart';
import '../disposable.dart';
import '../handle.dart';

abstract class ListenableContext implements BuildContext {
  // Use an value listenable from the controller. It **WONT** cause widget updates on change, the passed
  // in object will not be used every time, only in the first build (Which wont matter anyway for
  // performance, as creating them is probably not expensive). The returned value listenable is always
  // an handle, and the lifecycle of the parent object is managed by this context.
  ValueListenableHandle<T> use<T>(ValueListenable<T> fromController);
  // Handle an event from an value listenable. The listener will automatically be changed in
  // each widget build and removed when the context is disposed.
  void useEventHandler<T>(
      ValueListenable<T> fromController, ValueChanged<T> onChange);
  // Handle an action from an value listenable. The listener will automatically be changed in
  // each widget build and removed when the context is disposed.
  void useActionHandler(
      ValueListenable<void> fromController, VoidCallback onAction);
}

abstract class ControllerContext<Controller extends ControllerBase<Controller>>
    implements ListenableContext {
  // Use an value listenable from the controller. It **WONT** cause widget updates on change, the passed
  // in object will not be used every time, only in the first build (Which wont matter anyway for
  // performance, as creating them is probably not expensive). The returned value listenable is always
  // an handle, and the lifecycle of the parent object is managed by this context.
  ValueListenableHandle<T> useLazy<T>(
    ValueListenable<T> Function(Controller) fromController,
  );

  // Handle an event from an value listenable. The listener will automatically be changed in
  // each widget build and removed when the context is disposed.
  void useLazyEventHandler<T>(
    ValueListenable<T> Function(Controller) fromController,
    ValueChanged<T> onChange,
  );

  // Handle an action from an value listenable. The listener will automatically be changed in
  // each widget build and removed when the context is disposed.
  void useLazyActionHandler(
    ValueListenable<void> Function(Controller) fromController,
    VoidCallback onAction,
  );
}

const _sentinelValueListenable = _NeverValueListenable();

class _NeverValueListenable implements ValueListenable<Never> {
  const _NeverValueListenable();
  @override
  void addListener(VoidCallback listener) => UnimplementedError();

  @override
  void removeListener(VoidCallback listener) => UnimplementedError();

  @override
  Never get value => throw UnimplementedError();
}

class ControllerElement<Controller extends ControllerBase<Controller>>
    extends ListenableElement<ControllerHandle<Controller>>
    implements ControllerContext<Controller> {
  ControllerElement(ControllerWidget<Controller> widget) : super(widget);

  @override
  ControllerWidget<Controller> get widget =>
      super.widget as ControllerWidget<Controller>;

  @override
  ValueListenableHandle<T> useLazy<T>(
    ValueListenable<T> Function(Controller) fromController,
  ) {
    if (didInitHooks) {
      return use<T>(_sentinelValueListenable);
    }
    return use<T>(fromController(widget.identity.unwrap));
  }

  @override
  void useLazyActionHandler(
    ValueListenable<void> Function(Controller) fromController,
    void Function() onAction,
  ) {
    if (didInitHooks) {
      return useActionHandler(_sentinelValueListenable, onAction);
    }
    return useActionHandler(fromController(widget.identity.unwrap), onAction);
  }

  @override
  void useLazyEventHandler<T>(
    ValueListenable<T> Function(Controller) fromController,
    ValueChanged<T> onChange,
  ) {
    if (didInitHooks) {
      return useEventHandler<T>(_sentinelValueListenable, onChange);
    }
    return useEventHandler<T>(fromController(widget.identity.unwrap), onChange);
  }
}

class ListenableElement<Id extends Object> extends ComponentElement
    implements ListenableContext {
  ListenableElement(ListenableWidget<Id> widget)
      : currentIdentity = widget.identity,
        super(widget);
  final List<ValueListenable<Object?>> usedHooks = [];
  int hookI = 0;
  final List<Function> eventCallbacks = [];
  int eventI = 0;
  final List<VoidCallback> actionCallbacks = [];
  int actionI = 0;
  bool didInitHooks = false;
  Id currentIdentity;

  @override
  ListenableWidget get widget => super.widget as ListenableWidget;

  @override
  Widget build() {
    /// Require that the identity, from which the other listenables arise, was not disposed.
    assert(() {
      final id = currentIdentity;
      if (id is IDisposable) {
        return !id.wasDisposed;
      }
      return true;
    }());
    hookI = 0;
    eventI = 0;
    actionI = 0;
    final child = widget.build(this);
    didInitHooks = true;
    return child;
  }

  void _onAction(int actionIndex) => actionCallbacks[actionIndex]();
  void _onEvent<T>(int eventIndex, T value) =>
      (eventCallbacks[eventIndex] as ValueChanged<T>)(value);

  @override
  void useActionHandler(
      ValueListenable<void> fromController, void Function() onAction) {
    assert(debugDoingBuild);
    final actionIndex = actionI++;
    if (didInitHooks) {
      actionCallbacks[actionIndex] = onAction;
      hookI++;
      return;
    }
    actionCallbacks.add(onAction);
    usedHooks.add(fromController.tap((_) => _onAction(actionIndex)));
  }

  @override
  void useEventHandler<T>(
      ValueListenable<T> fromController, ValueChanged<T> onChange) {
    assert(debugDoingBuild);
    final eventIndex = eventI++;
    if (didInitHooks) {
      eventCallbacks[eventIndex] = onChange;
      hookI++;
      return;
    }
    eventCallbacks.add(onChange);
    usedHooks.add(fromController.tap((e) => _onEvent<T>(eventIndex, e)));
  }

  @override
  ValueListenableHandle<T> use<T>(ValueListenable<T> fromController) {
    assert(debugDoingBuild);
    final hookIndex = hookI++;
    if (didInitHooks) {
      final managed = usedHooks[hookIndex] as ValueListenable<T>;
      return ValueListenableHandle(managed);
    }
    usedHooks.add(fromController);
    return ValueListenableHandle(fromController);
  }

  @override
  void update(ListenableWidget<Id> newWidget) {
    final newIdentity = newWidget.identity;
    if (newWidget.identity != currentIdentity) {
      IDisposable.disposeAll(usedHooks);
      usedHooks.clear();
      eventCallbacks.clear();
      actionCallbacks.clear();
      didInitHooks = false;
      currentIdentity = newIdentity;
    }
    // Dont always set because they may be equal but not identical, and in the case they arent,
    // every hook was created based on the fist value, which was from when the currentIdentity
    // was the widget identity.
    super.update(newWidget);
  }

  @override
  void unmount() {
    super.unmount();
    IDisposable.disposeAll(usedHooks);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty('usedHooks', usedHooks, defaultValue: []));
    properties.add(DiagnosticsProperty('currentIdentity', currentIdentity));
  }
}

@optionalTypeArgs
abstract class ListenableWidget<Id extends Object> extends Widget {
  final Id identity;
  const ListenableWidget({
    Key? key,
    required this.identity,
  }) : super(key: key);

  @override
  ListenableElement<Id> createElement() => ListenableElement<Id>(this);

  @protected
  Widget build(covariant ListenableContext context);
}

class ListenableWidgetBuilder<Id extends Object> extends ListenableWidget<Id> {
  final Widget Function(ListenableContext context, Id source) builder;

  const ListenableWidgetBuilder({
    Key? key,
    required Id source,
    required this.builder,
  }) : super(
          key: key,
          identity: source,
        );

  @override
  Widget build(ListenableContext context) => builder(context, identity);
}

abstract class ControllerWidget<Controller extends ControllerBase<Controller>>
    extends ListenableWidget<ControllerHandle<Controller>> {
  const ControllerWidget({
    Key? key,
    required ControllerHandle<Controller> controller,
  }) : super(key: key, identity: controller);

  Controller get controller => identity.unwrap;

  @override
  ControllerElement<Controller> createElement() =>
      ControllerElement<Controller>(this);

  @override
  Widget build(ControllerContext<Controller> context);
}

class ControllerWidgetBuilder<Controller extends ControllerBase<Controller>>
    extends ControllerWidget<Controller> {
  final Widget Function(
      ControllerContext<Controller> context, Controller source) builder;

  const ControllerWidgetBuilder({
    Key? key,
    required ControllerHandle<Controller> controller,
    required this.builder,
  }) : super(key: key, controller: controller);

  @override
  Widget build(ControllerContext<Controller> context) =>
      builder(context, controller);
}
