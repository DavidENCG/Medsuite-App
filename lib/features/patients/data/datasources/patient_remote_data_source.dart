import '../../../../core/network/api_client.dart';
import '../models/patient_list_response.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<PatientListResponse> getMyPatients();
  Future<PatientListResponse> searchPatients(String query);
  Future<PatientModel> getPatientById(int id);
  Future<bool> updatePatient(int id, Map<String, dynamic> data);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final ApiClient _apiClient;

  PatientRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<PatientListResponse> getMyPatients() async {
    try {
      final String path = '/api/Pacientes/mis-pacientes';
      print('NETWORK: Requesting patients list...');
      
      final response = await _apiClient.get(path);
      
      print('NETWORK: Response Status: ${response.statusCode}');
      print('NETWORK: Raw Response Data Type: ${response.data.runtimeType}');
      print('NETWORK: Raw Response Body: ${response.data}');

      if (response.data is Map && response.data['success'] == true) {
        return PatientListResponse.fromJson(Map<String, dynamic>.from(response.data));
      }
      throw Exception(response.data['message'] ?? 'Error al obtener pacientes');
    } catch (e) {
      print('NETWORK: CRITICAL ERROR in getMyPatients: $e');
      rethrow;
    }
  }

  @override
  Future<PatientListResponse> searchPatients(String query) async {
    final response = await _apiClient.get('/api/Pacientes/buscar', queryParameters: {'q': query});
    if (response.data is Map && response.data['success'] == true) {
      return PatientListResponse.fromJson(Map<String, dynamic>.from(response.data));
    }
    throw Exception(response.data['message'] ?? 'Error en la búsqueda');
  }

  @override
  Future<PatientModel> getPatientById(int id) async {
    final response = await _apiClient.get('/api/Pacientes/$id');
    if (response.data is Map && response.data['success'] == true) {
      return PatientModel.fromJson(Map<String, dynamic>.from(response.data['data']));
    }
    throw Exception(response.data['message'] ?? 'Error al obtener datos del paciente');
  }

  @override
  Future<bool> updatePatient(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/api/Pacientes/$id', data: data);
    return response.data is Map && response.data['success'] == true;
  }
}
