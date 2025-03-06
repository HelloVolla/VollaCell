import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kaonic/data/models/user_model.dart';
import 'package:kaonic/service/user_service.dart';
import 'package:meta/meta.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc({required UserService userService})
      : _userService = userService,
        super(const SignUpState(signUpBtnEnabled: false)) {
    on<UsernameChanged>(_handleUsernameChanged);
    on<PasscodeCreated>(_handlePasscodeCreated);
  }

  final UserService _userService;
  String _username = '';

  FutureOr<void> _handleUsernameChanged(
      UsernameChanged event, Emitter<SignUpState> emit) {
    _username = event.username;

    emit(state.copyWith(signUpBtnEnabled: event.username.length > 2));
  }

  Future<void> _handlePasscodeCreated(
      PasscodeCreated event, Emitter<SignUpState> emit) async{
    if (_username.isEmpty || event.passcode.isEmpty) return;

    final newUser = await _userService.signUpUser(_username, event.passcode);

    if (newUser == null) {
      emit(const SignUpUsernameExistError());

      return;
    }

    emit(SignUpUserCreated(user: newUser));
  }
}
