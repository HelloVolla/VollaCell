
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:kaonic/data/models/mesh_address.dart';

class MeshNode {
  final MeshAddress _address;

  var _lastAdvertiseTime = DateTime.now();
  var sequence = 0;

  MeshNode(this._address);

  MeshAddress address() => _address;
  

  bool isOnline() {
    return _lastAdvertiseTime.difference(DateTime.now()).inSeconds < 20;
  }

  void updateAdvertiseTime() {
    _lastAdvertiseTime = DateTime.now();
  }

  Future<Uint8List> encrypt(List<int> clearText) async {
    return Uint8List.fromList(clearText);
    // final aes = AesGcm.with256bits();
    // final secretBox = await aes.encrypt(clearText, secretKey: _secretKey);
    // return secretBox.concatenation();
  }

  Future<Uint8List> decrypt(List<int> cipherText) async {
    // final aes = AesGcm.with256bits();
    // final secretBox = SecretBox.fromConcatenation(cipherText,
    //     nonceLength: AesGcm.defaultNonceLength,
    //     macLength: aes.macAlgorithm.macLength);
    // final clearText = await aes.decrypt(secretBox, secretKey: _secretKey);
    return Uint8List.fromList(cipherText);
  }
}
