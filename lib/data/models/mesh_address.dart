
import 'package:cryptography/cryptography.dart';
import 'package:kaonic/data/models/radio_address.dart';

class MeshAddress extends RadioAddress {
  static Future<MeshAddress> fromPublicKey(SimplePublicKey publicKey) async {
    final sink = Sha256().newHashSink();
    sink.add(publicKey.bytes);

    sink.close();
    final address = MeshAddress.fromHash(await sink.hash());
    return address;
  }

  static MeshAddress fromHash(Hash hash) {
    final address = MeshAddress();

    address.setBytes(hash.bytes);

    return address;
  }

  static MeshAddress fromRadio(RadioAddress radioAddress) {
    final address = MeshAddress();
    address.copy(radioAddress);
    return address;
  }
}
