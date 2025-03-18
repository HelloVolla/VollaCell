import 'dart:async';

import 'package:flutter/services.dart';
import 'package:kaonic/data/models/radio_address.dart';
import 'package:kaonic/data/models/radio_packet.dart';

enum TrxType {
  rf_09(0),
  rf_24(1);

  const TrxType(this.id);

  final int id;
}

class RadioConfig {
  final int frequency;
  final int spacing;
  final int channel;
  final int rfIndex;
  final TrxType trxType;

  RadioConfig({
    this.frequency = 869400,
    this.spacing = 200,
    this.channel = 1,
    this.rfIndex = 1,
  }) : trxType = frequency >= 2400000 ? TrxType.rf_24 : TrxType.rf_09;
}

class DeviceService {
  static const platform = MethodChannel('com.example.kaonic/kaonic');
  static const eventChannel =
      EventChannel('network.beechat.app.kaonic/packetStream');

  final _packetStreamController = StreamController<RadioPacket>.broadcast();
  Stream<RadioPacket> get packetStream => _packetStreamController.stream;

  var _config = RadioConfig();
  var _txCounter = 0;
  var _rxCounter = 0;

  Timer? _searchDevicesTimer;

  DeviceService() {
    _handleAdvChannel(eventChannel.receiveBroadcastStream());
  }

  Future<void> startUser(String userKey) async {
    return await platform.invokeMethod('userStart', {"key": userKey});
  }

  Future<void> transmit(RadioPacket packet) async {
    final packetBytes = packet.toBytes();
    if (packetBytes.length > 2048) {
      throw Exception("tx buffer overflow");
    }

    final rc = await platform.invokeMethod('kaonicTransmit', {
      "address": packet.dstAddress.toHex(),
      "data": packetBytes,
    });

    if (rc >= 0) {
      _txCounter++;
    } else {
      throw Exception("rf tx error - $rc");
    }
  }

  void _handleAdvChannel(Stream<dynamic> stream) {
    stream.listen((value) {
      final data = (value as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final type = data["type"];
      switch (type) {
        case "ANNOUNCE":
          final srcAddress = data["srcAddress"] as String;
          _packetStreamController.add(RadioPacket()
              .broadcast()
              .withSrcAddress(RadioAddress.fromHex(srcAddress))
              .withType(RadioPacketType.advertise)
              .withFlag(RadioPacket.flagPublic)
              .withFlag(RadioPacket.flagBroadcast));
          break;
        case "PACKET":
          // final srcAddress = data["srcAddress"] as String;
          final dstAddress = data["dstAddress"] as String;
          var packet = RadioPacket.fromBytes(data["data"] as Uint8List);
          if (packet != null) {
            // packet.srcAddress.copy(RadioAddress.fromHex(srcAddress));
            packet.dstAddress.copy(RadioAddress.fromHex(dstAddress));

            print(
                "received packet ${packet.srcAddress.toHex()} ${packet.dstAddress.toHex()}");

            _packetStreamController.add(packet);
          }
          break;
      }
    });
  }
}
