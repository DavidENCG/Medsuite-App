import '../entities/medical_history.dart';

abstract class MedicalHistoryRepository {
  Future<FullMedicalHistory> getHistoryByPatientId(int patientId);
  Future<bool> updateBasicData(int historyId, Map<String, dynamic> data);
  Future<bool> addAntecedent(int historyId, String category, Map<String, dynamic> data);
}
