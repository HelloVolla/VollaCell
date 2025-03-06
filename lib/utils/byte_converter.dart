import 'dart:typed_data';
import 'package:convert/convert.dart';

abstract class ByteConverter {
  static String bytesToHex(Uint8List data) {
    return data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  static List<int> hexToBytes(String data) => hex.decode(data);

  static String listToHex(List<int> data) {
    return data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  static int bytesToInt32(List<int> list, {int start = 0}) {
    if ((start + 4) <= list.length) {
      final value = (list[start + 3] << 24) |
          (list[start + 2] << 16) |
          (list[start + 1] << 8) |
          (list[start + 0] << 0);

      return value;
    }

    return 0;
  }

  static List<int> bytesFromInt32(int value, List<int> list, int start) {
    if ((start + 4) <= list.length) {
      list[start + 3] = (value >> 24) & 0xFF;
      list[start + 2] = (value >> 16) & 0xFF;
      list[start + 1] = (value >> 8) & 0xFF;
      list[start + 0] = (value >> 0) & 0xFF;
    }

    return list;
  }

  static int crc32(List<int> data, int start, int size) {
    const int polynomial = 0xEDB88320;
    int crc = 0xFFFFFFFF;

    for (int j = 0; j < size; ++j) {
      final byte = data[j + start];
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 1) != 0) {
          crc = (crc >> 1) ^ polynomial;
        } else {
          crc >>= 1;
        }
      }
    }

    return crc ^ 0xFFFFFFFF;
  }
}
