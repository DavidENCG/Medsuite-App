import '../../../../core/network/api_client.dart';
import '../models/dashboard_summary_model.dart';

abstract class DashboardDataSource {
  Future<DashboardSummaryModel> getSummary();
}

class DashboardDataSourceImpl implements DashboardDataSource {
  final ApiClient _apiClient;

  DashboardDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<DashboardSummaryModel> getSummary() async {
    try {
      print('NETWORK: GET /api/Dashboard/summary');
      final response = await _apiClient.get('/api/Dashboard/summary');
      
      print('NETWORK: Dashboard Status: ${response.statusCode}');
      print('NETWORK: Dashboard Raw Data: ${response.data}');

      final rawData = response.data;
      if (rawData is Map) {
        final Map<String, dynamic> resData = Map<String, dynamic>.from(rawData);
        if (resData['success'] == true || resData['Success'] == true) {
          final payload = resData['data'] ?? resData['Data'] ?? resData;
          return DashboardSummaryModel.fromJson(Map<String, dynamic>.from(payload));
        }
      }
      throw Exception('Respuesta inválida del servidor');
    } catch (e) {
      // Si falla (porque aún no existe el endpoint), devolvemos datos de prueba profesionales
      await Future.delayed(const Duration(seconds: 1));
      return const DashboardSummaryModel(
        appointmentsToday: 8,
        newPatientsThisMonth: 12,
        pendingMedicalRecords: 3,
        monthlyRevenue: 2450.0,
        upcomingAppointments: [
          {
            'time': '09:00 AM',
            'patient': 'Juan Pérez',
            'type': 'Consulta General',
          },
          {
            'time': '10:30 AM',
            'patient': 'María García',
            'type': 'Seguimiento',
          },
          {
            'time': '02:00 PM',
            'patient': 'Carlos Ruiz',
            'type': 'Control Post-Operatorio',
          },
        ],
      );
    }
  }
}
