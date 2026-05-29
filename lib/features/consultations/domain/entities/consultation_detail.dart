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
  final String? sintomasPrincipales;
  final String? medicamentos;
  final String? indicaciones;

  const ClinicalSection({
    this.descripcion,
    this.codigoCIE10,
    this.sintomasPrincipales,
    this.medicamentos,
    this.indicaciones,
  });

  @override
  List<Object?> get props => [descripcion, codigoCIE10, sintomasPrincipales, medicamentos, indicaciones];
}

class PhysicalExam extends Equatable {
  final String? cabezaCuello;
  final String? torax;
  final String? abdomen;
  final String? extremidades;
  final String? neurologico;
  final String? piel;
  final String? genitourinario;
  final String? observaciones;

  const PhysicalExam({
    this.cabezaCuello,
    this.torax,
    this.abdomen,
    this.extremidades,
    this.neurologico,
    this.piel,
    this.genitourinario,
    this.observaciones,
  });

  @override
  List<Object?> get props => [
        cabezaCuello,
        torax,
        abdomen,
        extremidades,
        neurologico,
        piel,
        genitourinario,
        observaciones,
      ];
}

class IndicationItem extends Equatable {
  final String? medicamento;
  final String? dosis;
  final String? frecuencia;
  final String? viaAdministracion;
  final int? duracionDias;
  final String? indicaciones;
  final String? fechaInicio;

  const IndicationItem({
    this.medicamento,
    this.dosis,
    this.frecuencia,
    this.viaAdministracion,
    this.duracionDias,
    this.indicaciones,
    this.fechaInicio,
  });

  @override
  List<Object?> get props => [
        medicamento,
        dosis,
        frecuencia,
        viaAdministracion,
        duracionDias,
        indicaciones,
        fechaInicio,
      ];
}

class ExamRequestItem extends Equatable {
  final String? nombreExamen;
  final String? tipoExamen;
  final String? indicaciones;

  const ExamRequestItem({
    this.nombreExamen,
    this.tipoExamen,
    this.indicaciones,
  });

  @override
  List<Object?> get props => [nombreExamen, tipoExamen, indicaciones];
}

class Prescription extends Equatable {
  final String? descripcion;
  final String? indicaciones;
  final String? fechaEmision;
  final String? fechaVencimiento;

  const Prescription({
    this.descripcion,
    this.indicaciones,
    this.fechaEmision,
    this.fechaVencimiento,
  });

  @override
  List<Object?> get props => [descripcion, indicaciones, fechaEmision, fechaVencimiento];
}

class MedicalReport extends Equatable {
  final String? titulo;
  final String? resumen;
  final String? conclusiones;
  final String? recomendaciones;
  final String? fechaInforme;
  final String? adjuntoUrl;

  const MedicalReport({
    this.titulo,
    this.resumen,
    this.conclusiones,
    this.recomendaciones,
    this.fechaInforme,
    this.adjuntoUrl,
  });

  @override
  List<Object?> get props => [
        titulo,
        resumen,
        conclusiones,
        recomendaciones,
        fechaInforme,
        adjuntoUrl,
      ];
}

class ConsultationDetail extends Equatable {
  final int citaId;
  final String? fechaCita;
  final String? motivoConsulta;
  final String? estadoCita;
  final String? pacienteNombre;
  final String? pacienteCedula;
  final int? pacienteEdad;
  final String? pacienteSexo;
  
  final VitalSigns signosVitales;
  final ClinicalSection enfermedadActual;
  final PhysicalExam examenFisico;
  final ClinicalSection diagnostico;
  final List<IndicationItem> indicaciones;
  final List<ExamRequestItem> examenesSolicitados;
  final Prescription receta;
  final MedicalReport informe;

  const ConsultationDetail({
    required this.citaId,
    this.fechaCita,
    this.motivoConsulta,
    this.estadoCita,
    this.pacienteNombre,
    this.pacienteCedula,
    this.pacienteEdad,
    this.pacienteSexo,
    required this.signosVitales,
    required this.enfermedadActual,
    required this.examenFisico,
    required this.diagnostico,
    required this.indicaciones,
    required this.examenesSolicitados,
    required this.receta,
    required this.informe,
  });

  @override
  List<Object?> get props => [
        citaId,
        fechaCita,
        motivoConsulta,
        estadoCita,
        pacienteNombre,
        pacienteCedula,
        pacienteEdad,
        pacienteSexo,
        signosVitales,
        enfermedadActual,
        examenFisico,
        diagnostico,
        indicaciones,
        examenesSolicitados,
        receta,
        informe,
      ];
}
