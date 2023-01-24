import 'package:wallet_connect_v2/core/store/store.dart';
import 'package:wallet_connect_v2/sign/sign-client/client/constants.dart';
import 'package:wallet_connect_v2/sign/sign-client/proposal/constants.dart';
import 'package:wallet_connect_v2/sign/sign-client/proposal/models.dart';

class Proposal extends Store<String, ProposalStruct> {
  Proposal({required super.core, required super.logger})
      : super(
          name: PROPOSAL_CONTEXT,
          storagePrefix: SIGN_CLIENT_STORAGE_PREFIX,
          fromJson: (v) => ProposalStruct.fromJson(v),
          toJson: (v) => v.toJson(),
        );
}
