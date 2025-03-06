part of 'passcode_bloc.dart';

@immutable
sealed class PasscodeEvent {}

class PasscodeChanged extends PasscodeEvent {
  PasscodeChanged({
    required this.code,
  });
  final String code;
}
