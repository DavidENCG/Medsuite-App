import '../../../appointments/data/models/clinic_model.dart';
import '../../domain/entities/user_session.dart';
import '../../../../core/utils/json_utils.dart';

class AuthResponseModel extends UserSession {
  const AuthResponseModel({
    super.userId,
    super.roleId,
    super.activeClinicId,
    super.fullName,
    super.activeClinicName,
    super.token,
    super.tokenTemporal,
    super.needsRole = false,
    super.needsClinic = false,
    super.needsClinicCreation = false,
    super.roles,
    super.clinics,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // DIAGNÓSTICO EXHAUSTIVO DEL LOGIN
    print('--- DEBUG LOGIN RAW JSON ---');
    print(json);
    
    // The C# API returns { success, message, data?, token?, user? }
    final Map<String, dynamic> data = (json['data'] != null)
        ? json['data'] as Map<String, dynamic>
        : json;
    
    print('--- DEBUG LOGIN DATA PART ---');
    print(data);

    final Map<String, dynamic> user = (json['user'] != null)
        ? json['user'] as Map<String, dynamic>
        : {};

    // Check for session info (sometimes nested in 'sesion')
    final Map<String, dynamic> session = (data['sesion'] ?? data['Sesion'] ?? {});

    final rolesData = data['rolesDisponibles'] ?? data['RolesDisponibles'];
    final clinicsData = data['consultoriosDisponibles'] ?? data['ConsultoriosDisponibles'];

    return AuthResponseModel(
      userId: JsonUtils.forceIntNullable(data['id'] ?? data['usuarioId'] ?? user['id'] ?? user['UsuarioId'] ?? user['usuarioId'] ?? session['usuarioId'] ?? session['UsuarioId']),
      roleId: JsonUtils.forceIntNullable(data['rolId'] ?? data['RolId'] ?? user['rolId'] ?? user['RolId'] ?? session['rolId'] ?? session['RolId']),
      activeClinicId: JsonUtils.forceIntNullable(data['consultorioId'] ?? data['ConsultorioId'] ?? user['consultorioId'] ?? user['ConsultorioId'] ?? session['consultorioId'] ?? session['ConsultorioId']),
      fullName: JsonUtils.forceString(user['nombreCompleto'] ?? user['NombreCompleto'] ?? session['nombreCompleto'] ?? session['NombreCompleto']),
      activeClinicName: JsonUtils.forceString(data['consultorioNombre'] ?? data['ConsultorioNombre'] ?? user['consultorioNombre'] ?? user['ConsultorioNombre'] ?? session['consultorioNombre'] ?? session['ConsultorioNombre']),
      token: json['token'] as String?, 
      tokenTemporal: data['tokenTemporal'] as String? ?? data['TokenTemporal'] as String?,
      needsRole: json['requiresRoleSelection'] ?? json['RequiresRoleSelection'] ?? data['requiereSeleccionRol'] ?? data['RequiereSeleccionRol'] ?? false,
      needsClinic: json['requiresClinicSelection'] ?? json['RequiresClinicSelection'] ?? data['requiereSeleccionConsultorio'] ?? data['RequiereSeleccionConsultorio'] ?? false,
      needsClinicCreation: json['requiresClinicCreation'] ?? json['RequiresClinicCreation'] ?? data['requiereCrearConsultorio'] ?? data['RequiereCrearConsultorio'] ?? data['requiresCrearConsultorio'] ?? false,
      roles: rolesData is List
          ? rolesData.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : null,
      clinics: clinicsData is List
          ? clinicsData.map((e) => ClinicModel.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'rolId': roleId,
      'consultorioId': activeClinicId,
      'token': token,
      'tokenTemporal': tokenTemporal,
      'requiereSeleccionRol': needsRole,
      'requiereSeleccionConsultorio': needsClinic,
      'requiereCreacionConsultorio': needsClinicCreation,
      'rolesDisponibles': roles,
      'consultoriosDisponibles': clinics,
    };
  }
}
