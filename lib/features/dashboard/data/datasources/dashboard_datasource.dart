import 'package:flutter/widgets.dart';

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
      final response = await _apiClient.get('/api/Dashboard/summary');
      
      final rawData = response.data;
      if (rawData is Map) {
        final Map<String, dynamic> resData = Map<String, dynamic>.from(rawData);
        
        // Si la respuesta contiene directamente llaves de resumen, las usamos
        final bool hasDirectKeys = resData.containsKey('appointmentsToday') || 
                                  resData.containsKey('citasHoy') ||
                                  resData.containsKey('upcomingAppointments') ||
                                  resData.containsKey('proximasCitas');

        // Consideramos éxito si tiene éxito explícito o si tiene las llaves de datos directamente
        final bool isSuccess = resData['success'] == true || resData['Success'] == true || hasDirectKeys;
        
        if (isSuccess) {
          final payload = resData['data'] ?? resData['Data'] ?? resData;
          return DashboardSummaryModel.fromJson(Map<String, dynamic>.from(payload));
        }
      }
      
      // Si el status es exitoso pero no podemos mapear un objeto claro, devolvemos modelo vacío
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
         return const DashboardSummaryModel();
      }
      
      throw Exception('Respuesta inválida del servidor');
    } catch (e) {
      debugPrint('DASHBOARD_ERROR: $e');
      return const DashboardSummaryModel();
    }
  }
}
