import 'dart:async';

import 'package:kaonic/data/models/kaonic_event.dart';
import 'package:kaonic/service/new/kaonic_communication_service.dart';
import 'package:rxdart/subjects.dart';

class ChatService {
  late final KaonicCommunicationService _kaonicService;

  ChatService(KaonicCommunicationService kaonicService) {
    _kaonicService = kaonicService;
    _listenMessages();
  }

  final _messagesSubject = BehaviorSubject<Map<String, List<KaonicEvent>>>();

  final _contactChats = <String, String>{};

  void _listenMessages() {
    _kaonicService.messageStream.listen((message) {
      if (message.data is MessageTextEvent) {
        _handleTextMessage(message);
      }

// TODO redo with new KaoniEvent
      // else if (message.type == KaonicEventType.fileMessage) {
      //   // TODO replace with file message handling
      //   _handleTextMessage(message);
      // }
      //else if (message.type == KaonicEventType.chatCreate) {
      //   _putOrUpdateChatId(message);
      // }
    });
  }

  // TODO redo with new KaoniEvent
  // void _putOrUpdateChatId(KaonicEventModel message) {
  //   if (message.address == null || message.chatId == null) return;

  //   _contactChats[message.address!] = message.chatId!;
  // }

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

  Future<dynamic> getChatMessages(String chatId) async {
    final messages = await _kaonicService.getChatMessages(chatId);
    return messages;
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
}
