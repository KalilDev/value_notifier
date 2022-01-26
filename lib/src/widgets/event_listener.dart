import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_notifier/src/disposable.dart';
import '../extensions.dart';

/// Equivalent of calling [ValueListenableE.tap], but automatically handles the
/// lifecycle of the resulting [IDisposableValueListenable]. If you do not want
/// the event to be disposed, be sure to use an view to it!
class EventListener<T> extends StatefulWidget {
  const EventListener({
    Key? key,
    required this.event,
    required this.onEvent,
    required this.child,
  }) : super(key: key);
  final ValueListenable<T> event;
  final void Function(T) onEvent;
  final Widget child;

  @override
  State<EventListener<T>> createState() => _EventListenerState<T>();
}

class _EventListenerState<T> extends State<EventListener<T>> {
  late IDisposableValueListenable<T> _tappedEvent;

  void initState() {
    super.initState();
    _tappedEvent = widget.event.tap(_onEvent);
  }

  void didChangeWidget(EventListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event == widget.event) {
      return;
    }
    _tappedEvent.dispose();
    _tappedEvent = widget.event.tap(_onEvent);
  }

  bool _debugDisposing = false;
  bool _debugDisposed = false;

  void dispose() {
    assert(() {
      _debugDisposing = true;
      return true;
    }());
    _tappedEvent.dispose();
    assert(() {
      _debugDisposed = true;
      return true;
    }());
    super.dispose();
  }

  void _onEvent(T value) {
    assert(!_debugDisposed && !_debugDisposing);
    widget.onEvent(value);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
