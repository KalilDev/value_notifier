import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_notifier/src/debounce.dart';
import 'package:value_notifier/src/default.dart';
import 'package:value_notifier/src/disposable.dart';
import 'package:value_notifier/src/dispose.dart';
import 'package:value_notifier/src/future.dart';
import 'package:value_notifier/src/listen.dart';
import 'package:value_notifier/src/map.dart';
import 'package:value_notifier/src/single.dart';
import 'package:value_notifier/src/stream.dart';
import 'package:value_notifier/src/tap.dart';
import 'package:value_notifier/src/unique.dart';
import 'package:value_notifier/src/handle.dart';
import 'package:value_notifier/src/where.dart';

import 'bind.dart';
import 'cast.dart';
import 'event_notifier.dart';
import 'initial.dart';
import 'where_keeping_previous.dart';
import 'widgets/own_value_listenable_builder.dart';

extension NullableValueListenableE<T extends Null> on ValueListenable<T> {}

extension NonNullableValueListenableE<T extends Object> on ValueListenable<T> {}

extension ListenableE on Listenable {
  IDisposableListenable listen(
    VoidCallback onChange, {
    bool includeInitial = false,
    bool takeOwnership = false,
  }) =>
      ListenerListenable(
        this,
        onChange,
        tapInitial: includeInitial,
        takeOwnership: takeOwnership,
      );
}


extension ValueListenableE<T> on ValueListenable<T> {
  IDisposableValueListenable<T> unique([Equals<T>? equals]) =>
      UniqueValueListenable(
        this,
        equals ?? UniqueValueListenable.defaultEquals,
      );
  IDisposableValueListenable<T?> where(Predicate<T> predicate, {T? onFalse}) =>
      WhereValueListenable(this, predicate, onFalse: onFalse);
  IDisposableValueListenable<T> whereKeepingPrevious(Predicate<T> predicate,
          {required T Function() initial}) =>
      WhereKeepingPreviousValueListenable(this, predicate, initial: initial);
  IDisposableValueListenable<T1> map<T1>(T1 Function(T) fn) =>
      MappedValueListenable(this, fn);
  /// Monadic bind
  IDisposableValueListenable<T1> bind<T1>(
    ValueListenable<T1> Function(T) fn, {
    bool canBindEagerly = true,
  }) =>
      BoundValueListenable(this, fn, canBindEagerly);
  IDisposableValueListenable<T> view() => ValueListenableHandle(this);
  IDisposableValueListenable<T1> cast<T1>() => CastValueListenable(this);
  IDisposableValueListenable<T> withInitial(T initial) =>
      InitialValueListenable(this, initial);
  /// Applicative lift
  IDisposableValueListenable<B> lift<A, B>(ValueListenable<B Function(A)> fn, ValueListenable<A> a) =>
      // We need to create an view into a, because in each bind we are taking ownership of a again, something that is clearly invalid,
      // and we dispose a with andDispose, so it does not leak.
      fn.bind<B>((fn) => a.view().map((a) => fn(a))).andDispose(a);
  IDisposableValueListenable<T> andDispose(Object object) => AndDisposeValueListenable(this, object);
  IDisposableValueListenable<T> andDisposeAll(Iterable<Object> objects) => AndDisposeAllValueListenable(this, objects);
  IDisposableValueListenable<T> tap(
    void Function(T) onValue, {
    bool includeInitial = false,
  }) =>
      TappedValueListenable(
        this,
        onValue,
        includeInitial,
      );

  /// equivalent to [tap]([onValue], includeInitial: true)
  IDisposableValueListenable<T> connect(void Function(T) onValue) =>
      TappedValueListenable(
        this,
        onValue,
        true,
      );
  IDisposableValueListenable<T> debounce({
    required Duration wait,
    bool leading = false,
    Duration? maxWait,
    bool trailing = true,
  }) =>
      DebouncedValueNotifier(
        this,
        wait: wait,
        leading: leading,
        maxWait: maxWait,
        trailing: trailing,
      );
  T Function() get getter => () => value;
}

extension ValueNotifierE<T> on ValueNotifier<T> {
  void Function(T) get setter => (v) => value = v;
}

extension NullableToNonNullableValueListenableE<T extends Object>
    on ValueListenable<T?> {
  ValueListenable<T> withDefault(T defaultValue) =>
      DefaultValueListenable<T>(this, defaultValue);
  ValueListenable<T> whereNotNull(T onNull) => where(
        (e) => e != null,
        onFalse: onNull,
      ).cast();
  ValueListenable<T> castNotNull() => cast();
}

extension FutureToValueListenableE<T> on Future<T> {
  ValueListenable<AsyncSnapshot<T>> toValueListenable({
    bool eager = false,
  }) =>
      FutureValueListenable(
        this,
        eager: eager,
      );
}

extension StreamToValueListenableE<T> on Stream<T> {
  ValueListenable<AsyncSnapshot<T>> toValueListenable({
    bool cancelOnError = false,
    VoidCallback? onDone,
    bool eager = false,
  }) =>
      StreamValueListenable(
        this,
        cancelOnError: cancelOnError,
        onDone: onDone,
        eager: eager,
      );
}

extension ValueListenableFunctionApply<U,T> on U Function(T) {
  ValueListenable<U> apply(ValueListenable<T> arg) => arg.lift(asValueListenable, arg);
  ValueListenable<U> operator >>(ValueListenable<T> arg) => apply(arg);
}
extension ValueListenableFunctionReturn1<U,T> on U Function(T) {
  ValueListenable<U> Function(T) get ret => (v)=>SingleValueListenable(this(v));
}
extension ValueListenableApply<U,T> on ValueListenable<U Function(T)> {
  ValueListenable<U> apply(ValueListenable<T> arg) => arg.lift(this, arg);
  ValueListenable<U> operator >>(ValueListenable<T> arg) => apply(arg);
}

extension ObjectToValueListenable<T> on T {
  @Deprecated('use asValueListenable, because it conforms to the effective dart naming convention')
  ValueListenable<T> toValueListenable() => SingleValueListenable(this);
  ValueListenable<T> get asValueListenable => SingleValueListenable(this);
}

extension ValueListenableWidgetE<T extends Widget> on ValueListenable<T> {
  Widget build({
    Key? key,
  }) =>
      OwnValueListenableBuilder<Widget>(
        key: key,
        valueListenable: this,
        builder: (_, widget, ___) => widget,
      );
  Widget buildView({
    Key? key,
  }) =>
      ValueListenableBuilder<Widget>(
        key: key,
        valueListenable: this,
        builder: (_, widget, ___) => widget,
      );
}

extension ValueListenableWidgetBuilderE on ValueListenable<WidgetBuilder> {
  Widget build({
    Key? key,
  }) =>
      OwnValueListenableBuilder<WidgetBuilder>(
        key: key,
        valueListenable: this,
        builder: (context, widgetBuilder, ___) => widgetBuilder(context),
      );
  Widget buildView({
    Key? key,
  }) =>
      ValueListenableBuilder<WidgetBuilder>(
        key: key,
        valueListenable: this,
        builder: (context, widgetBuilder, ___) => widgetBuilder(context),
      );
}

typedef ChildWidgetBuilder = Widget Function(
  BuildContext context,
  Widget? child,
);

extension ValueListenableChildWidgetBuilderE<T>
    on ValueListenable<ChildWidgetBuilder> {
  Widget build({
    Key? key,
    Widget? child,
  }) =>
      OwnValueListenableBuilder<ChildWidgetBuilder>(
        key: key,
        valueListenable: this,
        builder: (context, childWidgetBuilder, child) =>
            childWidgetBuilder(context, child),
        child: child,
      );
  Widget buildView({
    Key? key,
    Widget? child,
  }) =>
      ValueListenableBuilder<ChildWidgetBuilder>(
        key: key,
        valueListenable: this,
        builder: (context, childWidgetBuilder, child) =>
            childWidgetBuilder(context, child),
        child: child,
      );
}

extension ValueListenableBuilderE<T> on ValueListenable<T> {
  Widget build({
    Key? key,
    required ValueWidgetBuilder<T> builder,
    Widget? child,
  }) =>
      OwnValueListenableBuilder<T>(
        key: key,
        valueListenable: this,
        builder: (context, value, child) => builder(context, value, child),
        child: child,
      );
  Widget buildView({
    Key? key,
    required ValueWidgetBuilder<T> builder,
    Widget? child,
  }) =>
      ValueListenableBuilder<T>(
        key: key,
        valueListenable: this,
        builder: (context, value, child) => builder(context, value, child),
        child: child,
      );
}
