import '../datasources/medical_history_remote_data_source.dart';
import '../../domain/entities/medical_history.dart';
import '../../domain/repositories/medical_history_repository.dart';

class MedicalHistoryRepositoryImpl implements MedicalHistoryRepository {
  final MedicalHistoryRemoteDataSource _remoteDataSource;

  MedicalHistoryRepositoryImpl({required MedicalHistoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<FullMedicalHistory> getHistoryByPatientId(int patientId) async {
    return await _remoteDataSource.getHistoryByPatientId(patientId);
  }

  @override
  Future<bool> updateBasicData(int historyId, Map<String, dynamic> data) async {
    return await _remoteDataSource.updateBasicData(historyId, data);
  }

  @override
  Future<bool> addAntecedent(int historyId, String category, Map<String, dynamic> data) async {
    return await _remoteDataSource.addAntecedent(historyId, category, data);
  }
}
