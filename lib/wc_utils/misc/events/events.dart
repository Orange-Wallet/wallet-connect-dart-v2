part 'event_emitter.dart';

abstract class IEvents {
  EventEmitter<String> get events;

  Listener<String> on(String event, EventCallback callback);

  Listener<String> once(String event, EventCallback callback);

  void off(Listener<String>? listener);

  void removeListener(String eventName, EventCallback callback);
}

mixin Events implements IEvents {
  @override
  EventEmitter<String> get events;

  @override
  Listener<String> on(String event, EventCallback callback) =>
      events.on(event, callback);

  @override
  Listener<String> once(String event, EventCallback callback) =>
      events.once(event, callback);

  @override
  void off(Listener<String>? listener) => events.off(listener);

  @override
  void removeListener(String eventName, EventCallback callback) =>
      events.removeListener(eventName, callback);
}
