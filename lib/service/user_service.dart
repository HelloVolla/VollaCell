import 'package:flutter/services.dart';
import 'package:kaonic/data/models/user_model.dart';
import 'package:kaonic/data/repository/user_repository.dart';
import 'package:kaonic/main.dart';
import 'package:objectbox/objectbox.dart';

class UserService {
  UserService({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;
  static const platform = MethodChannel('network.beechat.app.kaonic/kaonic');
  UserModel? _user;
  UserModel? get user => _user;

  Future<UserModel?> signUpUser(String username, String passcode) async {
    _user = _userRepository.createUser(username, passcode);
    _user?.key = mocked
        ? '12345674567566674555123456745675666745551234567456756667455512345674567566674555123456745675666745551234567456756667455512345674567566674555123456745675666745551234567456756667455512345674567566674555'
        : await platform.invokeMethod("generateKey");
    _userRepository.updateUser(_user!);

    return user;
  }

  UserModel? loginUser(String username, String passcode) {
    _user = _userRepository.getUser(username, passcode);
    if (_user != null) {
      _userRepository.updateUser(_user!.copyWith(logged: true));
    }

//mesh

    return _user;
  }

  UserModel? checkUserSignedIn() {
    _user = _userRepository.getSignedInUser();

    return _user;
  }

  void logout() {
    if (_user == null) return;
    _userRepository.updateUser(_user!.copyWith(logged: false));
  }

  void updateCurrentUser() {
    if (_user == null) return;

    _userRepository.updateUser(_user!);
  }

  Stream<Query<UserModel>>? watchCurrentUser() {
    if (_user == null) return null;

    return _userRepository.watchUser(_user!.id);
  }
}
