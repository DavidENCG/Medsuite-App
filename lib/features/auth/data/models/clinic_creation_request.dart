class ClinicCreationRequest {
  final String nombre;
  final String direccion;
  final int ciudadId;
  final int usuarioId;
  final int rolId;
  final String tokenTemporal;

  ClinicCreationRequest({
    required this.nombre,
    required this.direccion,
    required this.ciudadId,
    required this.usuarioId,
    required this.rolId,
    required this.tokenTemporal,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'ciudadId': ciudadId,
      'usuarioId': usuarioId,
      'rolId': rolId,
      'tokenTemporal': tokenTemporal,
    };
  }
}
