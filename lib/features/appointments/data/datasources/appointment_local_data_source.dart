import 'package:hive/hive.dart';
import '../models/appointment_model.dart';

abstract class AppointmentLocalDataSource {
  Future<void> cacheAppointments(List<AppointmentModel> appointments, {String? dateKey});
  Future<List<AppointmentModel>> getCachedAppointments({String? dateKey});
  Future<void> savePendingChange(int citaId, int estadoId, String? notas);
  Future<List<Map<String, dynamic>>> getPendingChanges();
  Future<void> clearPendingChanges();
}

class AppointmentLocalDataSourceImpl implements AppointmentLocalDataSource {
  static const String _appointmentsBox = 'appointments_box';
  static const String _pendingChangesBox = 'pending_changes_box';

  @override
  Future<void> cacheAppointments(List<AppointmentModel> appointments, {String? dateKey}) async {
    final box = await Hive.openBox(_appointmentsBox);
    final data = appointments.map((e) => e.toJson()).toList();
    await box.put(dateKey ?? 'today', data);
  }

  @override
  Future<List<AppointmentModel>> getCachedAppointments({String? dateKey}) async {
    final box = await Hive.openBox(_appointmentsBox);
    final List? data = box.get(dateKey ?? 'today');
    if (data != null) {
      return data.map((e) => AppointmentModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  @override
  Future<void> savePendingChange(int citaId, int estadoId, String? notas) async {
    final box = await Hive.openBox(_pendingChangesBox);
    await box.add({
      'citaId': citaId,
      'estadoId': estadoId,
      'notas': notas,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingChanges() async {
    final box = await Hive.openBox(_pendingChangesBox);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> clearPendingChanges() async {
    final box = await Hive.openBox(_pendingChangesBox);
    await box.clear();
  }
}
