import 'package:wallet_connect_v2/wc_utils/misc/events/events.dart';

abstract class IHeartBeat implements IEvents {
  int get interval;

  Future<void> init();
}
