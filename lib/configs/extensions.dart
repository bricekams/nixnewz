import 'package:flutter/material.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:provider/provider.dart';

extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but the callback has index as second argument
  Iterable<T> indexedMap<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndexed(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}

extension Translate on BuildContext {
  String localize(String key) {
    return dictionary[key][read<SettingsProvider>().language]!;
  }
}