part of 'login_bloc.dart';


sealed class LoginEvent {}

class LoginInputsChanged extends LoginEvent {
  LoginInputsChanged({
    required this.username,
  });
  final String username;
}

class LoginUser extends LoginEvent {
  LoginUser({
    required this.username,
    required this.passcode,
  });
  final String username;
  final String passcode;
}
