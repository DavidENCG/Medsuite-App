import 'package:equatable/equatable.dart';

class ProfileCatalog extends Equatable {
  final List<CatalogItem> idTypes;
  final List<CatalogItem> genders;
  final List<CatalogItem> countries;
  final List<CatalogItem> phoneCodes;

  const ProfileCatalog({
    required this.idTypes,
    required this.genders,
    required this.countries,
    required this.phoneCodes,
  });

  @override
  List<Object?> get props => [idTypes, genders, countries, phoneCodes];
}

class CatalogItem extends Equatable {
  final int id;
  final String nombre;
  final String? extra;

  const CatalogItem({
    required this.id,
    required this.nombre,
    this.extra,
  });

  @override
  List<Object?> get props => [id, nombre, extra];
}
