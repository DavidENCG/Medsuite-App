import '../entities/patient.dart';

abstract class PatientRepository {
  Future<(List<Patient>, int)> getMyPatients();
  Future<(List<Patient>, int)> searchPatients(String query);
  Future<Patient> getPatientById(int id);
  Future<bool> updatePatient(int id, Map<String, dynamic> data);
  Future<bool> checkConnectivity();
}
