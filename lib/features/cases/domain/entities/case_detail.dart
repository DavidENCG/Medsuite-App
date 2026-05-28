import 'package:equatable/equatable.dart';

class CaseAppointment extends Equatable {
  final int id;
  final DateTime? fechaCita;
  final String estado;

  const CaseAppointment({
    required this.id,
    this.fechaCita,
    required this.estado,
  });

  @override
  List<Object?> get props => [id, fechaCita, estado];
}

class CaseDetail extends Equatable {
  final int id;
  final String tituloCaso;
  final List<CaseAppointment> citas;

  const CaseDetail({
    required this.id,
    required this.tituloCaso,
    required this.citas,
  });

  @override
  List<Object?> get props => [id, tituloCaso, citas];
}
