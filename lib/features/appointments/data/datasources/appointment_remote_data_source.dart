import '../../../../core/network/api_client.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getTodaysAppointments();
  Future<bool> updateAppointmentStatus(int citaId, int nuevoEstadoId, {String? notas});
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiClient _apiClient;

  AppointmentRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<AppointmentModel>> getTodaysAppointments() async {
    final response = await _apiClient.get('/api/Medico/agenda/hoy');
    if (response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((item) => AppointmentModel.fromJson(item)).toList();
    }
    throw Exception('Error al obtener la agenda del día');
  }

  @override
  Future<bool> updateAppointmentStatus(int citaId, int nuevoEstadoId, {String? notas}) async {
    final response = await _apiClient.put(
      '/api/Medico/citas/$citaId/estado',
      data: {
        'nuevoEstadoId': nuevoEstadoId,
        'notas': notas,
      },
    );
    return response.data['success'] == true;
  }
}
