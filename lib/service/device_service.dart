import 'dart:async';

import 'package:flutter/services.dart';
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
  static const eventChannel = EventChannel('com.example.kaonic/packetStream');

  final _packetStreamController = StreamController<RadioPacket>.broadcast();
  Stream<RadioPacket> get packetStream => _packetStreamController.stream;

  var _config = RadioConfig();
  var _txCounter = 0;
  var _rxCounter = 0;

  Timer? _searchDevicesTimer;

  DeviceService() {
    _handleAdvChannel(eventChannel.receiveBroadcastStream());
    // _enumerateDevices();
  }

  Future<void> _openDevice(String deviceName) async {
    try {
      final opened =
          await platform.invokeMethod('openDevice', {"deviceName": deviceName});
      if (opened) {
        configure(RadioConfig());
      } else {
        //_enumerateDevices();
      }
    } on PlatformException catch (e) {
      print("Failed to call write: '${e.message}'");
      // _enumerateDevices();
    }
  }

  void startUser(String userKey) async {
    await platform.invokeMethod('userStart', {"key": userKey});
  }

  Future<void> configure(RadioConfig config) async {
    _config = config;

    final rc = await platform.invokeMethod('kaonicConfigure', {
      "rfIndex": _config.rfIndex,
      "freq": _config.frequency,
      "spacing": _config.spacing,
      "channel": _config.channel,
    });

    _startReceive();
  }

  Future<void> closeDevice() async {}

  Future<void> transmit(packet) async {
    final packetBytes = packet.toBytes();
    if (packetBytes.length > 2048) {
      throw Exception("tx buffer overflow");
    }

    final rc = await platform.invokeMethod('kaonicTransmit', {
      "data": packetBytes,
    });

    if (rc >= 0) {
      _txCounter++;
    } else {
      throw Exception("rf tx error - $rc");
    }
  }

  void _startReceive() {}

  void _enumerateDevices() {
    _searchDevicesTimer?.cancel();
    // _searchDevicesTimer =
    //     Timer.periodic(const Duration(seconds: 1), (timer) async {
    //   final devices = await platform.invokeMethod('enumerateDevices');
    //
    //   if (devices is List<dynamic> && devices.isNotEmpty) {
    //     _openDevice(devices.first);
    //     timer.cancel();
    //   }
    // });
  }

  void _handleAdvChannel(Stream<dynamic> stream) {
    stream.listen((value) {
      if (value is List<int>) {
        final radioPacket = RadioPacket.fromBytes(Uint8List.fromList(value));
        if (radioPacket == null) return;

        _packetStreamController.add(radioPacket);
      }
    });
  }
}
