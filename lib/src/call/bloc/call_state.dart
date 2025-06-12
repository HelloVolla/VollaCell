part of 'call_bloc.dart';

@immutable
final class CallState {
  const CallState({
    this.call,
    this.usernameAddressHex,
    this.callState,
  });

  final MeshCall? call;
  final String? usernameAddressHex;
  final CallScreenState? callState;

  CallState copyWith({
    MeshCall? call,
    String? usernameAddressHex,
    CallScreenState? callState,
  }) =>
      CallState(
        call: call ?? this.call,
        callState: callState ?? this.callState,
        usernameAddressHex: usernameAddressHex ?? this.usernameAddressHex,
      );
}

final class EndCallState extends CallState {}
