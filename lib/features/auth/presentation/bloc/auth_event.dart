part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RoleSelected extends AuthEvent {
  final int roleId;

  const RoleSelected({required this.roleId});

  @override
  List<Object?> get props => [roleId];
}

class ClinicSelected extends AuthEvent {
  final int? clinicId;

  const ClinicSelected({required this.clinicId});

  @override
  List<Object?> get props => [clinicId];
}

class LogoutRequested extends AuthEvent {}
