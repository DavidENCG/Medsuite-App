import '../datasources/consultation_remote_data_source.dart';
import '../../domain/entities/consultation_detail.dart';
import '../../domain/repositories/consultation_repository.dart';
import '../models/consultation_detail_model.dart';

class ConsultationRepositoryImpl implements ConsultationRepository {
  final ConsultationRemoteDataSource _remoteDataSource;

  ConsultationRepositoryImpl({required ConsultationRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<ConsultationDetail> getConsultation(int citaId) async {
    return await _remoteDataSource.getConsultation(citaId);
  }

  @override
  Future<bool> saveConsultation(ConsultationDetail consultation) async {
    // Convert entity strictly to model for serialization to avoid casting crashes
    final model = ConsultationDetailModel(
      citaId: consultation.citaId,
      signosVitales: VitalSignsModel(
        tensionArterial: consultation.signosVitales.tensionArterial,
        temperatura: consultation.signosVitales.temperatura,
        frecuenciaCardiaca: consultation.signosVitales.frecuenciaCardiaca,
        frecuenciaRespiratoria: consultation.signosVitales.frecuenciaRespiratoria,
        saturacionOxigeno: consultation.signosVitales.saturacionOxigeno,
        pesoKg: consultation.signosVitales.pesoKg,
        estaturaCm: consultation.signosVitales.estaturaCm,
      ),
      enfermedadActual: ClinicalSectionModel(
        descripcion: consultation.enfermedadActual.descripcion,
        codigoCIE10: consultation.enfermedadActual.codigoCIE10,
        medicamentos: consultation.enfermedadActual.medicamentos,
        indicaciones: consultation.enfermedadActual.indicaciones,
      ),
      examenFisico: ClinicalSectionModel(
        descripcion: consultation.examenFisico.descripcion,
        codigoCIE10: consultation.examenFisico.codigoCIE10,
        medicamentos: consultation.examenFisico.medicamentos,
        indicaciones: consultation.examenFisico.indicaciones,
      ),
      diagnostico: ClinicalSectionModel(
        descripcion: consultation.diagnostico.descripcion,
        codigoCIE10: consultation.diagnostico.codigoCIE10,
        medicamentos: consultation.diagnostico.medicamentos,
        indicaciones: consultation.diagnostico.indicaciones,
      ),
      receta: ClinicalSectionModel(
        descripcion: consultation.receta.descripcion,
        codigoCIE10: consultation.receta.codigoCIE10,
        medicamentos: consultation.receta.medicamentos,
        indicaciones: consultation.receta.indicaciones,
      ),
    );
    return await _remoteDataSource.saveConsultation(model);
  }
}
