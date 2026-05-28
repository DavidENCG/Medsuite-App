import '../../domain/entities/medical_case.dart';
import '../../../../core/utils/json_utils.dart';

class MedicalCaseModel extends MedicalCase {
  const MedicalCaseModel({
    required super.id,
    required super.titulo,
    super.descripcion,
    required super.pacienteId,
    required super.fechaApertura,
    super.activo = true,
  });

  factory MedicalCaseModel.fromJson(Map<String, dynamic> json) {
    DateTime? safeParseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return MedicalCaseModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id']),
      titulo: JsonUtils.forceString(json['titulo'] ?? json['Titulo'] ?? json['tituloCaso'] ?? json['TituloCaso']),
      descripcion: JsonUtils.forceString(json['descripcion'] ?? json['Descripcion']),
      pacienteId: JsonUtils.forceInt(json['pacienteId'] ?? json['PacienteId']),
      fechaApertura: safeParseDate(json['fechaApertura'] ?? json['FechaApertura'] ?? json['fechaCreacion'] ?? json['FechaCreacion']) ?? DateTime.now(),
      activo: json['activo'] ?? json['Activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'pacienteId': pacienteId,
      'fechaApertura': fechaApertura.toIso8601String(),
      'activo': activo,
    };
  }
}
