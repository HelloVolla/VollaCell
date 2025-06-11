// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:intl/intl.dart';
import 'package:kaonic/data/models/meah_chat.dart';
import 'package:kaonic/data/models/mesh_address.dart';
import 'package:kaonic/data/models/mesh_call.dart';
import 'package:kaonic/data/models/mesh_message.dart';
import 'package:kaonic/data/models/mesh_node.dart';
import 'package:kaonic/data/models/radio_address.dart';
import 'package:kaonic/data/models/radio_packet.dart';
import 'package:kaonic/service/device_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

abstract class MeshServiceExceptions implements Exception {}

class MeshServiceUnknownNodeAddressException extends MeshServiceExceptions {}

class MeshService {
  final DeviceService _deviceService;
  final String _key;
  late final SimplePublicKey _publicKey;
  late final MeshAddress _address;

  var packetSequence = 0;

  Stream<RadioPacket>? _packetStream;

  /// nodes findNearby
  final BehaviorSubject<Map<String, MeshNode>> _nodes =
      BehaviorSubject.seeded({});
  Stream<Map<String, MeshNode>> get nodes => _nodes.stream;

  /// messagings
  final BehaviorSubject<Map<String, MeshChat>> _chats =
      BehaviorSubject.seeded({});
  Stream<Map<String, MeshChat>> get chats => _chats.stream;

  /// messagings
  final BehaviorSubject<MeshFileMessage?> _meshFilesEvents =
      BehaviorSubject.seeded(null);
  Stream<MeshFileMessage?> get meshFilesEvents => _meshFilesEvents.stream;

  /// Call Voice
  final _voiceStreamController = StreamController<MeshVoice>.broadcast();
  Stream<MeshVoice> get voiceStream => _voiceStreamController.stream;

  /// Call status
  final BehaviorSubject<MeshCall> _callStatus =
      BehaviorSubject.seeded(MeshCall());
  Stream<MeshCall> get callStatusStream => _callStatus.stream;
  MeshCall get callStatusValue => _callStatus.value;
  Timer? _automaticallyEndCallTimer;

  MeshService(this._deviceService, this._key) {
    // _address =
    //     MeshAddress.fromRadio(RadioAddress.fromHex(_key.substring(64 * 2)));
    _address =
        MeshAddress.fromRadio(RadioAddress.fromHex(_key));

    print("start mesh service /${_address.toHex()}/");
  }

  void _updateChatWithTextMessage({
    required String address,
    required String message,
    bool isMyMessage = false,
  }) {
    final Map<String, MeshChat> newChats = Map.from(_chats.value);
    newChats[address] = MeshChat(
      messages: [
        ...newChats[address]?.messages ?? [],
        MeshTextMessage(
            senderAddress: isMyMessage ? _address.toHex() : address,
            message: message)
      ],
      unreadMessagesCount: (newChats[address]?.unreadMessagesCount ?? 0) + 1,
    );

    _chats.add(newChats);
  }

  MeshFileMessage _updateChatWithFileFromMeMessage({
    required String address,
    required String filePath,
    required String fileName,
  }) {
    final Map<String, MeshChat> newChats = Map.from(_chats.value);
    final fileMessage = MeshFileMessage(
        senderAddress: _address.toHex(),
        localPath: filePath,
        fileName: fileName);
    newChats[address] = MeshChat(
      messages: [...newChats[address]?.messages ?? [], fileMessage],
      unreadMessagesCount: (newChats[address]?.unreadMessagesCount ?? 0) + 1,
    );

    _chats.add(newChats);
    return fileMessage;
  }

  void markMessageRead(String address) =>
      _chats.value[address]?.unreadMessagesCount = 0;

  Future<void> _handleAdvertisePacket(RadioPacket packet) async {
    final address = MeshAddress.fromRadio(packet.srcAddress);

    final addressHex = address.toHex();
    final isNewMessage = !_nodes.value.containsKey(addressHex);

    Map<String, MeshNode> updatedNodes = {}..addAll(_nodes.value);

    if (isNewMessage) {
      updatedNodes[addressHex] = MeshNode(address);

      // ignore: avoid_print
      print("mesh: new node discovered $addressHex");
    } else {
      final node = findNodeByAddress(address);
      if (node != null) {
        node.updateAdvertiseTime();
      }
    }

    _nodes.add(updatedNodes);
  }

  Future<void> _handleMessagePacket(
      RadioPacket packet, Uint8List clearPayload) async {
    final addressHex = packet.srcAddress.toHex();

    _updateChatWithTextMessage(
        address: addressHex, message: utf8.decode(clearPayload));
  }

  Future<void> _handleCallVoicePacket(
      RadioPacket packet, Uint8List clearPayload) async {
    final decodedVoice = clearPayload;

    _voiceStreamController.add(MeshVoice(
      packet.srcAddress,
      decodedVoice,
    ));
  }

  Future<void> _handleCallInvokePacket(RadioPacket packet) async {
    // Already in call, or waiting for response.
    // Reject income call.
    if (_callStatus.value.status != MeshCallStatuses.none) {
      await sendEmptyMessageWithType(
          address: packet.srcAddress, type: RadioPacketType.callReject);

      return;
    }

    _callStatus.add(MeshCall(
        address: packet.srcAddress, status: MeshCallStatuses.incomingCall));
  }

  Future<void> _handleCallAnswerPacket(RadioPacket packet) async {
    // User not started call
    if (!(_callStatus.value.address?.equals(packet.srcAddress) ?? false) ||
        _callStatus.value.status != MeshCallStatuses.outcomeCall) return;

    _automaticallyEndCallTimer?.cancel();
    _callStatus
        .add(_callStatus.value.copyWith(status: MeshCallStatuses.inCall));
  }

  Future<void> _handleCallRejectPacket(RadioPacket packet) async {
    // User not in in call or finished him
    if (!(_callStatus.value.address?.equals(packet.srcAddress) ?? false) ||
        _callStatus.value.status == MeshCallStatuses.none ||
        _callStatus.value.status == MeshCallStatuses.ended) return;

    // Ended call
    _callStatus.add(_callStatus.value.copyWith(status: MeshCallStatuses.ended));
    // Empty call
    _callStatus.add(MeshCall());
  }

  Future<void> startCall(RadioAddress address) async {
    await sendEmptyMessageWithType(
        address: address, type: RadioPacketType.callInvoke);

    _automaticallyEndCallTimer =
        Timer(const Duration(seconds: 30), stopCurrentCall);

    _callStatus
        .add(MeshCall(address: address, status: MeshCallStatuses.outcomeCall));
  }

  Future<void> acceptIncomingCall() async {
    if (_callStatus.value.address == null ||
        _callStatus.value.status != MeshCallStatuses.incomingCall) {
      throw Exception('no incoming call');
    }

    sendEmptyMessageWithType(
        address: _callStatus.value.address!, type: RadioPacketType.callAnswer);

    _callStatus
        .add(_callStatus.value.copyWith(status: MeshCallStatuses.inCall));
  }

  Future<void> stopCurrentCall() async {
    if (_callStatus.value.address == null) {
      throw Exception("call not found");
    }

    _automaticallyEndCallTimer?.cancel();
    await sendEmptyMessageWithType(
        address: _callStatus.value.address!, type: RadioPacketType.callReject);

    // Ended call
    _callStatus.add(_callStatus.value.copyWith(status: MeshCallStatuses.ended));
    // Empty call
    _callStatus.add(MeshCall());
  }

  void setPacketStream(Stream<RadioPacket> stream) {
    _packetStream = stream;
  }

  Future<void> handlePacket(RadioPacket packet) async {
    if (!packet.dstAddress.isEmpty() && !packet.dstAddress.equals(_address)) {
      // Filter packets not addressed to us
      return;
    }

    if (packet.hasFlag(RadioPacket.flagReceived)) {
      return;
    }

    Uint8List clearPayload = packet.payload();

    final node = findNodeByAddress(packet.srcAddress);

    if (node != null) {
      if (node.sequence != packet.sequence) {
        print("// packet duplicat //");
      }
    }

    if (node == null ||
        node.sequence != packet.sequence ||
        packet.sequence == 0) {
      // if (packet.hasFlag(RadioPacket.flagPrivate)) {
      //   if (node != null && clearPayload.isNotEmpty) {
      //     clearPayload = await node.decrypt(packet.payload());
      //   }
      // }

      if (packet.sequence != 0) {
        node?.sequence = packet.sequence;
      }

      switch (packet.type) {
        case RadioPacketType.advertise:
          await _handleAdvertisePacket(packet);
        case RadioPacketType.message:
          await _handleMessagePacket(packet, clearPayload);
        case RadioPacketType.callVoice:
          await _handleCallVoicePacket(packet, clearPayload);
        case RadioPacketType.callInvoke:
          await _handleCallInvokePacket(packet);
        case RadioPacketType.callAnswer:
          await _handleCallAnswerPacket(packet);
        case RadioPacketType.callReject:
          await _handleCallRejectPacket(packet);
        case RadioPacketType.fileStart:
          await _handleFileStartPacket(packet, clearPayload);
        case RadioPacketType.fileChunk:
          await _handleFilePacket(packet, clearPayload, isFinalPart: false);
        case RadioPacketType.fileEnd:
          await _handleFilePacket(packet, clearPayload, isFinalPart: true);
        default:
          break;
      }
    }

    if (packet.hasFlag(RadioPacket.flagAknowladge)) {
      await _deviceService.transmit(RadioPacket()
          .withSrcAddress(_address)
          .unicast(packet.srcAddress)
          .withSequence(packet.sequence)
          .withFlag(RadioPacket.flagPublic)
          .withFlag(RadioPacket.flagReceived));
    }
  }

  Future<void> advertise() async {
    return;
    final advertisePacket = RadioPacket()
        .broadcast()
        .withSrcAddress(_address)
        .withType(RadioPacketType.advertise)
        .withFlag(RadioPacket.flagPublic)
        .withSequence(0)
        .withPayloadList(_publicKey.bytes);

    return await _deviceService.transmit(advertisePacket);
  }

  MeshNode? findNodeByAddress(RadioAddress address) {
    return _nodes.value[address.toHex()];
  }

  Future<void> _sendPacket(RadioPacket txPacket) async {
    packetSequence += 1;

    if (packetSequence == 0) {
      packetSequence = 1;
    }

    final txSequence = packetSequence;
    txPacket.withSequence(txSequence);

    if (!txPacket.hasFlag(RadioPacket.flagAknowladge)) {
      return await _deviceService.transmit(txPacket);
    }

    for (int i = 0; i < 8; ++i) {
      final completer = Completer();

      StreamSubscription? sub;

      sub = _packetStream!.listen((rxPacket) {
        if (rxPacket.dstAddress.equals(_address) &&
            rxPacket.hasFlag(RadioPacket.flagReceived) &&
            rxPacket.sequence == txSequence) {
          sub?.cancel();

          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      await _deviceService.transmit(txPacket);

      try {
        await completer.future.timeout(Duration(milliseconds: 500));
        print("// packet ack (${txSequence};${i}) //");
        sub.cancel();
        return;
      } on TimeoutException catch (_) {
        print("// packet nack (${txSequence};${i}) //");
      }

      sub.cancel();
    }

    throw Exception("packet wasn't received");
  }

  Future<void> sendFile(MeshAddress address, String name, Uint8List? fileData,
      String filePath) async {
    final fileMessage = _updateChatWithFileFromMeMessage(
        address: address.toHex(), filePath: filePath, fileName: name);
    final node = findNodeByAddress(address);
    if (node == null || fileData == null) return;

    print("> send file ${filePath}");

    await _sendPacket(RadioPacket()
        .unicast(address)
        .withSrcAddress(_address)
        .withType(RadioPacketType.fileStart)
        .withFlag(RadioPacket.flagPrivate)
        .withFlag(RadioPacket.flagAknowladge)
        .withPayload(await node.encrypt(utf8.encode(name))));

    const maxChunkSize = RadioPacket.maxPayloadSize;

    fileMessage.bytes ??= [];
    for (int i = 0; i < fileData.length; i += maxChunkSize) {
      final chunkSize = min(maxChunkSize, fileData.length - i);

      print("> send file chunk ${i}/${fileData.length}");
      final bytes = fileData.sublist(i, i + chunkSize);
      await _sendPacket(RadioPacket()
          .unicast(node.address())
          .withSrcAddress(_address)
          .withType(RadioPacketType.fileChunk)
          .withFlag(RadioPacket.flagPrivate)
          .withFlag(RadioPacket.flagAknowladge)
          .withPayload(await node.encrypt(bytes)));

      fileMessage.bytes?.addAll(bytes);
      _chats.add(Map.from(_chats.value));
    }

    print("> send file finish");

    await _sendPacket(RadioPacket()
        .unicast(node.address())
        .withSrcAddress(_address)
        .withType(RadioPacketType.fileEnd)
        .withFlag(RadioPacket.flagPrivate)
        .withFlag(RadioPacket.flagAknowladge));
  }

  Future<void> sendMessageToNode(MeshNode node, String message) async {
    final chipherText = await node.encrypt(utf8.encode(message));

    final messagePacket = RadioPacket()
        .unicast(node.address())
        .withSrcAddress(_address)
        .withType(RadioPacketType.message)
        .withFlag(RadioPacket.flagPrivate)
        .withFlag(RadioPacket.flagAknowladge)
        .withPayloadList(chipherText);

    _updateChatWithTextMessage(
        address: node.address().toHex(), message: message, isMyMessage: true);

    return await _sendPacket(messagePacket);
  }

  Future<void> sendEmptyMessageWithType({
    required RadioAddress address,
    required RadioPacketType type,
  }) async {
    final node = findNodeByAddress(address);
    if (node != null) {
      final packet = RadioPacket()
          .unicast(node.address())
          .withSrcAddress(_address)
          .withType(type)
          .withFlag(RadioPacket.flagPrivate);

      await _sendPacket(packet);
    } else {
      throw Exception("node not found");
    }
  }

  Future<void> sendCallVoice(RadioAddress address, Uint8List voiceData) async {
    final node = findNodeByAddress(address);
    if (node != null) {
      final encodedVoice = voiceData;
      final chipherText = await node.encrypt(encodedVoice);

      final packet = RadioPacket()
          .unicast(node.address())
          .withSrcAddress(_address)
          .withType(RadioPacketType.callVoice)
          .withFlag(RadioPacket.flagPrivate)
          .withPayloadList(chipherText);

      await _sendPacket(packet);
    } else {
      throw Exception("node not found");
    }
  }

  Future<void> sendMessage(RadioAddress address, String message) async {
    final node = findNodeByAddress(address);
    if (node != null) {
      await sendMessageToNode(node, message);
    } else {
      throw Exception("node not found");
    }
  }

//"0bf806de7795afe717c8b76affc1f5da"
  _handleFilePacket(RadioPacket packet, Uint8List clearPayload,
      {required bool isFinalPart}) async {
    final Map<String, MeshChat> newChats = Map.from(_chats.value);
    final address = packet.srcAddress.toHex();
    final fileMessages = newChats[packet.srcAddress.toHex()]?.messages.where(
          (e) =>
              e is MeshFileMessage &&
              e.localPath == null &&
              address == e.senderAddress,
        );
    final l = fileMessages?.isEmpty;
    if (fileMessages?.isEmpty ?? true) return;

    final fileMessage = fileMessages!.last as MeshFileMessage;
    fileMessage.bytes ??= [];
    fileMessage.bytes?.addAll(clearPayload);
    print("RadioPacketType.fileChunk");

    if (isFinalPart && fileMessage.bytes != null) {
      final Directory downloadsDir =
          await getDownloadsDirectory() ?? Directory('');
      final f = File('${downloadsDir.path}/${fileMessage.fileName}');
      f.createSync();
      f.writeAsBytes(fileMessage.bytes!);
      fileMessage.localPath = f.path;
      _meshFilesEvents.add(fileMessage);
    }

    _chats.add(Map.from(_chats.value));
  }

  _handleFileStartPacket(RadioPacket packet, Uint8List payload) {
    final Map<String, MeshChat> newChats = Map.from(_chats.value);
    final address = packet.srcAddress.toHex();
    newChats[address] = MeshChat(
      messages: [
        ...newChats[address]?.messages ?? [],
        MeshFileMessage(
            senderAddress: packet.srcAddress.toHex(),
            localPath: null,
            fileName: utf8.decode(payload))
      ],
      unreadMessagesCount: (newChats[address]?.unreadMessagesCount ?? 0) + 1,
    );

    _chats.add(newChats);
  }
}


  // void _updateChatWithFileFromMeMessage({
  //   required String address,
  //   required Uint8List fileBytes,
  // }) {
  //   final Map<String, MeshChat> newChats = Map.from(_chats.value);
  //   final lastFileMessage = newChats[address]?.messages.where(
  //         (e) => e is MeshFileMessage && e.localPath == null && address == e.senderAddress,
  //       );
  //   newChats[address] = MeshChat(
  //     messages: [
  //       ...newChats[address]?.messages ?? [],
  //       MeshFileMessage(senderAddress: _address.toHex(), localPath: filePath)
  //     ],
  //     unreadMessagesCount: (newChats[address]?.unreadMessagesCount ?? 0) + 1,
  //   );

  //   _chats.add(newChats);
  // }