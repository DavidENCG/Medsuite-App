import '../entities/medical_case.dart';
import '../entities/case_detail.dart';

abstract class CaseRepository {
  Future<List<MedicalCase>> getPatientCases(int patientId);
  Future<bool> createCase(Map<String, dynamic> data);
  Future<CaseDetail> getCaseById(int caseId);
  Future<bool> scheduleAppointment(Map<String, dynamic> data);
}
