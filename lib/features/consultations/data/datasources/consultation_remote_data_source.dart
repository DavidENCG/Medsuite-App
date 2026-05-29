import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/consultation_detail_model.dart';

import '../../domain/entities/consultation_catalog.dart';
import '../models/consultation_catalog_model.dart';

abstract class ConsultationRemoteDataSource {
  Future<ConsultationDetailModel> getConsultation(int citaId);
  Future<ConsultationDetailModel?> saveConsultation(ConsultationDetailModel consultation);
  Future<ConsultationCatalogModel> getCatalogs();
  Future<List<int>> downloadPrescription(int citaId);
  Future<List<int>> downloadReport(int citaId, Map<String, bool> sections);
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
  Future<ConsultationDetailModel?> saveConsultation(ConsultationDetailModel consultation) async {
    try {
      print('NETWORK: POST /api/Consulta/guardar Payload: ${consultation.toJson()}');
      final response = await _apiClient.post('/api/Consulta/guardar', data: consultation.toJson());
      print('NETWORK: Save Response: ${response.data}');

      if (response.data is Map) {
        final Map<String, dynamic> resData = Map<String, dynamic>.from(response.data);
        if (resData['success'] == true || resData['Success'] == true) {
          // Intentar obtener el objeto actualizado si la API lo devuelve, si no, pedirlo de nuevo
          if (resData['data'] != null) {
            return ConsultationDetailModel.fromJson(Map<String, dynamic>.from(resData['data']));
          }
          // Si no viene en el 'data' del POST, el BLoC se encargará de re-peticionar el GET
          return null; 
        } else {
          String errorMsg = resData['message'] ?? resData['Mensaje'];
          if (errorMsg == null && resData.containsKey('errors')) {
             final errors = resData['errors'];
             if (errors is Map) {
               errorMsg = errors.values.map((v) => v.toString()).join('\n');
             } else {
               errorMsg = errors.toString();
             }
          }
          errorMsg ??= resData.toString();
          throw Exception(errorMsg);
        }
      }
      return null;
    } catch (e) {
      print('NETWORK: Error in saveConsultation: $e');
      rethrow;
    }
  }

  @override
  Future<ConsultationCatalogModel> getCatalogs() async {
    try {
      print('NETWORK: GET /api/Consulta/catalogos');
      final response = await _apiClient.get('/api/Consulta/catalogos');
      print('NETWORK: Catalogs Data: ${response.data}');

      if (response.data is Map) {
        final Map<String, dynamic> resData = Map<String, dynamic>.from(response.data);
        if (resData['success'] == true || resData['Success'] == true) {
          return ConsultationCatalogModel.fromJson(resData);
        }
      }
      throw Exception(response.data['message'] ?? 'Error al obtener catálogos');
    } catch (e) {
      print('NETWORK: Error in getCatalogs: $e');
      rethrow;
    }
  }

  @override
  Future<List<int>> downloadPrescription(int citaId) async {
    try {
      print('NETWORK: GET /api/Reportes/receta/$citaId');
      final response = await _apiClient.get(
        '/api/Reportes/receta/$citaId',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as List<int>;
    } catch (e) {
      print('NETWORK: Error in downloadPrescription: $e');
      rethrow;
    }
  }

  @override
  Future<List<int>> downloadReport(int citaId, Map<String, bool> sections) async {
    try {
      final queryParams = sections.map((key, value) => MapEntry(key, value.toString()));
      print('NETWORK: GET /api/Reportes/informe/$citaId with params: $queryParams');
      final response = await _apiClient.get(
        '/api/Reportes/informe/$citaId',
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data as List<int>;
    } catch (e) {
      print('NETWORK: Error in downloadReport: $e');
      rethrow;
    }
  }
}
