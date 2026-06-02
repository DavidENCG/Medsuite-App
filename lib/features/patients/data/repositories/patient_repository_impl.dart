import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:medsuite_cmo/features/auth/domain/entities/identification_type.dart';
import '../datasources/patient_local_data_source.dart';
import '../datasources/patient_remote_data_source.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource _remoteDataSource;
  final PatientLocalDataSource _localDataSource;
  final Connectivity _connectivity;

  PatientRepositoryImpl({
    required PatientRemoteDataSource remoteDataSource,
    required PatientLocalDataSource localDataSource,
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
  Future<(List<Patient>, int)> getMyPatients() async {
    final isOnline = await checkConnectivity();
    if (isOnline) {
      try {
        final response = await _remoteDataSource.getMyPatients();
        await _localDataSource.cachePatients(response.patients);
        return (response.patients, response.totalCount);
      } catch (_) {
        final cached = await _localDataSource.getCachedPatients();
        return (cached, cached.length);
      }
    } else {
      final cached = await _localDataSource.getCachedPatients();
      return (cached, cached.length);
    }
  }

  @override
  Future<(List<Patient>, int)> searchPatients(String query) async {
    final isOnline = await checkConnectivity();
    if (isOnline) {
      final response = await _remoteDataSource.searchPatients(query);
      return (response.patients, response.totalCount);
    } else {
      final cached = await _localDataSource.getCachedPatients();
      final filtered = cached.where((p) {
        return p.nombreCompleto.toLowerCase().contains(query.toLowerCase()) ||
               p.identificacion.contains(query);
      }).toList();
      return (filtered, filtered.length);
    }
  }

  @override
  Future<Patient> getPatientById(int id) async {
    return await _remoteDataSource.getPatientById(id);
  }

  @override
  Future<bool> updatePatient(int id, Map<String, dynamic> data) async {
    return await _remoteDataSource.updatePatient(id, data);
  }

  @override
  Future<List<IdentificationType>> getIdentificationTypes() async {
    return await _remoteDataSource.getIdentificationTypes();
  }

  @override
  Future<Map<String, dynamic>> createPatient({
    required String nombre,
    required String apellido,
    required int tipoIdentificacionId,
    required String identificacion,
  }) async {
    return await _remoteDataSource.createPatient({
      'nombre': nombre,
      'apellido': apellido,
      'tipoIdentificacionId': tipoIdentificacionId,
      'identificacion': identificacion,
    });
  }
}
