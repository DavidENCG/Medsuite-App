part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthSubscriptionBlocked extends AuthState {}

class AuthNeedsRole extends AuthState {
  final List<Map<String, dynamic>> roles;
  const AuthNeedsRole(this.roles);

  @override
  List<Object?> get props => [roles];
}

class AuthNeedsClinic extends AuthState {
  final List<Clinic> clinics;
  const AuthNeedsClinic(this.clinics);

  @override
  List<Object?> get props => [clinics];
}

class Authenticated extends AuthState {
  final String token;
  final String? fullName;
  final String? activeClinicName;
  final int? activeClinicId;
  final List<Clinic> clinics;
  
  const Authenticated(this.token, {
    this.fullName, 
    this.activeClinicName, 
    this.activeClinicId,
    this.clinics = const [],
  });

  @override
  List<Object?> get props => [token, fullName, activeClinicName, activeClinicId, clinics];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
