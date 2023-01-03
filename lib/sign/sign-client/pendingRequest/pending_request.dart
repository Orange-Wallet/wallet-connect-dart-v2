import 'package:wallet_connect/core/store/store.dart';
import 'package:wallet_connect/sign/sign-client/client/constants.dart';
import 'package:wallet_connect/sign/sign-client/pendingRequest/constants.dart';
import 'package:wallet_connect/sign/sign-client/pendingRequest/types.dart';

class PendingRequest extends Store<int, PendingRequestTypesStruct> {
  PendingRequest({required super.core, required super.logger})
      : super(
          name: REQUEST_CONTEXT,
          storagePrefix: SIGN_CLIENT_STORAGE_PREFIX,
          fromJson: (v) =>
              PendingRequestTypesStruct.fromJson(v as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
        );
}
