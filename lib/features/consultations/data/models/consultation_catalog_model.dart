import '../../domain/entities/consultation_catalog.dart';
import '../../../../core/utils/json_utils.dart';

class ConsultationCatalogModel extends ConsultationCatalog {
  const ConsultationCatalogModel({
    required super.viasAdministracion,
    required super.tiposExamenSolicitado,
    required super.physicalExam,
  });

  factory ConsultationCatalogModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    return ConsultationCatalogModel(
      viasAdministracion: (data['viasAdministracion'] as List?)
              ?.map((e) => CatalogItemModel.fromJson(e))
              .toList() ?? [],
      tiposExamenSolicitado: (data['tiposExamenSolicitado'] as List?)
              ?.map((e) => CatalogItemModel.fromJson(e))
              .toList() ?? [],
      physicalExam: PhysicalExamCatalogModel.fromJson(data['examenFisico'] ?? {}),
    );
  }
}

class CatalogItemModel extends CatalogItem {
  const CatalogItemModel({required super.id, required super.nombre, super.parentId});

  factory CatalogItemModel.fromJson(dynamic json) {
    if (json is String) {
        return CatalogItemModel(id: 0, nombre: json);
    }
    final map = json as Map<String, dynamic>;
    return CatalogItemModel(
      id: JsonUtils.forceInt(map['id'] ?? map['Id'] ?? 0),
      nombre: JsonUtils.forceString(map['nombre'] ?? map['Nombre'] ?? map['descripcion'] ?? map['Descripcion'] ?? ''),
      parentId: JsonUtils.forceIntNullable(map['examenFisicoId'] ?? map['ExamenFisicoId'] ?? map['parentId'] ?? map['examenId'] ?? map['ExamenId']),
    );
  }
}

class PhysicalExamCatalogModel extends PhysicalExamCatalog {
  const PhysicalExamCatalogModel({
    required super.examenes,
    required super.zonas,
  });

  factory PhysicalExamCatalogModel.fromJson(Map<String, dynamic> json) {
    return PhysicalExamCatalogModel(
      examenes: (json['examenes'] as List?)
              ?.map((e) => CatalogItemModel.fromJson(e))
              .toList() ?? [],
      zonas: (json['zonas'] as List?)
              ?.map((e) => CatalogItemModel.fromJson(e))
              .toList() ?? [],
    );
  }
}
