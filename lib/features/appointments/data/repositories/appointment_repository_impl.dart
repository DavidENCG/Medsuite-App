import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_data_source.dart';
import '../datasources/appointment_remote_data_source.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource _remoteDataSource;
  final AppointmentLocalDataSource _localDataSource;
  final Connectivity _connectivity;

  AppointmentRepositoryImpl({
    required AppointmentRemoteDataSource remoteDataSource,
    required AppointmentLocalDataSource localDataSource,
    required Connectivity connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity;

  @override
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<List<Appointment>> getTodaysAppointments() async {
    final isOnline = await checkConnectivity();

    if (isOnline) {
      try {
        final appointments = await _remoteDataSource.getTodaysAppointments();
        await _localDataSource.cacheAppointments(appointments);
        return appointments;
      } catch (_) {
        return await _localDataSource.getCachedAppointments();
      }
    } else {
      return await _localDataSource.getCachedAppointments();
    }
  }

  @override
  Future<bool> updateAppointmentStatus(int citaId, int nuevoEstadoId, {String? notas}) async {
    final isOnline = await checkConnectivity();

    if (isOnline) {
      try {
        final success = await _remoteDataSource.updateAppointmentStatus(citaId, nuevoEstadoId, notas: notas);
        return success;
      } catch (_) {
        await _localDataSource.savePendingChange(citaId, nuevoEstadoId, notas);
        return true; // Return true as it's saved locally
      }
    } else {
      await _localDataSource.savePendingChange(citaId, nuevoEstadoId, notas);
      return true;
    }
  }

  @override
  Future<void> syncPendingChanges() async {
    final isOnline = await checkConnectivity();
    if (!isOnline) return;

    final pending = await _localDataSource.getPendingChanges();
    if (pending.isEmpty) return;

    for (final change in pending) {
      try {
        await _remoteDataSource.updateAppointmentStatus(
          change['citaId'],
          change['estadoId'],
          notas: change['notas'],
        );
      } catch (_) {
        // Continue with others if one fails
      }
    }
    await _localDataSource.clearPendingChanges();
  }
}
