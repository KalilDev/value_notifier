import 'package:flutter/foundation.dart';
import 'package:value_notifier/src/frame.dart';
import 'disposable.dart';
import 'extensions.dart';

/// An [EventNotifier] for actions which hold no meaningful information.
///
/// For example, an pressed [ActionNotifier], which is notified when an
/// onPressed callback is called.
typedef ActionNotifier = EventNotifier<void>;

extension ActionNotifierE on ActionNotifier {
  void notify() => add(null);
}

/// A [ChangeNotifier] that notifies events, keeping track of the last emmited
/// event.
class EventNotifier<EventType> extends ChangeNotifier
    implements
        ValueListenable<EventType?>,
        DebugValueNotifierOwnershipChainMember {
  /// Whether or not only consecutive events which are not `==` should notify
  /// the listeners
  final bool onlyUnique;

  EventNotifier({
    this.onlyUnique = false,
  });

  /// The value of the last action that ocurred in this notifier.
  ///
  /// When the value is replaced with something that is not equal to the old
  /// value as evaluated by the equality operator ==, this class notifies its
  /// listeners.
  @override
  EventType? get value => _lastEvent;
  EventType? _lastEvent;
  void add(EventType newEvent) {
    if (onlyUnique && _lastEvent == newEvent) return;
    _lastEvent = newEvent;
    notifyListeners();
  }

  /// Only the next events
  IDisposableValueListenable<EventType> nexts() => cast();

  /// An view of only the next events
  IDisposableValueListenable<EventType> viewNexts() => view().cast();

  @override
  String toString() => '${describeIdentity(this)}($value)';

  @override
  Object? get debugOwnershipChainChild => null;

  @override
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame =>
      ValueNotifierOwnershipFrame(this, 'EventNotifier');
}
