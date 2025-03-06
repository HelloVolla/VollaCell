import 'package:kaonic/data/repository/storage.dart';

import '../../objectbox.g.dart';
import '../models/user_model.dart';

class PasscodeRepository {
  PasscodeRepository({required StorageService storageService}) {
    _users = storageService.initRepository<UserModel>();
  }

  late final Box<UserModel> _users;

  bool checkPasscodeForUser(String username, String passcode) {
    final usersFound = _users
        .query(UserModel_.username
            .equals(username)
            .and(UserModel_.passcode.equals(passcode)))
        .build()
        .count();

    return usersFound > 0;
  }
}
