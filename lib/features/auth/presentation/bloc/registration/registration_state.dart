part of 'registration_bloc.dart';

enum RegistrationStatus { initial, loading, success, failure, validating }

class RegistrationState {
  final int currentStep;
  final RegistrationStatus status;
  final String? errorMessage;
  
  // Data Step 1
  final List<IdentificationType> identificationTypes;
  final String nombre;
  final String apellido;
  final int? tipoIdentificacionId;
  final String identificacion;
  final String email;
  final String telefono;
  final String password;

  // Data Step 3
  final List<RegistrationRole> roles;
  final int? rolId;

  RegistrationState({
    this.currentStep = 0,
    this.status = RegistrationStatus.initial,
    this.errorMessage,
    this.identificationTypes = const [],
    this.nombre = '',
    this.apellido = '',
    this.tipoIdentificacionId,
    this.identificacion = '',
    this.email = '',
    this.telefono = '',
    this.password = '',
    this.roles = const [],
    this.rolId,
  });

  RegistrationState copyWith({
    int? currentStep,
    RegistrationStatus? status,
    String? errorMessage,
    List<IdentificationType>? identificationTypes,
    String? nombre,
    String? apellido,
    int? tipoIdentificacionId,
    String? identificacion,
    String? email,
    String? telefono,
    String? password,
    List<RegistrationRole>? roles,
    int? rolId,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage, // Reset error if not provided
      identificationTypes: identificationTypes ?? this.identificationTypes,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      tipoIdentificacionId: tipoIdentificacionId ?? this.tipoIdentificacionId,
      identificacion: identificacion ?? this.identificacion,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      password: password ?? this.password,
      roles: roles ?? this.roles,
      rolId: rolId ?? this.rolId,
    );
  }
}
