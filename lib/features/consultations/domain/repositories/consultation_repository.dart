import '../entities/consultation_detail.dart';
import '../entities/consultation_catalog.dart';

abstract class ConsultationRepository {
  Future<ConsultationDetail> getConsultation(int citaId);
  Future<ConsultationDetail?> saveConsultation(ConsultationDetail consultation);
  Future<ConsultationCatalog> getCatalogs();
  Future<List<int>> downloadPrescription(int citaId);
  Future<List<int>> downloadReport(int citaId, Map<String, bool> sections);
}
