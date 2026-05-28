import '../entities/patient.dart';

abstract class PrivacyRepository {
  Future<String?> generateConsentToken();
  Future<Patient> authorizeQr(String qrToken);
}
