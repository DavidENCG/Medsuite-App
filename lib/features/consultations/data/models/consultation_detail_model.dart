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
}

class ClinicalSectionModel extends ClinicalSection {
  const ClinicalSectionModel({
    super.descripcion,
    super.codigoCIE10,
    super.sintomasPrincipales,
    super.medicamentos,
    super.indicaciones,
  });

  factory ClinicalSectionModel.fromJson(Map<String, dynamic> json) {
    return ClinicalSectionModel(
      descripcion: JsonUtils.forceString(json['descripcion'] ?? json['Descripcion']),
      codigoCIE10: JsonUtils.forceString(json['codigoCIE10'] ?? json['CodigoCIE10']),
      sintomasPrincipales: JsonUtils.forceString(json['sintomasPrincipales'] ?? json['SintomasPrincipales']),
      medicamentos: JsonUtils.forceString(json['medicamentos'] ?? json['Medicamentos']),
      indicaciones: JsonUtils.forceString(json['indicaciones'] ?? json['Indicaciones']),
    );
  }
}

class PhysicalExamModel extends PhysicalExam {
  const PhysicalExamModel({
    super.cabezaCuello,
    super.torax,
    super.abdomen,
    super.extremidades,
    super.neurologico,
    super.piel,
    super.genitourinario,
    super.observaciones,
  });

  factory PhysicalExamModel.fromJson(Map<String, dynamic> json) {
    return PhysicalExamModel(
      cabezaCuello: JsonUtils.forceString(json['cabezaCuello'] ?? json['CabezaCuello']),
      torax: JsonUtils.forceString(json['torax'] ?? json['Torax']),
      abdomen: JsonUtils.forceString(json['abdomen'] ?? json['Abdomen']),
      extremidades: JsonUtils.forceString(json['extremidades'] ?? json['Extremidades']),
      neurologico: JsonUtils.forceString(json['neurologico'] ?? json['Neurologico']),
      piel: JsonUtils.forceString(json['piel'] ?? json['Piel']),
      genitourinario: JsonUtils.forceString(json['genitourinario'] ?? json['Genitourinario']),
      observaciones: JsonUtils.forceString(json['observaciones'] ?? json['Observaciones']),
    );
  }
}

class IndicationItemModel extends IndicationItem {
  const IndicationItemModel({
    super.medicamento,
    super.dosis,
    super.frecuencia,
    super.viaAdministracion,
    super.duracionDias,
    super.indicaciones,
    super.fechaInicio,
  });

  factory IndicationItemModel.fromJson(Map<String, dynamic> json) {
    return IndicationItemModel(
      medicamento: JsonUtils.forceString(json['medicamento'] ?? json['Medicamento']),
      dosis: JsonUtils.forceString(json['dosis'] ?? json['Dosis']),
      frecuencia: JsonUtils.forceString(json['frecuencia'] ?? json['Frecuencia']),
      viaAdministracion: JsonUtils.forceString(json['viaAdministracion'] ?? json['ViaAdministracion']),
      duracionDias: JsonUtils.forceIntNullable(json['duracionDias'] ?? json['DuracionDias']),
      indicaciones: JsonUtils.forceString(json['indicaciones'] ?? json['Indicaciones']),
      fechaInicio: JsonUtils.forceString(json['fechaInicio'] ?? json['FechaInicio']),
    );
  }
}

class ExamRequestItemModel extends ExamRequestItem {
  const ExamRequestItemModel({
    super.nombreExamen,
    super.tipoExamen,
    super.indicaciones,
  });

  factory ExamRequestItemModel.fromJson(Map<String, dynamic> json) {
    return ExamRequestItemModel(
      nombreExamen: JsonUtils.forceString(json['nombreExamen'] ?? json['NombreExamen']),
      tipoExamen: JsonUtils.forceString(json['tipoExamen'] ?? json['TipoExamen']),
      indicaciones: JsonUtils.forceString(json['indicaciones'] ?? json['Indicaciones']),
    );
  }
}

class PrescriptionModel extends Prescription {
  const PrescriptionModel({
    super.descripcion,
    super.indicaciones,
    super.fechaEmision,
    super.fechaVencimiento,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      descripcion: JsonUtils.forceString(json['descripcion'] ?? json['Descripcion']),
      indicaciones: JsonUtils.forceString(json['indicaciones'] ?? json['Indicaciones']),
      fechaEmision: JsonUtils.forceString(json['fechaEmision'] ?? json['FechaEmision']),
      fechaVencimiento: JsonUtils.forceString(json['fechaVencimiento'] ?? json['FechaVencimiento']),
    );
  }
}

class MedicalReportModel extends MedicalReport {
  const MedicalReportModel({
    super.titulo,
    super.resumen,
    super.conclusiones,
    super.recomendaciones,
    super.fechaInforme,
    super.adjuntoUrl,
  });

  factory MedicalReportModel.fromJson(Map<String, dynamic> json) {
    return MedicalReportModel(
      titulo: JsonUtils.forceString(json['titulo'] ?? json['Titulo']),
      resumen: JsonUtils.forceString(json['resumen'] ?? json['Resumen']),
      conclusiones: JsonUtils.forceString(json['conclusiones'] ?? json['Conclusiones']),
      recomendaciones: JsonUtils.forceString(json['recomendaciones'] ?? json['Recomendaciones']),
      fechaInforme: JsonUtils.forceString(json['fechaInforme'] ?? json['FechaInforme']),
      adjuntoUrl: JsonUtils.forceString(json['adjuntoUrl'] ?? json['AdjuntoUrl']),
    );
  }
}

class ConsultationDetailModel extends ConsultationDetail {
  const ConsultationDetailModel({
    required super.citaId,
    super.fechaCita,
    super.motivoConsulta,
    super.estadoCita,
    super.pacienteNombre,
    super.pacienteCedula,
    super.pacienteEdad,
    super.pacienteSexo,
    required super.signosVitales,
    required super.enfermedadActual,
    required super.examenFisico,
    required super.diagnostico,
    required super.indicaciones,
    required super.examenesSolicitados,
    required super.receta,
    required super.informe,
  });

  factory ConsultationDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final cita = data['cita'] ?? data['Cita'] ?? {};
    final paciente = data['paciente'] ?? data['Paciente'] ?? {};
    final seguimiento = data['seguimiento'] ?? data['Seguimiento'] ?? {};

    return ConsultationDetailModel(
      citaId: JsonUtils.forceInt(cita['id'] ?? cita['Id'] ?? data['id'] ?? data['Id']),
      fechaCita: JsonUtils.forceString(cita['fechaCita'] ?? cita['FechaCita'] ?? data['fechaCita']),
      motivoConsulta: JsonUtils.forceString(cita['motivoConsulta'] ?? cita['MotivoConsulta'] ?? data['motivoConsulta']),
      estadoCita: JsonUtils.forceString(cita['estado'] ?? cita['Estado']),
      pacienteNombre: JsonUtils.forceString(paciente['nombreCompleto'] ?? paciente['NombreCompleto'] ?? paciente['nombre'] ?? paciente['Nombre'], defaultValue: 'Paciente No Identificado'),
      pacienteCedula: JsonUtils.forceString(paciente['identificacion'] ?? paciente['Identificacion'] ?? paciente['cedula'], defaultValue: 'S/I'),
      pacienteEdad: JsonUtils.forceIntNullable(paciente['edad'] ?? paciente['Edad']),
      pacienteSexo: JsonUtils.forceString(paciente['sexo'] ?? paciente['Sexo']),
      signosVitales: VitalSignsModel.fromJson(seguimiento['signosVitales'] ?? seguimiento['SignosVitales'] ?? {}),
      enfermedadActual: ClinicalSectionModel.fromJson(seguimiento['enfermedadActual'] ?? seguimiento['EnfermedadActual'] ?? {}),
      examenFisico: PhysicalExamModel.fromJson(seguimiento['examenFisico'] ?? seguimiento['ExamenFisico'] ?? {}),
      diagnostico: ClinicalSectionModel.fromJson(seguimiento['diagnostico'] ?? seguimiento['Diagnostico'] ?? {}),
      indicaciones: (seguimiento['indicaciones'] as List?)?.map((e) => IndicationItemModel.fromJson(e)).toList() ?? [],
      examenesSolicitados: (seguimiento['examenesSolicitados'] as List?)?.map((e) => ExamRequestItemModel.fromJson(e)).toList() ?? [],
      receta: PrescriptionModel.fromJson(seguimiento['receta'] ?? seguimiento['Receta'] ?? {}),
      informe: MedicalReportModel.fromJson(seguimiento['informe'] ?? seguimiento['Informe'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    String? clean(String? value) => (value == null || value.trim().isEmpty) ? null : value;
    
    String? formatDate(String? date) {
      if (date == null || date.isEmpty) return null;
      try {
        return date.split('T')[0]; // Forzar YYYY-MM-DD
      } catch (_) {
        return null;
      }
    }

    final Map<String, dynamic> map = {
      'citaMedicaId': citaId,
    };

    final sv = signosVitales;
    final svJson = {
      if (sv.tensionArterial != null) 'tensionArterial': sv.tensionArterial,
      if (sv.temperatura != null) 'temperatura': sv.temperatura,
      if (sv.frecuenciaCardiaca != null) 'frecuenciaCardiaca': sv.frecuenciaCardiaca,
      if (sv.frecuenciaRespiratoria != null) 'frecuenciaRespiratoria': sv.frecuenciaRespiratoria,
      if (sv.saturacionOxigeno != null) 'saturacionOxigeno': sv.saturacionOxigeno,
      if (sv.pesoKg != null) 'pesoKg': sv.pesoKg,
      if (sv.estaturaCm != null) 'estaturaCm': sv.estaturaCm,
    };
    if (svJson.isNotEmpty) map['signosVitales'] = svJson;

    final ea = enfermedadActual;
    final eaJson = {
      if (clean(ea.descripcion) != null) 'descripcion': clean(ea.descripcion),
      if (clean(ea.sintomasPrincipales) != null) 'sintomasPrincipales': clean(ea.sintomasPrincipales),
    };
    if (eaJson.isNotEmpty) map['enfermedadActual'] = eaJson;

    final ef = examenFisico;
    final efJson = {
      if (clean(ef.cabezaCuello) != null) 'cabezaCuello': clean(ef.cabezaCuello),
      if (clean(ef.torax) != null) 'torax': clean(ef.torax),
      if (clean(ef.abdomen) != null) 'abdomen': clean(ef.abdomen),
      if (clean(ef.extremidades) != null) 'extremidades': clean(ef.extremidades),
      if (clean(ef.neurologico) != null) 'neurologico': clean(ef.neurologico),
      if (clean(ef.piel) != null) 'piel': clean(ef.piel),
      if (clean(ef.genitourinario) != null) 'genitourinario': clean(ef.genitourinario),
      if (clean(ef.observaciones) != null) 'observaciones': clean(ef.observaciones),
    };
    if (efJson.isNotEmpty) map['examenFisico'] = efJson;

    final dg = diagnostico;
    final dgJson = {
      if (clean(dg.descripcion) != null) 'descripcion': clean(dg.descripcion),
      if (clean(dg.codigoCIE10) != null) 'codigoCIE10': clean(dg.codigoCIE10),
    };
    if (dgJson.isNotEmpty) map['diagnostico'] = dgJson;

    // Solo mapear ítems que tengan al menos el campo requerido (Nombre/Medicamento)
    final validIndicaciones = indicaciones.where((e) => clean(e.medicamento) != null).map((e) => {
      'medicamento': clean(e.medicamento),
      if (clean(e.dosis) != null) 'dosis': clean(e.dosis),
      if (clean(e.frecuencia) != null) 'frecuencia': clean(e.frecuencia),
      if (clean(e.viaAdministracion) != null) 'viaAdministracion': clean(e.viaAdministracion),
      if (e.duracionDias != null) 'duracionDias': e.duracionDias,
      if (clean(e.indicaciones) != null) 'indicaciones': clean(e.indicaciones),
      if (formatDate(e.fechaInicio) != null) 'fechaInicio': formatDate(e.fechaInicio),
    }).toList();
    if (validIndicaciones.isNotEmpty) map['indicaciones'] = validIndicaciones;

    final validExamenes = examenesSolicitados.where((e) => clean(e.nombreExamen) != null).map((e) => {
      'nombreExamen': clean(e.nombreExamen),
      if (clean(e.tipoExamen) != null) 'tipoExamen': clean(e.tipoExamen),
      if (clean(e.indicaciones) != null) 'indicaciones': clean(e.indicaciones),
    }).toList();
    if (validExamenes.isNotEmpty) map['examenesSolicitados'] = validExamenes;

    final rc = receta;
    final rcJson = {
      if (clean(rc.descripcion) != null) 'descripcion': clean(rc.descripcion),
      if (clean(rc.indicaciones) != null) 'indicaciones': clean(rc.indicaciones),
      if (formatDate(rc.fechaEmision) != null) 'fechaEmision': formatDate(rc.fechaEmision),
      if (formatDate(rc.fechaVencimiento) != null) 'fechaVencimiento': formatDate(rc.fechaVencimiento),
    };
    if (rcJson.isNotEmpty) map['receta'] = rcJson;

    final inf = informe;
    final infJson = {
      if (clean(inf.titulo) != null) 'titulo': clean(inf.titulo),
      if (clean(inf.resumen) != null) 'resumen': clean(inf.resumen),
      if (clean(inf.conclusiones) != null) 'conclusiones': clean(inf.conclusiones),
      if (clean(inf.recomendaciones) != null) 'recomendaciones': clean(inf.recomendaciones),
      if (formatDate(inf.fechaInforme) != null) 'fechaInforme': formatDate(inf.fechaInforme),
      if (clean(inf.adjuntoUrl) != null) 'adjuntoUrl': clean(inf.adjuntoUrl),
    };
    if (infJson.isNotEmpty) map['informe'] = infJson;

    return map;
  }
}
