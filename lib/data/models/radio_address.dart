import 'dart:typed_data';

import 'package:kaonic/utils/byte_converter.dart';

class RadioAddress {
  static const addressSize = 16;

  final _data = Uint8List(RadioAddress.addressSize);

  static RadioAddress fromBytes(Uint8List bytes) {
    final address = RadioAddress();
    address.setBytes(bytes);
    return address;
  }

  void reset() {
    _data.fillRange(0, _data.length, 0);
  }

  void setByte(int index, int byte) {
    _data[index] = byte;
  }

  void setBytes(List<int> bytes) {
    for (int i = 0; i < _data.length; ++i) {
      _data[i] = bytes[i];
    }
  }

  void copy(RadioAddress rhs) {
    setBytes(rhs._data);
  }

  bool isEmpty() {
    for (int i = 0; i < _data.length; ++i) {
      if (_data[i] != 0) {
        return false;
      }
    }

    return true;
  }

  bool equals(RadioAddress rhs) {
    for (int i = 0; i < _data.length; ++i) {
      if (_data[i] != rhs._data[i]) {
        return false;
      }
    }
    return true;
  }

  Uint8List asBytes() {
    return _data;
  }

  String toHex() {
    return ByteConverter.bytesToHex(_data);
  }

  static RadioAddress fromHex(String hex) {
    final address = RadioAddress();
    final hexAddress = ByteConverter.hexToBytes(hex);

    for (int i = 0; i < address._data.length; ++i) {
      address._data[i] = hexAddress[i];
    }

    return address;
  }

  int operator [](int index) {
    return _data[index]; // Access the list element at the given index
  }

  void operator []=(int index, int value) {
    _data[index] = value;
  }

  int get length => _data.length;
}
