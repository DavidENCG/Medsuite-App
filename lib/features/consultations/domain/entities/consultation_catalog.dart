import 'package:equatable/equatable.dart';

class ConsultationCatalog extends Equatable {
  final List<CatalogItem> viasAdministracion;
  final List<CatalogItem> tiposExamenSolicitado;
  final PhysicalExamCatalog physicalExam;

  const ConsultationCatalog({
    required this.viasAdministracion,
    required this.tiposExamenSolicitado,
    required this.physicalExam,
  });

  @override
  List<Object?> get props => [viasAdministracion, tiposExamenSolicitado, physicalExam];
}

class CatalogItem extends Equatable {
  final int id;
  final String nombre;
  final int? parentId;

  const CatalogItem({required this.id, required this.nombre, this.parentId});

  @override
  List<Object?> get props => [id, nombre, parentId];
}

class PhysicalExamCatalog extends Equatable {
  final List<CatalogItem> examenes;
  final List<CatalogItem> zonas;

  const PhysicalExamCatalog({
    required this.examenes,
    required this.zonas,
  });

  @override
  List<Object?> get props => [examenes, zonas];
}
