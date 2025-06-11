import 'package:flutter/services.dart';

class KaonicCommunicationService {
  final kaonicMethodChannel =
      MethodChannel('network.beechat.app.kaonic/kaonic');
  static const kaonicEventChannel =
      EventChannel('network.beechat.app.kaonic/kaonicEventsStream');

  KaonicCommunicationService() {
    kaonicEventChannel.receiveBroadcastStream().listen(_listenKaonicEvents);
  }

  void createChat(String address, String chatId) {
    kaonicMethodChannel.invokeMethod('createChat', {
      "address": address,
      "chatId": chatId,
    });
  }

  void sendTextMessage(String address, String chatId, String message) {
    kaonicMethodChannel.invokeMethod('sendTextMessage', {
      "address": address,
      "chatId": chatId,
      "message": message,
    });
  }

  void sendFileMessage(String address, String chatId, String filePath) {
    kaonicMethodChannel.invokeMethod('sendTextMessage', {
      "address": address,
      "chatId": chatId,
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

  void _listenKaonicEvents(dynamic event) {
    try {
      final eventMap = (event as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );
      // TODO: convert map to KaonicEvent<KaonicEventData> 
      //       and push it to eventController here
    } catch (e) {
      print(e.toString());

      return;
    }
  }
}
