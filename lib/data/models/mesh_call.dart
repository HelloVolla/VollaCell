
import 'package:kaonic/data/models/radio_address.dart';


enum MeshCallStatuses {
  /// Base status
  none,

  /// Other user initiated call
  ///
  /// callInvoke received
  incomingCall,

  /// User initiated call
  ///
  /// callInvoke send
  outcomeCall,

  /// In call
  ///
  /// callAnswer received
  inCall,

  /// Call ended by sender or who initiated call
  ///
  /// callReject received or send
  ended;

  String getTitle([String? user]) => switch (this) {
        incomingCall => '$user CALLING',
        outcomeCall => 'CALLING...',
        inCall => 'IN CALL WITH $user',
        ended => 'CALL ENDED',
        _ => ''
      };
}
class MeshCall {
  MeshCall({this.status = MeshCallStatuses.none, this.address});

  final RadioAddress? address;
  final MeshCallStatuses status;

  MeshCall copyWith({
    RadioAddress? address,
    MeshCallStatuses? status,
  }) =>
      MeshCall(
        address: address ?? this.address,
        status: status ?? this.status,
      );
}