import 'package:flutter/material.dart';
import 'package:value_listenables/src/widgets/inherited_controller.dart';
import 'package:value_listenables/value_listenables.dart';

class InheritedControllerInjector<T extends ControllerBase<T>>
    extends StatelessWidget {
  const InheritedControllerInjector({
    Key? key,
    required this.factory,
    required this.child,
  }) : super(key: key);
  final T Function(BuildContext) factory;
  final Widget child;

  @override
  Widget build(BuildContext context) => ControllerInjectorBuilder<T>(
        factory: factory,
        inherited: true,
        builder: (context, controller) => child,
      );
}

class ControllerInjectorBuilder<T extends ControllerBase<T>>
    extends StatefulWidget {
  const ControllerInjectorBuilder({
    Key? key,
    required this.factory,
    this.inherited = false,
    required this.builder,
  }) : super(key: key);

  final T Function(BuildContext) factory;
  final bool inherited;
  final Widget Function(BuildContext context, ControllerHandle<T> controller)
      builder;

  @override
  _ControllerInjectorBuilderState<T> createState() =>
      _ControllerInjectorBuilderState<T>();
}

class _ControllerInjectorBuilderState<T extends ControllerBase<T>>
    extends State<ControllerInjectorBuilder<T>> {
  late final T controller;

  @override
  void initState() {
    super.initState();
    controller = widget.factory(context);
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.inherited) {
      return InheritedController<T>(
        handle: controller.handle,
        child: Builder(
          builder: (context) => widget.builder(context, controller.handle),
        ),
      );
    }
    return widget.builder(context, controller.handle);
  }
}
