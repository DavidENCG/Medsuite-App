import '../datasources/privacy_remote_data_source.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/privacy_repository.dart';

class PrivacyRepositoryImpl implements PrivacyRepository {
  final PrivacyRemoteDataSource _remoteDataSource;

  PrivacyRepositoryImpl({required PrivacyRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<String?> generateConsentToken() async {
    return await _remoteDataSource.generateConsentToken();
  }

  @override
  Future<Patient> authorizeQr(String qrToken) async {
    return await _remoteDataSource.authorizeQr(qrToken);
  }
}
