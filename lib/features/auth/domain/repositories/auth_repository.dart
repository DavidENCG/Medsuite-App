import '../../../appointments/domain/entities/clinic.dart';
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
}
