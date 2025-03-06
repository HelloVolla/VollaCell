import 'package:kaonic/data/models/contact_model.dart';
import 'package:objectbox/objectbox.dart';

import '../../objectbox.g.dart';

@Entity()
class UserModel {
  UserModel({
    required this.username,
    required this.passcode,
    this.privateKey = const [],
    this.publicKey = const [],
    required this.id,
    this.logged = false,
  });
  @Id()
  int id;
  final String username;
  final String passcode;
  final bool logged;
  List<int> privateKey;
  List<int> publicKey;
  final contacts = ToMany<ContactModel>();

  UserModel copyWith({
    String? username,
    String? passcode,
    bool? logged,
  }) {
    return UserModel(
        username: username ?? this.username,
        passcode: passcode ?? this.passcode,
        logged: logged ?? this.logged,
        privateKey: privateKey,
        publicKey: publicKey,
        id: id);
  }
}
