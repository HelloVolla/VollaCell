part of 'login_bloc.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {
  LoginInitial({required this.btnEnabled});
  final bool btnEnabled;
}

final class LoginFailure extends LoginState {}

final class LoginSuccess extends LoginState {}
