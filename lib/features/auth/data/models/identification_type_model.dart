import 'package:medsuite_cmo/core/utils/json_utils.dart';
import '../../domain/entities/identification_type.dart';

class IdentificationTypeModel extends IdentificationType {
  const IdentificationTypeModel({
    required super.id,
    required super.nombre,
  });

  factory IdentificationTypeModel.fromJson(Map<String, dynamic> json) {
    return IdentificationTypeModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id'] ?? json['tipoIdentificacionId'] ?? json['TipoIdentificacionId']),
      nombre: JsonUtils.forceString(
        json['nombre'] ?? 
        json['Nombre'] ?? 
        json['sigla'] ?? 
        json['Sigla'] ?? 
        json['abreviatura'] ?? 
        json['Abreviatura'] ?? 
        json['descripcion'] ?? 
        json['Descripcion']
      ),
    );
  }
}
