part of 'call_bloc.dart';

@immutable
sealed class CallEvent {}

final class _InitCall extends CallEvent {}

final class _CallUpdated extends CallEvent {
  _CallUpdated({required this.call});

  final MeshCall call;
}

final class EndCall extends CallEvent {}

final class AcceptCall extends CallEvent {}
