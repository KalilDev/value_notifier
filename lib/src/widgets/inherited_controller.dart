import 'package:flutter/cupertino.dart';
import 'package:value_listenables/src/controller.dart';

class InheritedController<T extends ControllerBase<T>> extends InheritedWidget {
  const InheritedController({
    Key? key,
    required this.handle,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  final ControllerHandle<T> handle;

  @override
  bool updateShouldNotify(InheritedController<T> oldWidget) =>
      handle != oldWidget.handle;

  static ControllerHandle<T> get<T extends ControllerBase<T>>(
    BuildContext context,
  ) =>
      maybeGet<T>(context)!;
  static ControllerHandle<T>? maybeGet<T extends ControllerBase<T>>(
    BuildContext context,
  ) =>
      context.findAncestorWidgetOfExactType<InheritedController<T>>()?.handle;

  static ControllerHandle<T> of<T extends ControllerBase<T>>(
    BuildContext context,
  ) =>
      maybeOf<T>(context)!;

  static ControllerHandle<T>? maybeOf<T extends ControllerBase<T>>(
    BuildContext context,
  ) =>
      context
          .dependOnInheritedWidgetOfExactType<InheritedController<T>>()
          ?.handle;
}
