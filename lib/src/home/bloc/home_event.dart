part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class _InitEvent extends HomeEvent {}

final class _UpdatedChats extends HomeEvent {
  _UpdatedChats({required this.chats});

  final Map<String, MeshChat> chats;
}

final class _HandleCallStatus extends HomeEvent {
  _HandleCallStatus({required this.call});

  final MeshCall call;
}

final class _UpdatedNodes extends HomeEvent {
  _UpdatedNodes({required this.nodes});

  final List<String> nodes;
}

final class _UpdatedUser extends HomeEvent {
  _UpdatedUser({required this.user});

  final UserModel user;
}
