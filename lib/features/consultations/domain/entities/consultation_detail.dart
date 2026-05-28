import 'package:equatable/equatable.dart';

class VitalSigns extends Equatable {
  final String? tensionArterial;
  final double? temperatura;
  final int? frecuenciaCardiaca;
  final int? frecuenciaRespiratoria;
  final double? saturacionOxigeno;
  final double? pesoKg;
  final double? estaturaCm;

  const VitalSigns({
    this.tensionArterial,
    this.temperatura,
    this.frecuenciaCardiaca,
    this.frecuenciaRespiratoria,
    this.saturacionOxigeno,
    this.pesoKg,
    this.estaturaCm,
  });

  @override
  List<Object?> get props => [
        tensionArterial,
        temperatura,
        frecuenciaCardiaca,
        frecuenciaRespiratoria,
        saturacionOxigeno,
        pesoKg,
        estaturaCm,
      ];
}

class ClinicalSection extends Equatable {
  final String? descripcion;
  final String? codigoCIE10;
  final String? medicamentos;
  final String? indicaciones;

  const ClinicalSection({
    this.descripcion,
    this.codigoCIE10,
    this.medicamentos,
    this.indicaciones,
  });

  @override
  List<Object?> get props => [descripcion, codigoCIE10, medicamentos, indicaciones];
}

class ConsultationDetail extends Equatable {
  final int citaId;
  final String? fechaCita;
  final String? motivoConsulta;
  final String? pacienteNombre;
  final String? pacienteCedula;
  final int? pacienteEdad;
  
  final VitalSigns signosVitales;
  final ClinicalSection enfermedadActual;
  final ClinicalSection examenFisico;
  final ClinicalSection diagnostico;
  final ClinicalSection receta;

  const ConsultationDetail({
    required this.citaId,
    this.fechaCita,
    this.motivoConsulta,
    this.pacienteNombre,
    this.pacienteCedula,
    this.pacienteEdad,
    required this.signosVitales,
    required this.enfermedadActual,
    required this.examenFisico,
    required this.diagnostico,
    required this.receta,
  });

  @override
  List<Object?> get props => [
        citaId,
        fechaCita,
        motivoConsulta,
        pacienteNombre,
        pacienteCedula,
        pacienteEdad,
        signosVitales,
        enfermedadActual,
        examenFisico,
        diagnostico,
        receta,
      ];
}
