import 'dart:async';

import 'package:wallet_connect/wc_utils/misc/events/events.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/constants.dart';
import 'package:wallet_connect/wc_utils/misc/heartbeat/types.dart';

class HeartBeat with Events implements IHeartBeat {
  static HeartBeat get instance {
    final heartbeat = HeartBeat();
    heartbeat.init();
    return heartbeat;
  }

  @override
  final EventSubject events;

  @override
  final int interval;

  HeartBeat({this.interval = HEARTBEAT_INTERVAL}) : events = EventSubject();

  @override
  Future<void> init() async => _initialize();

  // ---------- Private ----------------------------------------------- //

  void _initialize() {
    Timer.periodic(
      const Duration(seconds: HEARTBEAT_INTERVAL),
      (_) => _pulse(),
    );
  }

  _pulse() {
    events.emitData(HeartbeatEvents.pulse);
  }
}
