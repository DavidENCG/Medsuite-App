import 'package:medsuite_cmo/core/utils/json_utils.dart';
import '../../domain/entities/registration_role.dart';

class RegistrationRoleModel extends RegistrationRole {
  const RegistrationRoleModel({
    required super.id,
    required super.nombre,
    required super.tipo,
  });

  factory RegistrationRoleModel.fromJson(Map<String, dynamic> json) {
    return RegistrationRoleModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id']),
      nombre: JsonUtils.forceString(json['nombre'] ?? json['Nombre']),
      tipo: JsonUtils.forceString(json['tipo'] ?? json['Tipo']),
    );
  }
}
