import '../../../../core/network/api_client.dart';
import '../models/consultation_detail_model.dart';

abstract class ConsultationRemoteDataSource {
  Future<ConsultationDetailModel> getConsultation(int citaId);
  Future<bool> saveConsultation(ConsultationDetailModel consultation);
}

class ConsultationRemoteDataSourceImpl implements ConsultationRemoteDataSource {
  final ApiClient _apiClient;

  ConsultationRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ConsultationDetailModel> getConsultation(int citaId) async {
    try {
      print('NETWORK: GET /api/Consulta/$citaId');
      final response = await _apiClient.get('/api/Consulta/$citaId');
      print('NETWORK: Response Data: ${response.data}');

      if (response.data is Map) {
        final Map<String, dynamic> resData = Map<String, dynamic>.from(response.data);
        if (resData['success'] == true || resData['Success'] == true) {
          final payload = resData['data'] ?? resData['Data'] ?? resData;
          return ConsultationDetailModel.fromJson(Map<String, dynamic>.from(payload));
        }
      }
      throw Exception(response.data['message'] ?? response.data['Mensaje'] ?? 'Error al obtener datos de la consulta');
    } catch (e) {
      print('NETWORK: Error in getConsultation: $e');
      rethrow;
    }
  }

  @override
  Future<bool> saveConsultation(ConsultationDetailModel consultation) async {
    final response = await _apiClient.post('/api/Consulta/guardar', data: consultation.toJson());
    return response.data is Map && response.data['success'] == true;
  }
}
