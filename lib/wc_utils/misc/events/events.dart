import 'package:eventify/eventify.dart';

typedef EventsCallback = void Function(Event event);

abstract class IEvents {
  EventSubject get events;

  Listener on(String event, EventsCallback callback);

  Listener once(String event, EventsCallback callback);

  void off(Listener? listener);

  void removeListener(String eventName, EventsCallback callback);
}

mixin Events implements IEvents {
  @override
  EventSubject get events;
  @override
  Listener on(String event, EventsCallback callback) =>
      events.on(event, null, (event, _) => callback(event));
  @override
  Listener once(String event, EventsCallback callback) =>
      events.once(event, null, (event, _) => callback(event));
  @override
  void off(Listener? listener) => events.off(listener);
  @override
  void removeListener(String eventName, EventsCallback callback) =>
      events.removeListener(eventName, (event, _) => callback(event));
}

class EventSubject extends EventEmitter {
  void emitData(String event, [Object? data]) => emit(event, null, data);
}

// class EventData {
//   final String name;
//   final dynamic data;

//   EventData(this.name, this.data);
// }

// class EventSubject extends Subject<EventData> {
//   EventSubject._(
//       StreamController<EventData> controller, Stream<EventData> stream)
//       : super(controller, stream);

//   /// Constructs a [EventSubject], optionally pass handlers for
//   /// [onListen], [onCancel] and a flag to handle events [sync].
//   ///
//   /// See also [StreamController.broadcast]
//   factory EventSubject(
//       {void Function()? onListen,
//       void Function()? onCancel,
//       bool sync = false}) {
//     // ignore: close_sinks
//     final controller = StreamController<EventData>.broadcast(
//       onListen: onListen,
//       onCancel: onCancel,
//       sync: sync,
//     );

//     return EventSubject._(
//       controller,
//       controller.stream,
//     );
//   }

//   void emit(String event, [dynamic data]) => add(EventData(event, data));

//   void on(String event, void Function(dynamic data) callback) {
//     listen((value) {
//       if (value.name == event) {
//         callback(value.data);
//       }
//     });
//   }
// }
