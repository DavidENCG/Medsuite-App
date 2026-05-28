import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/medical_history_model.dart';

abstract class MedicalHistoryRemoteDataSource {
  Future<FullMedicalHistoryModel> getHistoryByPatientId(int patientId);
  Future<bool> updateBasicData(int historyId, Map<String, dynamic> data);
  Future<bool> addAntecedent(int historyId, String category, Map<String, dynamic> data);
}

class MedicalHistoryRemoteDataSourceImpl implements MedicalHistoryRemoteDataSource {
  final ApiClient _apiClient;

  MedicalHistoryRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<FullMedicalHistoryModel> getHistoryByPatientId(int patientId) async {
    try {
      final response = await _apiClient.get('/api/HistoriaMedica/paciente/$patientId');
      
      final data = response.data;
      if (data is Map && data['success'] == true) {
        return FullMedicalHistoryModel.fromJson(Map<String, dynamic>.from(data));
      }

      // Si el servidor responde success: false pero indica que no existe, es un paciente nuevo
      final String msg = (data is Map ? data['message'] ?? '' : '').toString().toLowerCase();
      if (msg.contains('no existe') || msg.contains('no encontrado') || response.statusCode == 404) {
        return const FullMedicalHistoryModel(
          historiaMedicaId: 0,
          datosBasicos: BasicDataModel(),
          detalles: {},
        );
      }
      
      throw Exception(data['message'] ?? 'Error al cargar la historia médica');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return const FullMedicalHistoryModel(
          historiaMedicaId: 0,
          datosBasicos: BasicDataModel(),
          detalles: {},
        );
      }
      rethrow;
    }
  }

  @override
  Future<bool> updateBasicData(int historyId, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/api/HistoriaMedica/$historyId/datos-basicos', data: data);
    return response.data is Map && response.data['success'] == true;
  }

  @override
  Future<bool> addAntecedent(int historyId, String category, Map<String, dynamic> data) async {
    // category will be 'alergicos', 'familiares', etc.
    final response = await _apiClient.post('/api/HistoriaMedica/$historyId/antecedentes/$category', data: data);
    return response.data is Map && response.data['success'] == true;
  }
}
