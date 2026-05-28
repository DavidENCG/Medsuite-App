import '../../domain/entities/medical_history.dart';
import '../../../../core/utils/json_utils.dart';

class BasicDataModel extends BasicData {
  const BasicDataModel({
    super.tipoSangreId,
    super.tipoSangreNombre,
    super.pesoGeneralKg,
    super.estaturaGeneral,
  });

  factory BasicDataModel.fromJson(Map<String, dynamic> json) {
    return BasicDataModel(
      tipoSangreId: JsonUtils.forceIntNullable(json['tipoSangreId'] ?? json['TipoSangreId']),
      tipoSangreNombre: JsonUtils.forceString(json['tipoSangreNombre'] ?? json['TipoSangreNombre']),
      pesoGeneralKg: JsonUtils.forceString(json['pesoGeneralKg'] ?? json['PesoGeneralKg']),
      estaturaGeneral: JsonUtils.forceString(json['estaturaGeneral'] ?? json['EstaturaGeneral']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipoSangreId': tipoSangreId,
      'pesoGeneralKg': pesoGeneralKg,
      'estaturaGeneral': estaturaGeneral,
    };
  }
}

class FullMedicalHistoryModel extends FullMedicalHistory {
  const FullMedicalHistoryModel({
    required super.historiaMedicaId,
    super.patientName,
    super.patientIdCard,
    required super.datosBasicos,
    required super.detalles,
  });

  factory FullMedicalHistoryModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<dynamic>> parsedDetalles = {};
    
    // Función para extraer listas de un mapa
    void collectLists(Map<String, dynamic> source) {
      source.forEach((key, value) {
        if (value is List) {
          parsedDetalles[key] = value;
        }
      });
    }

    // 1. Buscamos en la raíz
    collectLists(json);

    // 2. Buscamos dentro de 'detalles' o 'Detalles'
    final rawDetalles = json['detalles'] ?? json['Detalles'];
    if (rawDetalles is Map) {
      collectLists(Map<String, dynamic>.from(rawDetalles));
    }

    final paciente = json['paciente'] ?? json['Paciente'] ?? {};

    return FullMedicalHistoryModel(
      historiaMedicaId: JsonUtils.forceInt(json['historiaMedicaId'] ?? json['HistoriaMedicaId']),
      patientName: JsonUtils.forceString(paciente['nombreCompleto'] ?? paciente['NombreCompleto']),
      patientIdCard: JsonUtils.forceString(paciente['identificacion'] ?? paciente['Identificacion']),
      datosBasicos: BasicDataModel.fromJson(json['datosBasicos'] ?? json['DatosBasicos'] ?? {}),
      detalles: parsedDetalles,
    );
  }
}
