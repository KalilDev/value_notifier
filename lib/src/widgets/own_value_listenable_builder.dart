import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_notifier/src/disposable.dart';
import 'package:value_notifier/src/handle.dart';

/// An [ValueListenableBuilder] which takes ownership of the passed
/// [valueListenable], disposing it when done.
class OwnValueListenableBuilder<T> extends StatefulWidget {
  const OwnValueListenableBuilder({
    Key? key,
    required this.valueListenable,
    required this.builder,
    this.child,
  })  : assert(valueListenable != null),
        assert(builder != null),
        super(key: key);

  final ValueListenable<T> valueListenable;

  final ValueWidgetBuilder<T> builder;

  final Widget? child;

  @override
  State<StatefulWidget> createState() => _OwnValueListenableBuilderState<T>();
}

class _OwnValueListenableBuilderState<T>
    extends State<OwnValueListenableBuilder<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = IDisposableAlreadyDisposedException.checkNotDisposed(
      widget.valueListenable,
    ).value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(OwnValueListenableBuilder<T> oldWidget) {
    if (!ValueListenableHandle.refersToTheSameBase(
        widget.valueListenable, oldWidget.valueListenable)) {
      IDisposable.tryDispose(oldWidget.valueListenable, () {
        assert(() {
          print(
              'Could not dispose the ValueListener ${oldWidget.valueListenable}'
              ', of type ${oldWidget.valueListenable.runtimeType}. If you wish '
              'it was disposed, wrap the object in an IDisposable or an '
              'ChangeNotifier!');
          return true;
        }());
      });
      value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    } else if (widget.valueListenable != oldWidget.valueListenable) {
      print('Saved an dispose');
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    IDisposable.tryDispose(widget.valueListenable, () {
      assert(() {
        print('Could not dispose the ValueListener ${widget.valueListenable}'
            ', of type ${widget.valueListenable.runtimeType}. If you wish '
            'it was disposed, wrap the object in an IDisposable or an '
            'ChangeNotifier!');
        return true;
      }());
    });

    super.dispose();
  }

  void _valueChanged() {
    setState(() {
      value = widget.valueListenable.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}
