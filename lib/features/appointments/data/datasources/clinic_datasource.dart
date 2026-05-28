import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/clinic_model.dart';

abstract class ClinicDataSource {
  Future<List<ClinicModel>> getMyClinics(String token);
}

class ClinicDataSourceImpl implements ClinicDataSource {
  final ApiClient _apiClient;

  ClinicDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<ClinicModel>> getMyClinics(String token) async {
    try {
      final String path = '/api/Consultorios/mis-consultorios';
      print('NETWORK: GET ${_apiClient.dio.options.baseUrl}$path');
      
      final response = await _apiClient.dio.get(
        path,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('NETWORK: Response Status: ${response.statusCode}');
      print('NETWORK: Response Data: ${response.data}');

      final data = response.data;
      if (data is Map) {
        // La API puede devolver { success, data } o { exitoso, consultorios }
        final bool success = data['success'] == true || data['exitoso'] == true;
        if (success) {
          final List? listData = data['data'] ?? data['consultorios'];
          if (listData != null) {
            return listData.map((item) => ClinicModel.fromJson(Map<String, dynamic>.from(item))).toList();
          }
        } else {
          throw Exception(data['message'] ?? data['Mensaje'] ?? data['mensaje'] ?? 'Error desconocido del servidor');
        }
      }
      return [];
    } on DioException catch (e) {
      print('NETWORK: DioError: ${e.message}');
      print('NETWORK: DioError Response: ${e.response?.data}');
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No se pudo conectar con el servidor. Verifica tu red e IP.');
      }
      rethrow;
    }
  }
}
