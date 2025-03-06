// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpEvent {}

class UsernameChanged extends SignUpEvent {
  UsernameChanged({
    required this.username,
  });
  final String username;
}

class PasscodeCreated extends SignUpEvent {
  PasscodeCreated({
    required this.passcode,
  });
  final String passcode;
}


