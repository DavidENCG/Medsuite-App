import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getTodaysAppointments();
  Future<List<AppointmentModel>> getAppointmentsByDate(DateTime date);
  Future<bool> updateAppointmentStatus(int citaId, int nuevoEstadoId, {String? notas});
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiClient _apiClient;

  AppointmentRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<AppointmentModel>> getTodaysAppointments() async {
    final response = await _apiClient.get('/api/Medico/agenda/hoy');
    if (response.data['success'] == true || response.data['Success'] == true) {
      final data = response.data['data'] ?? response.data['Data'];
      if (data is List) {
        return data.map((item) => AppointmentModel.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    }
    return [];
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByDate(DateTime date) async {
    // Aseguramos formato YYYY-MM-DD
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    try {
      final response = await _apiClient.get('/api/Medico/agenda/dia', queryParameters: {'fecha': dateStr});
      
      if (response.data['success'] == true || response.data['Success'] == true) {
        final data = response.data['data'] ?? response.data['Data'];
        if (data is List) {
          return data.map((item) => AppointmentModel.fromJson(Map<String, dynamic>.from(item))).toList();
        }
      }
      
      // Fallback si la fecha es hoy
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return await getTodaysAppointments();
      }
      
      return [];
    } catch (e) {
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return await getTodaysAppointments();
      }
      rethrow;
    }
  }

  @override
  Future<bool> updateAppointmentStatus(int citaId, int nuevoEstadoId, {String? notas}) async {
    final response = await _apiClient.put(
      '/api/citas/$citaId/estado',
      data: {
        'estadoId': nuevoEstadoId,
        'notas': notas ?? 'Actualizado desde la aplicación móvil',
      },
    );
    
    // Si el servidor responde 200, 201 o 204, consideramos éxito
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return true;
    }

    // Fallback por si devuelve un cuerpo con success: true
    if (response.data != null && response.data is Map) {
      return response.data['success'] == true || response.data['Success'] == true;
    }
    
    return false;
  }
}
