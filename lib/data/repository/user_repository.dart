import 'package:kaonic/data/repository/storage.dart';

import '../../objectbox.g.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({required StorageService storageService}) {
    _users = storageService.initRepository<UserModel>();
  }

  late final Box<UserModel> _users;

  UserModel? createUser(String username, String passcode) {
    final usersWithSameUsername =
        _users.query(UserModel_.username.equals(username)).build().count();
    if (usersWithSameUsername > 0) return null;

    final user = UserModel(username: username, passcode: passcode, id: 0);
    final id = _users.put(user);
    user.id = id;

    return user;
  }

  void deleteUser(UserModel user) {
    _users.remove(user.id);
  }

  UserModel? getUser(String username, String passcode) {
    final queryBuilder = _users.query(UserModel_.username
        .equals(username)
        .and(UserModel_.passcode.equals(passcode)));

    return queryBuilder.build().findFirst();
  }

  Stream<Query<UserModel>>? watchUser(int id) {
    final queryBuilder = _users.query(UserModel_.id.equals(id));

    return queryBuilder.watch();
  }

  UserModel? getSignedInUser() {
    final queryBuilder = _users.query(UserModel_.logged.equals(true));

    return queryBuilder.build().findFirst();
  }

  void updateUser(UserModel user) => _users.put(user);
}
