import 'package:intl/intl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_datasource.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource _dataSource;
  final AppointmentRepository _appointmentRepository;

  DashboardRepositoryImpl({
    required DashboardDataSource dataSource,
    required AppointmentRepository appointmentRepository,
  })  : _dataSource = dataSource,
        _appointmentRepository = appointmentRepository;

  @override
  Future<DashboardSummary> getSummary() async {
    // Obtenemos el resumen base (contadores, etc)
    final summary = await _dataSource.getSummary();
    
    // Obtenemos las citas reales usando el endpoint de la Agenda (que sí funciona)
    try {
      final realAppointments = await _appointmentRepository.getTodaysAppointments();
      
      if (realAppointments.isNotEmpty) {
        // Convertimos las entidades de cita al formato que espera el Dashboard
        final mappedAppointments = realAppointments.map((a) {
          // Formatear hora de HH:mm:ss a h:mm a
          String formattedTime = a.horaCita;
          try {
            final timeParts = a.horaCita.split(':');
            final date = DateTime(2000, 1, 1, int.parse(timeParts[0]), int.parse(timeParts[1]));
            formattedTime = DateFormat('h:mm a').format(date);
          } catch (_) {}

          return {
            'time': formattedTime,
            'patient': a.pacienteNombre,
            'type': a.motivoConsulta,
          };
        }).toList();

        return DashboardSummary(
          appointmentsToday: realAppointments.length, // Usamos el conteo real
          newPatientsThisMonth: summary.newPatientsThisMonth,
          pendingMedicalRecords: summary.pendingMedicalRecords,
          monthlyRevenue: summary.monthlyRevenue,
          upcomingAppointments: mappedAppointments,
        );
      }
    } catch (_) {
      // Si falla la carga de citas reales, devolvemos el resumen original
    }
    
    return summary;
  }
}
