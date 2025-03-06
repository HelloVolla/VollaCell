part of 'home_bloc.dart';

@immutable
final class HomeState {
  const HomeState(
      {this.user, this.unreadMessages = const {}, this.nodes = const {}});

  final UserModel? user;
  final Map<String, MeshNode> nodes;
  final Map<String, int> unreadMessages;

  HomeState copyWith({
    UserModel? user,
    Map<String, int>? unreadMessages,
    Map<String, MeshNode>? nodes,
  }) =>
      HomeState(
        user: user ?? this.user,
        unreadMessages: unreadMessages ?? this.unreadMessages,
        nodes: nodes ?? this.nodes,
      );
}

final class IncomingCall extends HomeState {
  const IncomingCall({
    required super.nodes,
    required super.unreadMessages,
    required super.user,
  });

  static IncomingCall fromParentState(HomeState state) => IncomingCall(
      nodes: state.nodes,
      unreadMessages: state.unreadMessages,
      user: state.user);
}
