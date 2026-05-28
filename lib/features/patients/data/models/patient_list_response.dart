import '../models/patient_model.dart';

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
    
    final List rawData = json['data'] ?? json['Data'] ?? json['patients'] ?? json['Patients'] ?? [];
    print('DEBUG: Data list size: ${rawData.length}');
    
    final int count = json['count'] ?? json['Count'] ?? rawData.length;
    print('DEBUG: Count value: $count');

    final mappedPatients = rawData.map((p) {
      try {
        return PatientModel.fromJson(Map<String, dynamic>.from(p as Map));
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
