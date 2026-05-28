import 'package:equatable/equatable.dart';

class BasicData extends Equatable {
  final int? tipoSangreId;
  final String? tipoSangreNombre;
  final String? pesoGeneralKg;
  final String? estaturaGeneral;

  const BasicData({
    this.tipoSangreId,
    this.tipoSangreNombre,
    this.pesoGeneralKg,
    this.estaturaGeneral,
  });

  @override
  List<Object?> get props => [tipoSangreId, tipoSangreNombre, pesoGeneralKg, estaturaGeneral];
}

class FullMedicalHistory extends Equatable {
  final int historiaMedicaId;
  final String? patientName;
  final String? patientIdCard;
  final BasicData datosBasicos;
  final Map<String, List<dynamic>> detalles;

  const FullMedicalHistory({
    required this.historiaMedicaId,
    this.patientName,
    this.patientIdCard,
    required this.datosBasicos,
    required this.detalles,
  });

  @override
  List<Object?> get props => [historiaMedicaId, patientName, patientIdCard, datosBasicos, detalles];
}
