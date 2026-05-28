import 'package:equatable/equatable.dart';

class Clinic extends Equatable {
  final int id;
  final String nombre;
  final String? direccion;
  final String? ciudad;

  const Clinic({
    required this.id,
    required this.nombre,
    this.direccion,
    this.ciudad,
  });

  @override
  List<Object?> get props => [id, nombre, direccion, ciudad];
}
