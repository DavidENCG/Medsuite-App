import '../../domain/entities/case_detail.dart';
import '../../../../core/utils/json_utils.dart';

class CaseAppointmentModel extends CaseAppointment {
  const CaseAppointmentModel({
    required super.id,
    super.fechaCita,
    required super.estado,
  });

  factory CaseAppointmentModel.fromJson(Map<String, dynamic> json) {
    return CaseAppointmentModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id']),
      fechaCita: json['fechaCita'] != null ? DateTime.tryParse(json['fechaCita'].toString()) : null,
      estado: JsonUtils.forceString(json['estado'] ?? json['Estado']),
    );
  }
}

class CaseDetailModel extends CaseDetail {
  const CaseDetailModel({
    required super.id,
    required super.tituloCaso,
    required super.citas,
  });

  factory CaseDetailModel.fromJson(Map<String, dynamic> json) {
    final citasRaw = json['citas'] ?? json['Citas'] ?? [];
    List<CaseAppointmentModel> citasList = [];
    if (citasRaw is List) {
      citasList = citasRaw.map((e) => CaseAppointmentModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    
    return CaseDetailModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id']),
      tituloCaso: JsonUtils.forceString(json['tituloCaso'] ?? json['TituloCaso']),
      citas: citasList,
    );
  }
}
