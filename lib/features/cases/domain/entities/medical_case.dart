import 'package:equatable/equatable.dart';

class MedicalCase extends Equatable {
  final int id;
  final String titulo;
  final String? descripcion;
  final int pacienteId;
  final DateTime fechaApertura;
  final bool activo;

  const MedicalCase({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.pacienteId,
    required this.fechaApertura,
    this.activo = true,
  });

  @override
  List<Object?> get props => [id, titulo, descripcion, pacienteId, fechaApertura, activo];
}
