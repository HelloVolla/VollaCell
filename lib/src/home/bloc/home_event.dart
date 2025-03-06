part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class _InitEvent extends HomeEvent {}


final class _UpdatedUser extends HomeEvent {
  _UpdatedUser({required this.user});

  final UserModel user;
}
