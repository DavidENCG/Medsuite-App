import '../../domain/entities/clinic.dart';
import '../../../../core/utils/json_utils.dart';

class ClinicModel extends Clinic {
  const ClinicModel({
    required super.id,
    required super.nombre,
    super.direccion,
    super.ciudad,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id']),
      nombre: JsonUtils.forceString(json['nombre'] ?? json['Nombre']),
      direccion: JsonUtils.forceString(json['direccion'] ?? json['Direccion']),
      ciudad: JsonUtils.forceString(json['ciudad'] ?? json['Ciudad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'ciudad': ciudad,
    };
  }
}
