import 'package:wallet_connect/core/store/store.dart';
import 'package:wallet_connect/sign/sign-client/client/constants.dart';
import 'package:wallet_connect/sign/sign-client/session/constants.dart';
import 'package:wallet_connect/sign/sign-client/session/models.dart';

class Session extends Store<String, SessionStruct> {
  Session({required super.core, required super.logger})
      : super(
          name: SESSION_CONTEXT,
          storagePrefix: SIGN_CLIENT_STORAGE_PREFIX,
          fromJson: (v) => SessionStruct.fromJson(v as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
        );
}
