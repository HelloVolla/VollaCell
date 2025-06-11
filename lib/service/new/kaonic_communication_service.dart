import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kaonic/data/models/kaonic_new/kaonic_event.dart';
import 'package:kaonic/data/models/kaonic_new/kaonic_event_type.dart';
import 'package:kaonic/data/models/kaonic_new/kaonic_message_event.dart';
import 'package:rxdart/subjects.dart';

class KaonicCommunicationService {
  final kaonicMethodChannel =
      MethodChannel('network.beechat.app.kaonic/kaonic');
  final kaonicEventChannel =
      EventChannel('network.beechat.app.kaonic/kaonicEventsStream');

  final _nodesSubject = BehaviorSubject<List<String>>();
  Stream<List<String>> get nodes => _nodesSubject.stream;

  final _eventsController = StreamController<KaonicEvent>.broadcast();
  Stream<KaonicEvent> get eventsStream =>
      _eventsController.stream.asBroadcastStream();

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
    kaonicMethodChannel.invokeMethod('sendFileMessage', {
      "address": address,
      "filePath": filePath,
    });
  }

  void sendConfig(int mcs, int optionNumber, int module, int frequency,
      int channel, int channelSpacing, int txPower) {
    kaonicMethodChannel.invokeMethod('sendConfig', {
      "mcs": mcs,
      "optionNumber": optionNumber,
      "module": module,
      "frequency": frequency,
      "channel": channel,
      "channelSpacing": channelSpacing,
      "txPower": txPower,
    });
  }

  void _listenKaonicEvents(dynamic event) {
    try {
      final eventJson = jsonDecode(event) as Map<String, dynamic>;
      if (eventJson.containsKey('type')) return;

      final eventType = eventJson['type']?.toString() ?? '';

      KaonicEvent? kaonicEvent;
      switch (eventType) {
        case KaonicEventType.CONTACT_FOUND:
          final address = eventJson.containsKey('data')
              ? (event['data'] as Map<String, dynamic>)['address']
                      ?.toString() ??
                  ''
              : '';
          if (address.isNotEmpty && !_nodesSubject.value.contains(address)) {
            _nodesSubject.add([..._nodesSubject.value, address]);
          }
          return;
        case KaonicEventType.MESSAGE_TEXT:
          kaonicEvent = KaonicEvent<MessageTextEvent>.fromJson(
              eventJson,
              (json) =>
                  MessageTextEvent.fromJson(json as Map<String, dynamic>));
        case KaonicEventType.MESSAGE_FILE:
          kaonicEvent = KaonicEvent<MessageFileEvent>.fromJson(
              eventJson,
              (json) =>
                  MessageFileEvent.fromJson(json as Map<String, dynamic>));
      }

      if (kaonicEvent != null) {
        _eventsController.add(kaonicEvent);
      }
    } catch (e) {
      print(e.toString());

      return;
    }
  }
}
