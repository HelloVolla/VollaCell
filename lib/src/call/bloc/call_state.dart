part of 'call_bloc.dart';

@immutable
final class CallState {
  const CallState({this.call, this.usernameAddressHex});

  final MeshCall? call;
  final String? usernameAddressHex;

  CallState copyWith({
    MeshCall? call,
    String? usernameAddressHex,
  }) =>
      CallState(
        call: call ?? this.call,
        usernameAddressHex: usernameAddressHex ?? this.usernameAddressHex,
      );
}

final class EndCallState extends CallState {}
