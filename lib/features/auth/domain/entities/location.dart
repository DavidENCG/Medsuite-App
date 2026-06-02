class Country {
  final int id;
  final String nombre;

  const Country({required this.id, required this.nombre});
}

class City {
  final int id;
  final String nombre;
  final int paisId;

  const City({required this.id, required this.nombre, required this.paisId});
}
