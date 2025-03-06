part of 'passcode_bloc.dart';

@immutable
sealed class PasscodeState {
  final String code;
  const PasscodeState({required this.code});

  PasscodeState copyWith({String? code});
}

final class PasscodeCreate extends PasscodeState {
  const PasscodeCreate({required super.code});

  @override
  PasscodeCreate copyWith({String? code}) =>
      PasscodeCreate(code: code ?? this.code);
}

final class PasscodeRepeat extends PasscodeState {
  const PasscodeRepeat({required super.code});
  @override
  PasscodeRepeat copyWith({String? code}) =>
      PasscodeRepeat(code: code ?? this.code);
}

final class PasscodeRepeatNotMatch extends PasscodeState {
  const PasscodeRepeatNotMatch({required super.code});
  @override
  PasscodeRepeatNotMatch copyWith({String? code}) =>
      PasscodeRepeatNotMatch(code: code ?? this.code);
}

final class PasscodeCreatedSuccess extends PasscodeState {
  const PasscodeCreatedSuccess({required super.code});
  @override
  PasscodeCreatedSuccess copyWith({String? code}) =>
      PasscodeCreatedSuccess(code: code ?? this.code);
}

final class PasscodeEnter extends PasscodeState {
  const PasscodeEnter({required super.code});
  @override
  PasscodeEnter copyWith({String? code}) =>
      PasscodeEnter(code: code ?? this.code);
}

final class PasscodeEnterFailure extends PasscodeState {
  const PasscodeEnterFailure({required super.code});
  @override
  PasscodeEnterFailure copyWith({String? code}) =>
      PasscodeEnterFailure(code: code ?? this.code);
}

final class PasscodeEnterSuccess extends PasscodeState {
  const PasscodeEnterSuccess({required super.code});
  @override
  PasscodeEnterSuccess copyWith({String? code}) =>
      PasscodeEnterSuccess(code: code ?? this.code);
}
