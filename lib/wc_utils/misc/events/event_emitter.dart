// Copyright (c) 2019, iMeshAcademy authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'events.dart';

/// The callback function to receive event notification.
/// [data] - [Object] event data emitted by the publisher.
typedef EventCallback = void Function(Object? data);

/// This class provides necessary implementations for subscribing and cancelling the event subscriptions and publishing events to the subcribers.
class EventEmitter<T> {
  final Map<T, Set<Listener<T>>> _listeners = <T, Set<Listener<T>>>{};

  /// API to register for notification.
  /// It is mandatory to pass event and callback parameters.
  /// [event] - Event used for the subscription. A valid event is mandatory.
  /// [callback] - [EventCallback] function registered to receive events emitted from the publisher. A valid callback function is mandatory.
  Listener<T> on(T event, EventCallback callback) =>
      listen(event, callback, false);

  Listener<T> once(T event, EventCallback callback) =>
      listen(event, callback, true);

  Listener<T> listen(
    T event,
    EventCallback callback,
    bool isOnce,
  ) {
    var subs =
        // ignore: prefer_collection_literals
        _listeners.putIfAbsent(event, () => Set<Listener<T>>());

    // Create new element.
    Listener<T> listener = Listener.Default(event, callback);
    if (isOnce) {
      listener.updateCallback((ev) {
        listener.cancel();
        callback(ev);
      });
    }

    // Apply cancellation callback.
    listener._cancelCallback = () {
      _removeListener(listener);
    };

    subs.add(listener);
    return listener;
  }

  /// Remove event listener from emitter.
  /// This will unsubscribe the caller from the emitter from any future events.
  /// Listener should be a valid instance.
  /// [listener] - [Listener] instance to be removed from the event subscription.
  void off(Listener<T>? listener) {
    if (null == listener) {
      throw ArgumentError.notNull('listener');
    }

    // Check if the listner has a valid callback for cancelling the subscription.
    // Use the callback to cancel the subscription.
    if (false == listener.cancel()) {
      // Assuming that subscription was not cancelled, could be that the cancel callback was not registered.
      // Follow the old trained method to remove the subrscription .
      _removeListener(listener);
    }
  }

  /// Private method to remove a listener from subject.
  /// The listener should not be a null object.
  void _removeListener(Listener<T> listener) {
    if (_listeners.containsKey(listener.event)) {
      final subscribers = _listeners[listener.event]!;

      subscribers.remove(listener);
      if (subscribers.isEmpty) {
        _listeners.remove(listener.event);
      }
    }
  }

  /// Unsubscribe from getting any future events from emitter.
  /// This mechanism uses event and callback to unsubscribe from all possible events.
  /// [event] - Event for the subscription.
  /// [callback] - [EventCallback] used when registering subscription using [on] function.
  void removeListener(T event, EventCallback callback) {
    // Check if listeners have the specific event already registered.
    // if so, then check for the callback registration.

    if (_listeners.containsKey(event)) {
      final subs = _listeners[event]!;
      subs.removeWhere(
          (element) => element.event == event && element.callback == callback);
    }
  }

  /// API to emit events.
  /// event is a required parameter.
  /// If sender information is sent, it will be used to intimate user about it.
  /// [event] - What event needs to be emitted.
  /// [data] - Data the event need to carry. Ignore this argument if no data needs to be sent.
  void emit(T event, [Object? data]) {
    if (_listeners.containsKey(event)) {
      final sublist = _listeners[event]!.toList();
      for (final item in sublist) {
        item.callback(data);
      }
    }
  }

  /// Clear all subscribers from the cache.
  void clear() {
    _listeners.clear();
  }

  /// Remove all listeners which matches with the callback provided.
  /// It is possible to register for multiple events with a single callback.
  /// This mechanism ensure that all event registrations would be cancelled which matches the callback.
  /// [callback] - The event callback used during subscription.
  void removeAllByCallback(EventCallback callback) {
    _listeners.forEach((key, lst) {
      lst.removeWhere((item) => item.callback == callback);
    });
  }

  /// Use this mechanism to remove all subscription for a particular event.
  /// Caution : This will remove all the listeners from multiple files or classes or modules.
  /// Think twice before calling this API and make sure you know what you are doing!!!
  /// [event] - Event used during subscription.
  void removeAllByEvent(T event) {
    _listeners.removeWhere((key, val) => key == event);
  }

  /// Get the unique count of events registered in the emitter.
  int get count => _listeners.length;

  /// Get the list of subscribers for a particular event.
  int getListenersCount(String event) =>
      _listeners.containsKey(event) ? _listeners[event]!.length : 0;
}

/// Handler for cancelling the event registration.
typedef CancelEvent = void Function();

/// Listener is one who listen for specific event.
/// Listener register for notification with EventEmitter
/// Once the listener is registered, a Listener interface is returned back to the caller.
/// Caller can use this Listener interface to cancel the registration or check the state.
class Listener<T> {
  /// A mechanism to cancel the event.
  CancelEvent? _cancelCallback;

  /// The event, the subscriber subscribed to.
  final T event;

  /// The event callback, which the subscriber uses when he register it for.
  EventCallback _callback;
  EventCallback get callback => _callback;

  /// Constructor for Listener.
  /// This will take four arguments.
  /// [event], [callback] are mandatory.
  ///  [_cancelCallback] is optional.
  /// if [_cancelCallback] callback is provided, then the listener can use that to cancel the subscription.
  Listener(this.event, this._callback, this._cancelCallback);

  /// Constructor for Listener.
  /// This will take four arguments.
  /// [event], [callback] are mandatory.
  Listener.Default(this.event, this._callback);

  void updateCallback(EventCallback callback) => _callback = callback;

  /// Cancel the event subscription with the subject.
  /// Eventhough the cancel method is called, listener doesn't check the cancellation of the subscription.
  /// Subscription cancellation shall be implemented in the _cancelCallback function.
  /// The Default constructor doesn't provide a mechanism to cancel the subscription.
  /// Use the EventEmitter.on to cancel the suscrition effectively.
  /// Returns true, if _cancelCallback is successfully executed, false otherwise.
  bool cancel() {
    if (null != _cancelCallback) {
      _cancelCallback!();
      return true;
    }

    return false;
  }
}
