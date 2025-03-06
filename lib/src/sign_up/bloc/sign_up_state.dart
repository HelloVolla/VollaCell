part of 'sign_up_bloc.dart';

@immutable
class SignUpState {
  const SignUpState({
    required this.signUpBtnEnabled,
  });

  final bool signUpBtnEnabled;

  SignUpState copyWith({
    bool? signUpBtnEnabled,
  }) {
    return SignUpState(
      signUpBtnEnabled: signUpBtnEnabled ?? this.signUpBtnEnabled,
    );
  }
}

class SignUpUsernameExistError extends SignUpState {
  const SignUpUsernameExistError({super.signUpBtnEnabled = true});
}

class SignUpUserCreated extends SignUpState {
  const SignUpUserCreated({
    super.signUpBtnEnabled = false,
    required this.user,
  });

  final UserModel user;
}
