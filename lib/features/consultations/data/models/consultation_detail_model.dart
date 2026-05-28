import '../../domain/entities/consultation_detail.dart';
import '../../../../core/utils/json_utils.dart';

class VitalSignsModel extends VitalSigns {
  const VitalSignsModel({
    super.tensionArterial,
    super.temperatura,
    super.frecuenciaCardiaca,
    super.frecuenciaRespiratoria,
    super.saturacionOxigeno,
    super.pesoKg,
    super.estaturaCm,
  });

  factory VitalSignsModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return VitalSignsModel(
      tensionArterial: JsonUtils.forceString(json['tensionArterial'] ?? json['TensionArterial']),
      temperatura: toDouble(json['temperatura'] ?? json['Temperatura']),
      frecuenciaCardiaca: JsonUtils.forceIntNullable(json['frecuenciaCardiaca'] ?? json['FrecuenciaCardiaca']),
      frecuenciaRespiratoria: JsonUtils.forceIntNullable(json['frecuenciaRespiratoria'] ?? json['FrecuenciaRespiratoria']),
      saturacionOxigeno: toDouble(json['saturacionOxigeno'] ?? json['SaturacionOxigeno']),
      pesoKg: toDouble(json['pesoKg'] ?? json['PesoKg']),
      estaturaCm: toDouble(json['estaturaCm'] ?? json['EstaturaCm']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tensionArterial': tensionArterial,
      'temperatura': temperatura,
      'frecuenciaCardiaca': frecuenciaCardiaca,
      'frecuenciaRespiratoria': frecuenciaRespiratoria,
      'saturacionOxigeno': saturacionOxigeno,
      'pesoKg': pesoKg,
      'estaturaCm': estaturaCm,
    };
  }
}

class ClinicalSectionModel extends ClinicalSection {
  const ClinicalSectionModel({
    super.descripcion,
    super.codigoCIE10,
    super.medicamentos,
    super.indicaciones,
  });

  factory ClinicalSectionModel.fromJson(Map<String, dynamic> json) {
    return ClinicalSectionModel(
      descripcion: JsonUtils.forceString(json['descripcion'] ?? json['Descripcion']),
      codigoCIE10: JsonUtils.forceString(json['codigoCIE10'] ?? json['CodigoCIE10']),
      medicamentos: JsonUtils.forceString(json['medicamentos'] ?? json['Medicamentos']),
      indicaciones: JsonUtils.forceString(json['indicaciones'] ?? json['Indicaciones']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descripcion': descripcion,
      'codigoCIE10': codigoCIE10,
      'medicamentos': medicamentos,
      'indicaciones': indicaciones,
    };
  }
}

class ConsultationDetailModel extends ConsultationDetail {
  const ConsultationDetailModel({
    required super.citaId,
    super.fechaCita,
    super.motivoConsulta,
    super.pacienteNombre,
    super.pacienteCedula,
    super.pacienteEdad,
    required super.signosVitales,
    required super.enfermedadActual,
    required super.examenFisico,
    required super.diagnostico,
    required super.receta,
  });

  factory ConsultationDetailModel.fromJson(Map<String, dynamic> json) {
    final cita = json['cita'] ?? json['Cita'] ?? {};
    final paciente = json['paciente'] ?? json['Paciente'] ?? {};
    final seguimiento = json['seguimiento'] ?? json['Seguimiento'] ?? {};

    return ConsultationDetailModel(
      citaId: JsonUtils.forceInt(cita['id'] ?? cita['Id'] ?? json['id'] ?? json['Id']),
      fechaCita: JsonUtils.forceString(cita['fechaCita'] ?? cita['FechaCita'] ?? json['fechaCita']),
      motivoConsulta: JsonUtils.forceString(cita['motivoConsulta'] ?? cita['MotivoConsulta'] ?? json['motivoConsulta']),
      pacienteNombre: JsonUtils.forceString(paciente['nombreCompleto'] ?? paciente['NombreCompleto'] ?? paciente['nombre'] ?? paciente['Nombre'], defaultValue: 'Paciente No Identificado'),
      pacienteCedula: JsonUtils.forceString(paciente['identificacion'] ?? paciente['Identificacion'] ?? paciente['cedula'], defaultValue: 'S/I'),
      pacienteEdad: JsonUtils.forceIntNullable(paciente['edad'] ?? paciente['Edad']),
      signosVitales: VitalSignsModel.fromJson(seguimiento['signosVitales'] ?? seguimiento['SignosVitales'] ?? {}),
      enfermedadActual: ClinicalSectionModel.fromJson(seguimiento['enfermedadActual'] ?? seguimiento['EnfermedadActual'] ?? {}),
      examenFisico: ClinicalSectionModel.fromJson(seguimiento['examenFisico'] ?? seguimiento['ExamenFisico'] ?? {}),
      diagnostico: ClinicalSectionModel.fromJson(seguimiento['diagnostico'] ?? seguimiento['Diagnostico'] ?? {}),
      receta: ClinicalSectionModel.fromJson(seguimiento['receta'] ?? seguimiento['Receta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'citaMedicaId': citaId,
      'signosVitales': (signosVitales as VitalSignsModel).toJson(),
      'enfermedadActual': (enfermedadActual as ClinicalSectionModel).toJson(),
      'examenFisico': (examenFisico as ClinicalSectionModel).toJson(),
      'diagnostico': (diagnostico as ClinicalSectionModel).toJson(),
      'receta': (receta as ClinicalSectionModel).toJson(),
    };
  }
}
