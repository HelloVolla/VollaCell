import 'dart:async';

import 'package:kaonic/data/models/kaonic_new/kaonic_event.dart';
import 'package:kaonic/data/models/kaonic_new/kaonic_event_type.dart';
import 'package:kaonic/data/models/kaonic_new/kaonic_message_event.dart';
import 'package:kaonic/service/new/kaonic_communication_service.dart';
import 'package:rxdart/subjects.dart';

class ChatService {
  ChatService(KaonicCommunicationService kaonicService) {
    _kaonicService = kaonicService;
    _listenMessages();
  }

  late final KaonicCommunicationService _kaonicService;

  /// key is address of chat id
  final _messagesSubject = BehaviorSubject<Map<String, List<KaonicEvent>>>();

  /// key is contact address,
  /// value is chatUUID
  final _contactChats = <String, String>{};

  void _listenMessages() {
    _kaonicService.eventsStream
        .where((event) => KaonicEventType.messageEvents.contains(event.type))
        .listen((event) {
      switch (event.type) {
        case KaonicEventType.CHAT_CREATE:
          _putOrUpdateChatId(
            (event.data as MessageEvent).chatId,
            (event.data as MessageEvent).address,
          );
        case KaonicEventType.MESSAGE_TEXT:
        case KaonicEventType.MESSAGE_FILE:
          _handleTextMessage(event);
      }
    });
  }

  Stream<List<KaonicEvent>> getChatMessages(String chatId) {
    return _messagesSubject.stream.map((messagesMap) {
      return messagesMap[chatId] ?? [];
    });
  }

  Future<String> createChat(String address) async {
    final chatId = await _kaonicService.createChat(address);

    _contactChats[address] = chatId;
    return chatId;
  }

  void sendTextMessage(String message, String address) async {
    _kaonicService.sendTextMessage(address, message);
  }

  void sendFileMessage(String filePath, String address) async {
    _kaonicService.sendFileMessage(address, filePath);
  }

  void _handleTextMessage(KaonicEvent message) {
    final data = message.data as MessageTextEvent;
    final chatId = data.chatId;

    final currentMap =
        Map<String, List<KaonicEvent>>.from(_messagesSubject.value);
    final messageList = List<KaonicEvent>.from(currentMap[chatId] ?? []);

    final existingMessages = messageList
        .where((msg) =>
            msg.data is MessageEvent &&
            (msg.data as MessageEvent).id == data.id)
        .toList();

    if (existingMessages.isNotEmpty) {
      final index = messageList.indexOf(existingMessages.first);
      if (index != -1) {
        messageList[index] = message;
      }
    } else {
      messageList.add(message);
    }

    currentMap[chatId] = messageList;

    _messagesSubject.add(currentMap);
  }

  void _putOrUpdateChatId(String chatId, String address) {
    _contactChats[address] = chatId;
  }
}
