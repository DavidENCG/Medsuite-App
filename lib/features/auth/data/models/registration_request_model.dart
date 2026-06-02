class RegistrationRequest {
  final String nombre;
  final String apellido;
  final int tipoIdentificacionId;
  final String identificacion;
  final String email;
  final String telefono;
  final String password;
  final int rolId;

  RegistrationRequest({
    required this.nombre,
    required this.apellido,
    required this.tipoIdentificacionId,
    required this.identificacion,
    required this.email,
    required this.telefono,
    required this.password,
    required this.rolId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'tipoIdentificacionId': tipoIdentificacionId,
      'identificacion': identificacion,
      'email': email,
      'telefono': telefono,
      'contraseña': password,
      'rolId': rolId,
    };
  }
}
