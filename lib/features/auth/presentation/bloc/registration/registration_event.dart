part of 'registration_bloc.dart';

abstract class RegistrationEvent {}

class LoadIdentificationTypes extends RegistrationEvent {}

class UpdatePersonalData extends RegistrationEvent {
  final String nombre;
  final String apellido;
  final int tipoIdentificacionId;
  final String identificacion;
  final String email;
  final String telefono;
  final String password;

  UpdatePersonalData({
    required this.nombre,
    required this.apellido,
    required this.tipoIdentificacionId,
    required this.identificacion,
    required this.email,
    required this.telefono,
    required this.password,
  });
}

class ValidateAndNext extends RegistrationEvent {}

class LoadRoles extends RegistrationEvent {}

class SelectRole extends RegistrationEvent {
  final int roleId;
  SelectRole(this.roleId);
}

class FinalizeRegistration extends RegistrationEvent {}

class PreviousStep extends RegistrationEvent {}
