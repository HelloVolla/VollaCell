import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaonic/service/user_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required UserService userService})
      : _userService = userService,
        super(LoginInitial(btnEnabled: false)) {
    on<LoginInputsChanged>(_handleLoginInputsChanged);
    on<LoginUser>(_handleUserLogin);
  }

  final UserService _userService;

  FutureOr<void> _handleLoginInputsChanged(
      LoginInputsChanged event, Emitter<LoginState> emit) {
    emit(LoginInitial(btnEnabled: event.username.length > 2));
  }

  FutureOr<void> _handleUserLogin(LoginUser event, Emitter<LoginState> emit) {
    final response = _userService.loginUser(event.username, event.passcode);

    if (response == null) {
      emit(LoginFailure());
    } else {
      emit(LoginSuccess());
    }
  }
}
