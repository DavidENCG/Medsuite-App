import '../entities/consultation_detail.dart';

abstract class ConsultationRepository {
  Future<ConsultationDetail> getConsultation(int citaId);
  Future<bool> saveConsultation(ConsultationDetail consultation);
}
