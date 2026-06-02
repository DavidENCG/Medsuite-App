import '../models/patient_model.dart';
import '../../../../core/utils/json_utils.dart';

class PatientListResponse {
  final List<PatientModel> patients;
  final int totalCount;

  PatientListResponse({
    required this.patients,
    required this.totalCount,
  });

  factory PatientListResponse.fromJson(Map<String, dynamic> json) {
    // Diagnóstico exhaustivo
    print('DEBUG: Full API JSON Keys: ${json.keys.toList()}');
    
    final List rawData = json['data'] ?? json['Data'] ?? json['patients'] ?? json['Patients'] ?? json['pacientes'] ?? json['Pacientes'] ?? [];
    print('DEBUG: Data list size: ${rawData.length}');
    
    // El error "type 'String' is not a subtype of type 'int'" sugiere que un campo esperado como int llegó como String
    // Posiblemente 'count' o 'message' si el backend lo mandó ahí.
    int count = JsonUtils.forceInt(json['count'] ?? json['Count'] ?? json['totalCount'] ?? json['TotalCount'] ?? rawData.length);
    
    // Si 'count' sigue siendo 0 pero tenemos datos, usamos el tamaño de la lista
    if (count == 0 && rawData.isNotEmpty) {
      count = rawData.length;
    }

    final mappedPatients = rawData.map((p) {
      try {
        if (p is Map) {
          return PatientModel.fromJson(Map<String, dynamic>.from(p));
        }
        return null;
      } catch (e) {
        print('DEBUG: Error mapping individual patient: $e');
        return null;
      }
    }).whereType<PatientModel>().toList();

    return PatientListResponse(
      patients: mappedPatients,
      totalCount: count,
    );
  }
}
