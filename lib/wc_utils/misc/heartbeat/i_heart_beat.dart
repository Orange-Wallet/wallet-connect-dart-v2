import 'package:wallet_connect/wc_utils/misc/events/events.dart';

abstract class IHeartBeat implements IEvents {
  int get interval;

  Future<void> init();
}
