import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final int id;
  final int? casoId;
  final int pacienteId;
  final String pacienteNombre;
  final String pacienteIdentificacion;
  final int consultorioId;
  final String consultorioNombre;
  final DateTime fechaCita;
  final String horaCita;
  final String motivoConsulta;
  final int estadoId;
  final String estado;
  final bool atendido;
  final String? notas;

  const Appointment({
    required this.id,
    this.casoId,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.pacienteIdentificacion,
    required this.consultorioId,
    required this.consultorioNombre,
    required this.fechaCita,
    required this.horaCita,
    required this.motivoConsulta,
    required this.estadoId,
    required this.estado,
    required this.atendido,
    this.notas,
  });

  @override
  List<Object?> get props => [
        id,
        casoId,
        pacienteId,
        pacienteNombre,
        pacienteIdentificacion,
        consultorioId,
        consultorioNombre,
        fechaCita,
        horaCita,
        motivoConsulta,
        estadoId,
        estado,
        atendido,
        notas,
      ];
}
