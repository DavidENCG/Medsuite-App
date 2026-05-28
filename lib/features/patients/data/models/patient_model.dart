import '../../domain/entities/patient.dart';
import '../../../../core/utils/json_utils.dart';

class PatientModel extends Patient {
  const PatientModel({
    required super.usuarioId,
    required super.nombreCompleto,
    super.nombre,
    super.apellido,
    required super.identificacion,
    super.tipoIdentificacionId,
    super.edad,
    super.fechaNacimiento,
    super.sexoId,
    required super.tieneHistoria,
    super.ultimaCita,
    super.telefono,
    super.email,
    super.tipoSangre,
    super.direccion,
    super.ciudadId,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    DateTime? safeParseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    try {
      return PatientModel(
        usuarioId: JsonUtils.forceInt(json['usuarioId'] ?? json['UsuarioId'] ?? json['id'] ?? json['Id']),
        nombreCompleto: JsonUtils.forceString(
          json['nombreCompleto'] ?? json['NombreCompleto'] ?? json['pacienteNombre'] ?? json['PacienteNombre']
        ),
        nombre: JsonUtils.forceString(json['nombre'] ?? json['Nombre']),
        apellido: JsonUtils.forceString(json['apellido'] ?? json['Apellido']),
        identificacion: JsonUtils.forceString(
          json['identificacion'] ?? json['Identificacion'] ?? json['pacienteIdentificacion'] ?? json['PacienteIdentificacion']
        ),
        tipoIdentificacionId: JsonUtils.forceIntNullable(json['tipoIdentificacionId'] ?? json['TipoIdentificacionId']),
        edad: JsonUtils.forceIntNullable(json['edad'] ?? json['Edad']),
        fechaNacimiento: safeParseDate(json['fechaNacimiento'] ?? json['FechaNacimiento']),
        sexoId: JsonUtils.forceIntNullable(json['sexoId'] ?? json['SexoId']),
        tieneHistoria: json['tieneHistoria'] ?? json['TieneHistoria'] ?? false,
        ultimaCita: safeParseDate(json['ultimaCita'] ?? json['UltimaCita']),
        telefono: JsonUtils.forceString(json['telefono'] ?? json['Telefono']),
        email: JsonUtils.forceString(json['email'] ?? json['Email']),
        tipoSangre: JsonUtils.forceString(json['tipoSangre'] ?? json['TipoSangre']),
        direccion: JsonUtils.forceString(json['direccion'] ?? json['Direccion']),
        ciudadId: JsonUtils.forceIntNullable(json['ciudadId'] ?? json['CiudadId']),
      );
    } catch (e) {
      print('CRITICAL ERROR parsing PatientModel: $e');
      print('RAW JSON ITEM: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'nombre': nombre,
      'apellido': apellido,
      'nombreCompleto': nombreCompleto,
      'tipoIdentificacionId': tipoIdentificacionId,
      'identificacion': identificacion,
      'edad': edad,
      'fechaNacimiento': fechaNacimiento?.toIso8601String().split('T')[0],
      'sexoId': sexoId,
      'tieneHistoria': tieneHistoria,
      'ultimaCita': ultimaCita?.toIso8601String(),
      'telefono': telefono,
      'email': email,
      'tipoSangre': tipoSangre,
      'direccion': direccion,
      'ciudadId': ciudadId,
    };
  }
}
