import '../../domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getTodaysAppointments();
  Future<List<Appointment>> getAppointmentsByDate(DateTime date);
  Future<bool> updateAppointmentStatus(int citaId, int nuevoEstadoId, {String? notas});
  Future<bool> checkConnectivity();
  Future<void> syncPendingChanges();
}
