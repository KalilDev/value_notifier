import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_notifier/src/default.dart';
import 'package:value_notifier/src/disposable.dart';
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
import 'initial.dart';
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
  IDisposableValueListenable<T1> map<T1>(T1 Function(T) fn) =>
      MappedValueListenable(this, fn);
  IDisposableValueListenable<T1> bind<T1>(ValueListenable<T1> Function(T) fn) =>
      BoundValueListenable(this, fn);
  IDisposableValueListenable<T> view() => ValueListenableHandle(this);
  IDisposableValueListenable<T1> cast<T1>() => CastValueListenable(this);
  IDisposableValueListenable<T> withInitial(T initial) =>
      InitialValueListenable(this, initial);
  IDisposableValueListenable<T> tap(
    void Function(T) onValue, {
    bool includeInitial = false,
  }) =>
      TappedValueListenable(
        this,
        onValue,
        includeInitial,
      );
}

extension NullableToNonNullableValueListenableE<T extends Object>
    on ValueListenable<T?> {
  ValueListenable<T> withDefault(T defaultValue) =>
      DefaultValueListenable<T>(this, defaultValue);
  ValueListenable<T> whereNotNull(T onNull) => where(
        (e) => e != null,
        onFalse: onNull,
      ).cast();
}

extension FutureToValueListenableE<T> on Future<T> {
  ValueListenable<T?> toValueListenable() => FutureValueListenable(this);
}

extension StreamToValueListenableE<T> on Stream<T> {
  ValueListenable<T?> toValueListenable({
    bool cancelOnError = false,
    VoidCallback? onDone,
  }) =>
      StreamValueListenable(
        this,
        cancelOnError: cancelOnError,
        onDone: onDone,
      );
}

extension ObjectToValueListenable<T> on T {
  ValueListenable<T> toValueListenable() => SingleValueListenable(this);
}

extension ValueListenableWidgetE<T extends Widget> on ValueListenable<T> {
  Widget build() => OwnValueListenableBuilder<Widget>(
        valueListenable: this,
        builder: (_, widget, ___) => widget,
      );
  Widget buildView() => ValueListenableBuilder<Widget>(
        valueListenable: this,
        builder: (_, widget, ___) => widget,
      );
}

extension ValueListenableWidgetBuilderE on ValueListenable<WidgetBuilder> {
  Widget build() => OwnValueListenableBuilder<WidgetBuilder>(
        valueListenable: this,
        builder: (context, widgetBuilder, ___) => widgetBuilder(context),
      );
  Widget buildView() => ValueListenableBuilder<WidgetBuilder>(
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
  Widget build([Widget? child]) =>
      OwnValueListenableBuilder<ChildWidgetBuilder>(
        valueListenable: this,
        builder: (context, childWidgetBuilder, child) =>
            childWidgetBuilder(context, child),
        child: child,
      );
  Widget buildView([Widget? child]) =>
      ValueListenableBuilder<ChildWidgetBuilder>(
        valueListenable: this,
        builder: (context, childWidgetBuilder, child) =>
            childWidgetBuilder(context, child),
        child: child,
      );
}

extension ValueListenableBuilderE<T> on ValueListenable<T> {
  Widget build({
    required ValueWidgetBuilder<T> builder,
    Widget? child,
  }) =>
      OwnValueListenableBuilder<T>(
        valueListenable: this,
        builder: (context, value, child) => builder(context, value, child),
        child: child,
      );
  Widget buildView({
    required ValueWidgetBuilder<T> builder,
    Widget? child,
  }) =>
      ValueListenableBuilder<T>(
        valueListenable: this,
        builder: (context, value, child) => builder(context, value, child),
        child: child,
      );
}
