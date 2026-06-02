class RegistrationRole {
  final int id;
  final String nombre;
  final String tipo; // 'doctor' o 'patient'

  const RegistrationRole({
    required this.id,
    required this.nombre,
    required this.tipo,
  });
}
