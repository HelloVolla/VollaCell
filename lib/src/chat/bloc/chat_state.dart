part of 'chat_bloc.dart';

@immutable
final class ChatState {
  const ChatState({
    required this.address,
    this.messages = const [],
    this.flagScrollToDown = false,
  });

  // final List<MeshMessage> messages;
  final List<KaonicEvent<KaonicEventData>> messages;
  final MeshAddress address;

  final bool flagScrollToDown;

  ChatState copyWith({
    // List<MeshMessage>? messages,
    List<KaonicEvent<KaonicEventData>>? messages,
    bool flagScrollToDown = false,
  }) =>
      ChatState(
        address: address,
        flagScrollToDown: flagScrollToDown,
        messages: messages ?? this.messages,
      );
}

final class NavigateToCall extends ChatState {
  const NavigateToCall({required super.address});
}
