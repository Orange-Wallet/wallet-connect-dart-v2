import 'package:wallet_connect/core/store/store.dart';
import 'package:wallet_connect/sign/sign-client/client/constants.dart';
import 'package:wallet_connect/sign/sign-client/session/constants.dart';
import 'package:wallet_connect/sign/sign-client/session/types.dart';

class Session extends Store<String, SessionTypesStruct> {
  Session({required super.core, required super.logger})
      : super(
          name: SESSION_CONTEXT,
          storagePrefix: SIGN_CLIENT_STORAGE_PREFIX,
          fromJson: (v) =>
              SessionTypesStruct.fromJson(v as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
        );
}
