import '../../../../core/network/api_client.dart';
import '../models/patient_model.dart';

abstract class PrivacyRemoteDataSource {
  Future<String?> generateConsentToken();
  Future<PatientModel> authorizeQr(String qrToken);
}

class PrivacyRemoteDataSourceImpl implements PrivacyRemoteDataSource {
  final ApiClient _apiClient;

  PrivacyRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<String?> generateConsentToken() async {
    final response = await _apiClient.get('/api/HistoriaMedica/consentimiento/token');
    if (response.data is Map && response.data['success'] == true) {
      return response.data['token'];
    }
    return null;
  }

  @override
  Future<PatientModel> authorizeQr(String qrToken) async {
    final response = await _apiClient.post(
      '/api/Medico/acceso/autorizar-qr',
      data: {'token': qrToken},
    );
    if (response.data is Map && response.data['success'] == true) {
      // Assuming 'data' or 'user' contains the patient profile unlocked
      final data = response.data['data'] ?? response.data['patient'];
      return PatientModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception(response.data['message'] ?? 'Error al autorizar acceso');
  }
}
