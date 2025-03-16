// ignore_for_file: avoid_print


import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:async/async.dart';

import 'dart:async';

import 'package:kaonic/data/models/mesh_address.dart';
import 'package:kaonic/data/models/mesh_message.dart';
import 'package:kaonic/data/models/radio_packet.dart';
import 'package:kaonic/service/mesh_service.dart';

class CallService {
  static const eventChannel = EventChannel('com.example.kaonic/audioStream');
  static const platform = MethodChannel('com.example.kaonic/kaonic');
  static const sampleRate = 4800;
  // static const Codec codec = Codec.pcm16;
  static const timeoutDuration = Duration(seconds: 10);

  var _running = false;
  var _lastVoiceTime = DateTime.now();
  var _callStartTime = DateTime.now();

  Timer? _callTimer;

  MeshAddress? _clientAddress;

  final _voiceBuffer = List<int>.empty(growable: true);

  final MeshService _meshService;

  CallService(this._meshService) {
    _initService().then((_) {
      // startCall(MeshAddress());
    });
  }

  Future<void> _feedPlayer(Uint8List data) async {
    return await platform.invokeMethod('feedPlayer', {"data": data});
  }

  Future<void> _playHandler(StreamQueue<MeshVoice> streamQueue) async {
    while (await streamQueue.hasNext) {
      final meshVoice = await streamQueue.next;
      if (_running) {
        if (meshVoice.address.equals(_clientAddress!)) {
          await _feedPlayer(meshVoice.data);
          _lastVoiceTime = DateTime.now();
        }
      }
    }
  }

  Future<void> _recordHandler(Stream<dynamic> stream) async {
    final chunkStream = ChunkedStreamReader(stream.map((record) =>
        (record["data"] as Uint8List)
            .sublist(0, record["count"] as int)
            .toList()));

    while (true) {
      final data = await chunkStream.readBytes(RadioPacket.maxPayloadSize);
      if (_running) {
        await _meshService.sendCallVoice(_clientAddress!, data);
      }
    }
  }

  Future<void> _initService() async {
    _playHandler(StreamQueue(_meshService.voiceStream)).then((_) {});

    _recordHandler(eventChannel.receiveBroadcastStream()).then((_) {});
  }

  Future<void> startCall(MeshAddress clientAddress) async {
    if (_running) {
      return;
    }

    print("start call with ${clientAddress.toHex()}");

    _clientAddress = clientAddress;
    _running = true;
    _lastVoiceTime = DateTime.now();
    _callStartTime = DateTime.now();

    _callTimer = Timer.periodic(CallService.timeoutDuration, (_) async {
      if (_lastVoiceTime.difference(DateTime.now()).inSeconds >
          CallService.timeoutDuration.inSeconds) {
        print("call timed out!");

        await stopCall();
      }
    });

    platform.invokeMethod('startAudio');
  }

  Future<void> stopAudio() async {
    await platform.invokeMethod('stopAudio');
  }

  Future<void> stopCall() async {
    if (_running) {
      print("stop call with ${_clientAddress!.toHex()}");
      _callTimer!.cancel();
    }
    
    _running = false;
    _clientAddress = null;
    _callTimer = null;

    await stopAudio();

    await _meshService.stopCurrentCall();
  }
}
