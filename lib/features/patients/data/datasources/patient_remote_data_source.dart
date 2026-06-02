import '../../../../core/network/api_client.dart';
import 'package:medsuite_cmo/features/auth/data/models/identification_type_model.dart';
import '../models/patient_list_response.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<PatientListResponse> getMyPatients();
  Future<PatientListResponse> searchPatients(String query);
  Future<PatientModel> getPatientById(int id);
  Future<bool> updatePatient(int id, Map<String, dynamic> data);

  // Registro de Pacientes
  Future<List<IdentificationTypeModel>> getIdentificationTypes();
  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final ApiClient _apiClient;

  PatientRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<PatientListResponse> getMyPatients() async {
    try {
      const String path = '/api/Pacientes/mis-pacientes';
      final response = await _apiClient.get(path);
      
      if (response.data is Map) {
        final Map<String, dynamic> resData = Map<String, dynamic>.from(response.data);
        if (resData['success'] == true || resData['Success'] == true) {
          return PatientListResponse.fromJson(resData);
        }
      }
      throw Exception(response.data['message'] ?? 'Error al obtener pacientes');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PatientListResponse> searchPatients(String query) async {
    final response = await _apiClient.get('/api/Pacientes/buscar', queryParameters: {'q': query});
    if (response.data is Map && (response.data['success'] == true || response.data['Success'] == true)) {
      return PatientListResponse.fromJson(Map<String, dynamic>.from(response.data));
    }
    throw Exception(response.data['message'] ?? 'Error en la búsqueda');
  }

  @override
  Future<PatientModel> getPatientById(int id) async {
    final response = await _apiClient.get('/api/Pacientes/$id');
    if (response.data is Map && (response.data['success'] == true || response.data['Success'] == true)) {
      final data = response.data['data'] ?? response.data['Data'] ?? response.data;
      return PatientModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception(response.data['message'] ?? 'Error al obtener datos del paciente');
  }

  @override
  Future<bool> updatePatient(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/api/Pacientes/$id', data: data);
    return response.data is Map && (response.data['success'] == true || response.data['Success'] == true);
  }

  @override
  Future<List<IdentificationTypeModel>> getIdentificationTypes() async {
    final response = await _apiClient.get('/api/auth/tipos-identificacion');
    final List data = response.data is List 
        ? response.data 
        : (response.data['tipos'] ?? response.data['Tipos'] ?? response.data['data'] ?? response.data['Data'] ?? []);
    return data.map((e) => IdentificationTypeModel.fromJson(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/api/pacientes/crear', data: data);
    if (response.data is Map) {
      final resData = Map<String, dynamic>.from(response.data);
      if (resData['success'] == true || resData['Success'] == true) {
        return resData;
      }
      throw Exception(resData['message'] ?? 'Error al crear paciente');
    }
    throw Exception('Error inesperado al crear paciente');
  }
}
