import '../datasources/case_remote_data_source.dart';
import '../../domain/entities/medical_case.dart';
import '../../domain/entities/case_detail.dart';
import '../../domain/repositories/case_repository.dart';

class CaseRepositoryImpl implements CaseRepository {
  final CaseRemoteDataSource _remoteDataSource;

  CaseRepositoryImpl({required CaseRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<MedicalCase>> getPatientCases(int patientId) async {
    return await _remoteDataSource.getPatientCases(patientId);
  }

  @override
  Future<bool> createCase(Map<String, dynamic> data) async {
    return await _remoteDataSource.createCase(data);
  }

  @override
  Future<CaseDetail> getCaseById(int caseId) async {
    return await _remoteDataSource.getCaseById(caseId);
  }

  @override
  Future<bool> scheduleAppointment(Map<String, dynamic> data) async {
    return await _remoteDataSource.scheduleAppointment(data);
  }
}
