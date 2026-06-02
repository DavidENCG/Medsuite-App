import 'package:medsuite_cmo/core/utils/json_utils.dart';
import '../../domain/entities/location.dart';

class CountryModel extends Country {
  const CountryModel({required super.id, required super.nombre});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id']),
      nombre: JsonUtils.forceString(json['nombre'] ?? json['Nombre']),
    );
  }
}

class CityModel extends City {
  const CityModel({required super.id, required super.nombre, required super.paisId});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id']),
      nombre: JsonUtils.forceString(json['nombre'] ?? json['Nombre']),
      paisId: JsonUtils.forceInt(json['paisId'] ?? json['PaisId'] ?? json['id_pais']),
    );
  }
}
