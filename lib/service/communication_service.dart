import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:kaonic/data/models/meah_chat.dart';
import 'package:kaonic/data/models/mesh_address.dart';
import 'package:kaonic/data/models/mesh_call.dart';
import 'package:kaonic/data/models/mesh_message.dart';
import 'package:kaonic/data/models/mesh_node.dart';
import 'package:kaonic/data/models/radio_address.dart';
import 'package:kaonic/data/models/user_model.dart';
import 'package:kaonic/service/call_service.dart';
import 'package:kaonic/service/device_service.dart';
import 'package:kaonic/service/mesh_service.dart';

class CommunicationService {
  CommunicationService({required DeviceService deviceService})
      : _deviceService = deviceService;
  final DeviceService _deviceService;
  MeshService? _meshService;
  StreamSubscription? _packetSubscription;
  CallService? _callService;
  Timer? _advertiseTimer;

  Stream<Map<String, MeshNode>>? get nodes => _meshService?.nodes;
  Stream<Map<String, MeshChat>>? get chats => _meshService?.chats;
  Stream<MeshFileMessage?>? get fileEvents => _meshService?.meshFilesEvents;
  Stream<MeshCall>? get callStatusStream => _meshService?.callStatusStream;
  MeshCall? get callStatusValue => _meshService?.callStatusValue;

  void dispose() {
    _packetSubscription?.cancel();
    _advertiseTimer?.cancel();
  }

  void initializeCommunicationLayer(UserModel user) {
    _meshService = MeshService(_deviceService, user.key);
    _initMeshService();

    _callService = CallService(_meshService!);
  }

  Future<void> stopAudio() async {
    await _callService?.stopAudio();
  }

  Future<void> stopCall() async {
   // await _meshService?.stopCurrentCall();
    await _callService?.stopCall();
  }

  Future<void> acceptCall(MeshAddress address) async {
    await _meshService?.acceptIncomingCall();
    await startSendAudio(address);
  }

  Future<void>? startSendAudio(MeshAddress address) =>
      _callService?.startCall(address);

  Future<void>? initiateCall(RadioAddress address) =>
      _meshService?.startCall(address);

  Future<void>? sendFile(
          MeshAddress address, String fileName, Uint8List? fileBytes, String filePath) =>
      _meshService?.sendFile(address  , fileName, fileBytes, filePath);

  void sendMessage(MeshAddress address, String message) =>
      _meshService?.sendMessage(address, message);

  void markMessageRead(MeshAddress address) =>
      _meshService?.markMessageRead(address.toHex());

  void _initMeshService() {
    if (_meshService == null) return;

    _packetSubscription =
        _deviceService.packetStream.listen(_meshService!.handlePacket);

    _meshService!.setPacketStream(_deviceService.packetStream);

    _advertiseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_meshService == null) {
        timer.cancel();
        return;
      }
      _meshService!.advertise();
    });
  }
}
