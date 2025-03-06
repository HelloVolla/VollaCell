import 'package:cryptography/cryptography.dart';
import 'package:kaonic/data/models/user_keys.dart';

class CryptoUtils {
  Future<UserKeys> generateKeys() async {

    final ec = X25519();

    final keyPair = await (await ec.newKeyPair()).extract();
    final privateKey = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();

    return UserKeys(privateKey: privateKey, publicKey: publicKey.bytes);
  }
}
