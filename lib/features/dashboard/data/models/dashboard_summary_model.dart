import '../../domain/entities/dashboard_summary.dart';

import '../../../../core/utils/json_utils.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    super.appointmentsToday,
    super.newPatientsThisMonth,
    super.pendingMedicalRecords,
    super.monthlyRevenue,
    super.upcomingAppointments,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct data and wrapped data { success: true, data: { ... } }
    final Map<String, dynamic> data = (json.containsKey('data') && json['data'] != null)
        ? Map<String, dynamic>.from(json['data'] as Map)
        : (json.containsKey('Data') && json['Data'] != null) 
            ? Map<String, dynamic>.from(json['Data'] as Map)
            : json;

    final upcomingRaw = data['upcomingAppointments'] ?? data['UpcomingAppointments'] ?? data['proximasCitas'] ?? data['ProximasCitas'];
    
    List<Map<String, dynamic>> parsedUpcoming = [];
    if (upcomingRaw is List) {
       parsedUpcoming = upcomingRaw.map((e) {
         final map = Map<String, dynamic>.from(e as Map);
         // Normalizamos las llaves internamente para que la UI no tenga que lidiar con Casing
         return {
           'time': map['time'] ?? map['Time'] ?? map['horaCita'] ?? map['HoraCita'] ?? '',
           'patient': map['patient'] ?? map['Patient'] ?? map['pacienteNombre'] ?? map['PacienteNombre'] ?? 'Paciente',
           'type': map['type'] ?? map['Type'] ?? map['motivoConsulta'] ?? map['MotivoConsulta'] ?? 'Consulta',
         };
       }).toList();
    }

    return DashboardSummaryModel(
      appointmentsToday: JsonUtils.forceInt(data['appointmentsToday'] ?? data['AppointmentsToday']),
      newPatientsThisMonth: JsonUtils.forceInt(data['newPatientsThisMonth'] ?? data['NewPatientsThisMonth']),
      pendingMedicalRecords: JsonUtils.forceInt(data['pendingMedicalRecords'] ?? data['PendingMedicalRecords']),
      monthlyRevenue: (data['monthlyRevenue'] ?? data['MonthlyRevenue'] ?? 0).toDouble(),
      upcomingAppointments: parsedUpcoming,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentsToday': appointmentsToday,
      'newPatientsThisMonth': newPatientsThisMonth,
      'pendingMedicalRecords': pendingMedicalRecords,
      'monthlyRevenue': monthlyRevenue,
      'upcomingAppointments': upcomingAppointments,
    };
  }
}
