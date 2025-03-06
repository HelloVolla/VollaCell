
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:kaonic/data/models/mesh_address.dart';

class MeshNode {
  final MeshAddress _address;
  final SimplePublicKey _publicKey;
  final SecretKey _secretKey;
  var _lastAdvertiseTime = DateTime.now();
  var sequence = 0;

  MeshNode(this._address, this._publicKey, this._secretKey);

  MeshAddress address() => _address;
  SimplePublicKey publicKey() => _publicKey;

  bool isOnline() {
    return _lastAdvertiseTime.difference(DateTime.now()).inSeconds < 20;
  }

  void updateAdvertiseTime() {
    _lastAdvertiseTime = DateTime.now();
  }

  Future<Uint8List> encrypt(List<int> clearText) async {
    final aes = AesGcm.with256bits();
    final secretBox = await aes.encrypt(clearText, secretKey: _secretKey);
    return secretBox.concatenation();
  }

  Future<Uint8List> decrypt(List<int> cipherText) async {
    final aes = AesGcm.with256bits();
    final secretBox = SecretBox.fromConcatenation(cipherText,
        nonceLength: AesGcm.defaultNonceLength,
        macLength: aes.macAlgorithm.macLength);
    final clearText = await aes.decrypt(secretBox, secretKey: _secretKey);
    return Uint8List.fromList(clearText);
  }
}
