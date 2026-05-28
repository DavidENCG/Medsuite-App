import '../../../../core/network/api_client.dart';
import '../models/medical_case_model.dart';
import '../models/case_detail_model.dart';

abstract class CaseRemoteDataSource {
  Future<List<MedicalCaseModel>> getPatientCases(int patientId);
  Future<bool> createCase(Map<String, dynamic> data);
  Future<CaseDetailModel> getCaseById(int caseId);
  Future<bool> scheduleAppointment(Map<String, dynamic> data);
}

class CaseRemoteDataSourceImpl implements CaseRemoteDataSource {
  final ApiClient _apiClient;

  CaseRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<MedicalCaseModel>> getPatientCases(int patientId) async {
    try {
      final String path = '/api/Casos/paciente/$patientId';
      print('NETWORK: GET ${_apiClient.dio.options.baseUrl}$path');
      
      final response = await _apiClient.get(path);
      
      print('NETWORK: Response Status: ${response.statusCode}');
      print('NETWORK: Response Data: ${response.data}');

      if (response.data is Map && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((e) => MedicalCaseModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return [];
    } catch (e) {
      print('NETWORK: Error in getPatientCases: $e');
      rethrow;
    }
  }

  @override
  Future<bool> createCase(Map<String, dynamic> data) async {
    try {
      print('NETWORK: POST /api/Casos/crear');
      print('NETWORK: Body: $data');
      final response = await _apiClient.post('/api/Casos/crear', data: data);
      print('NETWORK: Response: ${response.data}');
      return response.data is Map && response.data['success'] == true;
    } catch (e) {
      print('NETWORK: Error in createCase: $e');
      rethrow;
    }
  }

  @override
  Future<CaseDetailModel> getCaseById(int caseId) async {
    try {
      print('NETWORK: GET /api/Casos/$caseId');
      final response = await _apiClient.get('/api/Casos/$caseId');
      print('NETWORK: Response: ${response.data}');
      
      if (response.data is Map && response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        return CaseDetailModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception(response.data['message'] ?? 'Error al obtener detalles del caso');
    } catch (e) {
      print('NETWORK: Error in getCaseById: $e');
      rethrow;
    }
  }

  @override
  Future<bool> scheduleAppointment(Map<String, dynamic> data) async {
    try {
      print('NETWORK: POST /api/Citas/agendar');
      print('NETWORK: Body: $data');
      final response = await _apiClient.post('/api/Citas/agendar', data: data);
      print('NETWORK: Response: ${response.data}');
      return response.data is Map && response.data['success'] == true;
    } catch (e) {
      print('NETWORK: Error in scheduleAppointment: $e');
      rethrow;
    }
  }
}
