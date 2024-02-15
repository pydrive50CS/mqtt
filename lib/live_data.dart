import 'package:flutter/material.dart';

/// Using: Live<T> instead of setState({});
/// for better performance in StatefulWidget.
///
///```dart
///
/// :: Define
/// final Live<String> _message = Live<String>('Hello');
///
/// :: Listen & Build (context, value, widget)
/// _message.listen((c, v, w) =>
///     Text('Message: $v', style: const TextStyle(fontSize: 24)));
/// OR
/// _message.listens((v) =>
///     Text('Message: $v', style: const TextStyle(fontSize: 24)));
///
/// :: Dispose
/// _message.dispose();
///
///```
///

class Live<T> {
  final ValueNotifier<T> _notifier;

  Live(T initialValue) : _notifier = ValueNotifier<T>(initialValue);

  T get value => _notifier.value;

  set value(T newValue) => _notifier.value = newValue;

  void observe(VoidCallback listener) => _notifier.addListener(listener);

  void removeObserver(VoidCallback listener) =>
      _notifier.removeListener(listener);

  void dispose() => _notifier.dispose();

  Widget listen(Widget Function(T value) builder) => ValueListenableBuilder<T>(
        valueListenable: _notifier,
        builder: (BuildContext context, T value, Widget? child) =>
            builder(value),
      );

  Widget listens(Widget Function(BuildContext, T, Widget?) builder) =>
      ValueListenableBuilder<T>(valueListenable: _notifier, builder: builder);
}

// Live Data for Flutter HookWidget:

/*Live<T> useLive<T>(T initialValue) {
  return use(_LiveHook(initialValue));
}

class _LiveHook<T> extends Hook<Live<T>> {
  final T initialValue;

  const _LiveHook(this.initialValue);

  @override
  _LiveHookState<T> createState() => _LiveHookState<T>();
}

class _LiveHookState<T> extends HookState<Live<T>, _LiveHook<T>> {
  late Live<T> _liveData;

  @override
  void initHook() {
    super.initHook();
    _liveData = Live<T>(hook.initialValue);
  }

  @override
  Live<T> build(BuildContext context) {
    return _liveData;
  }

  @override
  void dispose() {
    _liveData.dispose();
    super.dispose();
  }
}*/
