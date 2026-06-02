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
    // Intentamos extraer el payload real (ya sea que venga envuelto en 'data' o sea el objeto raíz)
    final Map<String, dynamic> data = (json.containsKey('data') && json['data'] != null && json['data'] is Map)
        ? Map<String, dynamic>.from(json['data'] as Map)
        : (json.containsKey('Data') && json['Data'] != null && json['Data'] is Map) 
            ? Map<String, dynamic>.from(json['Data'] as Map)
            : json;

    final upcomingRaw = data['upcomingAppointments'] ?? data['UpcomingAppointments'] ?? 
                        data['proximasCitas'] ?? data['ProximasCitas'] ?? 
                        data['citas'] ?? data['Citas'];
    
    List<Map<String, dynamic>> parsedUpcoming = [];
    if (upcomingRaw is List) {
       parsedUpcoming = upcomingRaw.map((e) {
         final map = Map<String, dynamic>.from(e as Map);
         return {
           'time': map['time'] ?? map['Time'] ?? map['horaCita'] ?? map['HoraCita'] ?? map['hora'] ?? '',
           'patient': map['patient'] ?? map['Patient'] ?? map['pacienteNombre'] ?? map['PacienteNombre'] ?? map['paciente'] ?? 'Paciente',
           'type': map['type'] ?? map['Type'] ?? map['motivoConsulta'] ?? map['MotivoConsulta'] ?? map['tipo'] ?? 'Consulta',
         };
       }).toList();
    }

    return DashboardSummaryModel(
      appointmentsToday: JsonUtils.forceInt(data['appointmentsToday'] ?? data['AppointmentsToday'] ?? data['citasHoy'] ?? data['CitasHoy'] ?? data['totalCitas'] ?? 0),
      newPatientsThisMonth: JsonUtils.forceInt(data['newPatientsThisMonth'] ?? data['NewPatientsThisMonth'] ?? data['pacientesMes'] ?? data['PacientesMes'] ?? 0),
      pendingMedicalRecords: JsonUtils.forceInt(data['pendingMedicalRecords'] ?? data['PendingMedicalRecords'] ?? data['historiasPendientes'] ?? data['HistoriasPendientes'] ?? 0),
      monthlyRevenue: (data['monthlyRevenue'] ?? data['MonthlyRevenue'] ?? data['ingresosMes'] ?? data['IngresosMes'] ?? 0).toDouble(),
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
