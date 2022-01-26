import 'package:flutter/foundation.dart';
import 'package:value_notifier/value_notifier.dart';

class ValueNotifierOwnershipChain {
  final List<ValueNotifierOwnershipFrame> _frames;

  ValueNotifierOwnershipChain._(this._frames);
  @override
  String toString([bool topDown = false]) {
    final result = StringBuffer();
    const kIdent = '  ';
    var ident = kIdent;
    final indexWidth = _frames.length.toString().length;
    for (var i = topDown ? _frames.length - 1 : 0;
        topDown ? i >= 0 : i < _frames.length;
        topDown ? i-- : i++) {
      final frame = _frames[i];
      result.write('#');
      result.write(i.toString().padLeft(indexWidth, '0'));
      result.write(ident);
      result.writeln(frame);
      if (frame is _ValueNotifierOwnershipFrame && !frame.ownsChild) {
        ident += kIdent;
      }
    }
    return result.toString();
  }

  factory ValueNotifierOwnershipChain.walkFrom(Object valueNotifier) {
    final result = <ValueNotifierOwnershipFrame>[];
    Object? possibleFrame = valueNotifier;
    while (possibleFrame is DebugValueNotifierOwnershipChainMember) {
      final frame = possibleFrame.debugOwnershipChainFrame;
      possibleFrame = possibleFrame.debugOwnershipChainChild;
      result.add(frame);
    }
    assert(possibleFrame is! ValueNotifierOwnershipFrame);
    if (possibleFrame != null) {
      result.add(_ValueNotifierOwnershipEndFrame(possibleFrame));
    }
    return ValueNotifierOwnershipChain._(result);
  }
}

abstract class DebugValueNotifierOwnershipChainMember {
  @visibleForTesting
  ValueNotifierOwnershipFrame get debugOwnershipChainFrame;
  @visibleForTesting
  Object? get debugOwnershipChainChild;
}

abstract class ValueNotifierOwnershipFrame {
  const factory ValueNotifierOwnershipFrame(
    Object object,
    String typename, [
    bool ownsChildren,
  ]) = _ValueNotifierOwnershipFrame;
}

class _ValueNotifierOwnershipEndFrame implements ValueNotifierOwnershipFrame {
  final Object object;

  _ValueNotifierOwnershipEndFrame(this.object);

  String toString() => 'END --> $object';
}

class _ValueNotifierOwnershipFrame implements ValueNotifierOwnershipFrame {
  final Object object;
  final String typename;
  final bool ownsChild;

  const _ValueNotifierOwnershipFrame(
    this.object,
    this.typename, [
    this.ownsChild = true,
  ]);

  String toString() =>
      '$typename#${object.hashCode.toRadixString(16)}[`$object`]';
}
