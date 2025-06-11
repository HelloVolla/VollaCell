import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kaonic/data/models/kaonic_event.dart';

class KaonicCommunicationService {
  final kaonicMethodChannel =
      MethodChannel('network.beechat.app.kaonic/kaonic');
  final kaonicEventChannel =
      EventChannel('network.beechat.app.kaonic/kaonicEventsStream');

  final _messageController = StreamController<KaonicEvent>.broadcast();

  Stream<KaonicEvent> get messageStream =>
      _messageController.stream.asBroadcastStream();

  KaonicCommunicationService() {
    kaonicEventChannel.receiveBroadcastStream().listen(_listenKaonicEvents);
  }

  Future<String> createChat(String address) async {
    return await kaonicMethodChannel
        .invokeMethod('createChat', {"address": address});
  }

  void sendTextMessage(String address, String message) {
    kaonicMethodChannel.invokeMethod('sendTextMessage', {
      "address": address,
      "message": message,
    });
  }

  void sendFileMessage(String address, String filePath) {
    kaonicMethodChannel.invokeMethod('sendTextMessage', {
      "address": address,
      "filePath": filePath,
    });
  }

  void sendConfig(int mcs, int optionNumber, int module, int frequency,
      int channel, int channelSpacing, int txPower) {
    kaonicMethodChannel.invokeMethod('sendTextMessage', {
      "mcs": mcs,
      "optionNumber": optionNumber,
      "module": module,
      "frequency": frequency,
      "channel": channel,
      "channelSpacing": channelSpacing,
      "txPower": txPower,
    });
  }

  Future<List<KaonicEvent>> getChatMessages(String chatId) async {
    final messages = await kaonicMethodChannel.invokeMethod('getChatMessages');
    final json = jsonDecode(messages);

    return (json as List).map((message) {
      return KaonicEvent<MessageTextEvent>.fromJson(message,
          (json) => MessageTextEvent.fromJson(json as Map<String, dynamic>));
    }).toList();
  }

  void _listenKaonicEvents(dynamic event) {
    try {
      // final kaonicEvent = KaonicEventModel.fromJson(event);
      final json = jsonDecode(event);
      if (json['type'] == 'Message') {
        final message = KaonicEvent<MessageTextEvent>.fromJson(json,
            (json) => MessageTextEvent.fromJson(json as Map<String, dynamic>));

        _messageController.add(message);
      } else if (json['type'] == 'MessageFile') {
        // TODO
      }

      // if ([
      //   KaonicEventType.textMessage,
      //   KaonicEventType.fileMessage,
      // ].contains(kaonicEvent.type)) {
      //   _messageController.add(kaonicEvent);
      // }

      // final eventMap = (event as Map).map(
      //   (key, value) => MapEntry(key.toString(), value),
      // );
      // TODO: convert map to KaonicEvent<KaonicEventData>
      //       and push it to eventController here
    } catch (e) {
      print(e.toString());

      return;
    }
  }
}
