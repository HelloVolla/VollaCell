import 'dart:typed_data';

import 'package:kaonic/data/models/radio_address.dart';

import '../../utils/byte_converter.dart';

enum RadioPacketType {
  none(0x00),
  advertise(0x01),
  message(0x02),
  chunk(0x03),
  ping(0x04),
  callInvoke(0x05),
  callVoice(0x06),
  callAnswer(0x07),
  callReject(0x08),
  ok(0x09),
  fileStart(0x0A),
  fileChunk(0x0B),
  fileEnd(0x0C);

  final int id;
  const RadioPacketType(this.id);

  static RadioPacketType fromInt(int id) {
    return RadioPacketType.values
        .firstWhere((e) => e.id == id, orElse: () => RadioPacketType.none);
  }
}

class RadioPacket {
  // Constants
  static const magic = 0xB1;
  static const maxPayloadSize = 256;
  static const minPacketSize = 1 +
      1 +
      1 +
      2 +
      4 +
      RadioAddress.addressSize +
      RadioAddress.addressSize +
      4 +
      4;

  static const flagBroadcast = 0x01 << 0;
  static const flagUnicast = 0x01 << 1;
  static const flagPublic = 0x01 << 2;
  static const flagPrivate = 0x01 << 3;
  static const flagAknowladge = 0x01 << 4;
  static const flagReceived = 0x01 << 5;

  // Data
  var flags = 0; // 8 bytes
  var type = RadioPacketType.none; // 8 bytes
  var sequence = 0;

  final dstAddress = RadioAddress();
  final srcAddress = RadioAddress();

  var _payloadLength = 0;
  var _payload = Uint8List(0);

  RadioPacket();

  bool hasFlag(int flag) {
    return (flags & flag) == flag;
  }

  Uint8List payload() => _payload;

  RadioPacket withSequence(int sequence) {
    this.sequence = sequence;
    return this;
  }

  RadioPacket withPayload(Uint8List payload) {
    _payloadLength = payload.length;
    _payload = payload;
    return this;
  }

  RadioPacket withPayloadList(List<int> payload) {
    _payloadLength = payload.length;
    _payload = Uint8List.fromList(payload);
    return this;
  }

  RadioPacket withType(RadioPacketType type) {
    this.type = type;
    return this;
  }

  RadioPacket withFlag(int flag) {
    flags = flags | flag;
    return this;
  }

  RadioPacket withSrcAddress(RadioAddress address) {
    srcAddress.copy(address);
    return this;
  }

  RadioPacket broadcast() {
    flags = flags | flagBroadcast;
    dstAddress.reset();
    return this;
  }

  RadioPacket unicast(RadioAddress address) {
    flags = flags | flagUnicast;
    dstAddress.copy(address);
    return this;
  }

  static RadioPacket? fromBytes(Uint8List bytes) {
    // Check minimal size of the packet
    if (bytes.length < minPacketSize || bytes[0] != magic) {
      return null;
    }

    final expectedCrc =
        ByteConverter.bytesToInt32(bytes, start: bytes.length - 4);

    final actualCrc = ByteConverter.crc32(bytes, 0, bytes.length - 4);

    // Check if packet is correct
    if (expectedCrc != actualCrc) {
      return null;
    }

    final packet = RadioPacket();

    var offset = 1;

    packet.flags = bytes[offset];
    offset += 1;

    packet.type = RadioPacketType.fromInt(bytes[offset]);
    offset += 1;

    packet.sequence = ByteConverter.bytesToInt32(bytes, start: offset);
    offset += 4;

    offset += 2;

    for (int i = 0; i < RadioAddress.addressSize; ++i) {
      packet.dstAddress.setByte(i, bytes[offset + i]);
    }

    offset += RadioAddress.addressSize;

    for (int i = 0; i < RadioAddress.addressSize; ++i) {
      packet.srcAddress.setByte(i, bytes[offset + i]);
    }

    offset += RadioAddress.addressSize;

    packet._payloadLength = ByteConverter.bytesToInt32(bytes, start: offset);

    offset += 4;

    if (packet._payloadLength + offset > bytes.length) {
      return null;
    }

    packet._payload = Uint8List.fromList(
        bytes.sublist(offset, offset + packet._payloadLength));

    return packet;
  }

  Uint8List toBytes() {
    final bytes = Uint8List(minPacketSize + _payload.length);

    var offset = 0;

    bytes[offset] = magic;
    offset += 1;

    bytes[offset] = flags;
    offset += 1;

    bytes[offset] = type.id;
    offset += 1;

    ByteConverter.bytesFromInt32(sequence, bytes, offset);
    offset += 4;

    offset += 2;

    for (int i = 0; i < RadioAddress.addressSize; ++i) {
      bytes[offset + i] = dstAddress[i];
    }

    offset += RadioAddress.addressSize;

    for (int i = 0; i < RadioAddress.addressSize; ++i) {
      bytes[offset + i] = srcAddress[i];
    }

    offset += RadioAddress.addressSize;

    ByteConverter.bytesFromInt32(_payload.length, bytes, offset);
    offset += 4;

    for (var byte in _payload) {
      bytes[offset] = byte;
      offset++;
    }

    final crc = ByteConverter.crc32(bytes, 0, offset);

    ByteConverter.bytesFromInt32(crc, bytes, offset);
    offset += 4;

    return bytes;
  }
}
