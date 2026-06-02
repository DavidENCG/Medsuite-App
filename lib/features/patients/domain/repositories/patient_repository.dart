import 'package:medsuite_cmo/features/auth/domain/entities/identification_type.dart';
import '../entities/patient.dart';

abstract class PatientRepository {
  Future<(List<Patient>, int)> getMyPatients();
  Future<(List<Patient>, int)> searchPatients(String query);
  Future<Patient> getPatientById(int id);
  Future<bool> updatePatient(int id, Map<String, dynamic> data);
  Future<bool> checkConnectivity();

  // Registro de Pacientes
  Future<List<IdentificationType>> getIdentificationTypes();
  Future<Map<String, dynamic>> createPatient({
    required String nombre,
    required String apellido,
    required int tipoIdentificacionId,
    required String identificacion,
  });
}
