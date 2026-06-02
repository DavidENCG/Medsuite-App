import '../../../appointments/domain/entities/clinic.dart';
import '../../data/models/registration_request_model.dart';
import '../entities/identification_type.dart';
import '../entities/registration_role.dart';
import '../entities/registration_validation.dart';
import '../entities/location.dart';
import '../../data/models/clinic_creation_request.dart';
import '../../domain/entities/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login(String email, String password);
  Future<UserSession> selectRole({
    required int userId,
    required int roleId,
    required String tokenTemporal,
  });
  Future<UserSession> selectClinic({
    required int userId,
    required int roleId,
    required int? clinicId,
    required String tokenTemporal,
  });
  Future<void> logout();
  Future<String?> getToken();
  Future<UserSession> getStoredSession();
  Future<bool> checkSubscription();
  Future<List<Clinic>> getClinics(String token);

  // Registro
  Future<List<IdentificationType>> getIdentificationTypes();
  Future<RegistrationValidation> validateRegistration({
    required int tipoIdentificacionId,
    required String identificacion,
    required String email,
  });
  Future<List<RegistrationRole>> getRegistrationRoles();
  Future<void> register(RegistrationRequest request);
  Future<void> sendWelcomeEmail({
    required String email,
    required String nombre,
    required String usuario,
    required String password,
  });

  // Creación de Consultorio
  Future<List<Country>> getCountries();
  Future<List<City>> getCitiesByCountry(int countryId);
  Future<UserSession> createClinic(ClinicCreationRequest request);
}
