import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_listenables/value_listenables.dart';

import '../disposable.dart';

// An widget that owns an valueListenable in the tree, disposing it when done.
class ValueListenableOwner extends StatefulWidget {
  const ValueListenableOwner({
    Key? key,
    required this.valueListenable,
    required this.child,
  }) : super(key: key);
  final ValueListenable<Never> valueListenable;
  final Widget child;

  @override
  _ValueListenableOwnerState createState() => _ValueListenableOwnerState();
}

class _ValueListenableOwnerState extends State<ValueListenableOwner> {
  @override
  void didUpdateWidget(ValueListenableOwner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable) {
      IDisposable.disposeObj(oldWidget.valueListenable);
    }
  }

  void dispose() {
    IDisposable.disposeObj(widget.valueListenable);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// An widget that owns an valueListenable in the tree, disposing it when done.
class ValueListenableOwnerBuilder<T> extends StatefulWidget {
  const ValueListenableOwnerBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
  }) : super(key: key);
  final ValueListenable<T> valueListenable;
  final Widget Function(
    BuildContext context,
    ValueGetter<ValueListenable<T>> view,
  ) builder;

  @override
  _ValueListenableOwnerBuilderState<T> createState() =>
      _ValueListenableOwnerBuilderState();
}

class _ValueListenableOwnerBuilderState<T>
    extends State<ValueListenableOwnerBuilder<T>> {
  @override
  void didUpdateWidget(ValueListenableOwnerBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable) {
      IDisposable.disposeObj(oldWidget.valueListenable);
    }
  }

  void dispose() {
    IDisposable.disposeObj(widget.valueListenable);
    super.dispose();
  }

  ValueListenable<T> createView() => widget.valueListenable.view();

  @override
  Widget build(BuildContext context) => widget.builder(context, createView);
}
