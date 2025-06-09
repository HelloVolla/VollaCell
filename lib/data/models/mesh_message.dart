import 'dart:convert';
import 'dart:typed_data';

import 'package:kaonic/data/models/radio_address.dart';

class MeshMessage {
  MeshMessage({
    required this.senderAddress,
    this.sentAt,
  });
  final String senderAddress;
  final DateTime? sentAt;
}

class MeshTextMessage extends MeshMessage {
  MeshTextMessage({
    required super.senderAddress,
    required super.sentAt,
    required this.message,
  });
  factory MeshTextMessage.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr);
    if (map is Map<dynamic, dynamic> &&
        map.containsKey('senderAddress') &&
        map.containsKey('message')) {
      return MeshTextMessage(
        senderAddress: map['senderAddress'],
        message: map['message'],
        sentAt: map['sentAt'],
      );
    }

    return MeshTextMessage(
      senderAddress: '-',
      message: '-',
      sentAt: DateTime.now(),
    );
  }
  final String message;

  String toJsonString() =>
      jsonEncode({'senderAddress': senderAddress, 'message': message});
}

class MeshFileMessage extends MeshMessage {
  MeshFileMessage(
      {required super.senderAddress,
      required super.sentAt,
      required this.fileName,
      this.localPath,
      this.bytes});
  String? localPath;
  final String fileName;
  List<int>? bytes;

  Uint8List get image => Uint8List.fromList(bytes ?? []);
}

class MeshVoice {
  final RadioAddress address;
  final Uint8List data;

  MeshVoice(this.address, this.data);
}
