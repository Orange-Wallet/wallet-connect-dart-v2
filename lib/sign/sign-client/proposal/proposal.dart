import 'package:wallet_connect/core/store/store.dart';
import 'package:wallet_connect/sign/sign-client/client/constants.dart';
import 'package:wallet_connect/sign/sign-client/proposal/constants.dart';
import 'package:wallet_connect/sign/sign-client/proposal/types.dart';

class Proposal extends Store<String, ProposalTypesStruct> {
  Proposal({required super.core, required super.logger})
      : super(
          name: PROPOSAL_CONTEXT,
          storagePrefix: SIGN_CLIENT_STORAGE_PREFIX,
          fromJson: (v) =>
              ProposalTypesStruct.fromJson(v as Map<String, dynamic>),
          toJson: (v) => v.toJson(),
        );
}
