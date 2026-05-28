import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final int usuarioId;
  final String nombreCompleto;
  final String? nombre;
  final String? apellido;
  final String identificacion;
  final int? tipoIdentificacionId;
  final int? edad;
  final DateTime? fechaNacimiento;
  final int? sexoId;
  final bool tieneHistoria;
  final DateTime? ultimaCita;
  final String? telefono;
  final String? email;
  final String? tipoSangre;
  final String? direccion;
  final int? ciudadId;

  const Patient({
    required this.usuarioId,
    required this.nombreCompleto,
    this.nombre,
    this.apellido,
    required this.identificacion,
    this.tipoIdentificacionId,
    this.edad,
    this.fechaNacimiento,
    this.sexoId,
    required this.tieneHistoria,
    this.ultimaCita,
    this.telefono,
    this.email,
    this.tipoSangre,
    this.direccion,
    this.ciudadId,
  });

  @override
  List<Object?> get props => [
        usuarioId,
        nombreCompleto,
        nombre,
        apellido,
        identificacion,
        tipoIdentificacionId,
        edad,
        fechaNacimiento,
        sexoId,
        tieneHistoria,
        ultimaCita,
        telefono,
        email,
        tipoSangre,
        direccion,
        ciudadId,
      ];
}
