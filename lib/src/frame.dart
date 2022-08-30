import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:value_listenables/src/disposable.dart';

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

class BaseAlreadyDisposedException<T extends Listenable> implements Exception {
  final T? debugDisposedBase;
  final DebugValueNotifierOwnershipChainMember self;

  const BaseAlreadyDisposedException(this.debugDisposedBase, this.self);
  static T checkNotDisposed<T extends Listenable>(
    T? base,
    T? debugDisposedBase,
    DebugValueNotifierOwnershipChainMember self,
  ) =>
      base ??
      (throw BaseAlreadyDisposedException<T>(
        debugDisposedBase,
        self,
      ));

  @override
  String toString() =>
      '$runtimeType: The base for $self, $debugDisposedBase, was already disposed';
}

class TraceableValueNotifierException implements Exception {
  final Object error;
  final StackTrace? stackTrace;
  final DebugValueNotifierOwnershipChainMember source;
  final DebugValueNotifierOwnershipChainMember lastTarget;

  TraceableValueNotifierException(
    this.error,
    this.stackTrace,
    this.source,
    this.lastTarget,
  );

  static T tryReturn<T>(
      T Function() fn, DebugValueNotifierOwnershipChainMember self) {
    try {
      return fn();
    } on TraceableValueNotifierException catch (e) {
      throw TraceableValueNotifierException(
        e.error,
        e.stackTrace,
        e.source,
        self,
      );
    } on Object catch (e, s) {
      throw TraceableValueNotifierException(
        e,
        s,
        self,
        self,
      );
    }
  }

  @override
  String toString() => 'TraceableValueNotifierException: $error at $source.\n'
      'The stackTrace was $stackTrace\n'
      'The last target was $lastTarget\n'
      'The Value notifier chain was ${ValueNotifierOwnershipChain.walkFrom(lastTarget)}\n';
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
  const factory ValueNotifierOwnershipFrame.handle(
    Object object,
    String typename, [
    bool ownsChildren,
  ]) = _ValueNotifierOwnershipElidedFrame;
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

class _ValueNotifierOwnershipElidedFrame
    implements ValueNotifierOwnershipFrame {
  final Object object;
  final String typename;
  final bool ownsChild;

  const _ValueNotifierOwnershipElidedFrame(
    this.object,
    this.typename, [
    this.ownsChild = true,
  ]);

  String toString() =>
      '$typename#${object.hashCode.toRadixString(16)}[`$object`]';
}

String valueToStringOrUndefined(ValueListenable<Object?> valueListenable) {
  try {
    return valueListenable.value.toString();
  } on Object {
    return 'undefined';
  }
}
