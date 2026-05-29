import '../datasources/consultation_remote_data_source.dart';
import '../../domain/entities/consultation_detail.dart';
import '../../domain/entities/consultation_catalog.dart';
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
  Future<ConsultationCatalog> getCatalogs() async {
    return await _remoteDataSource.getCatalogs();
  }

  @override
  Future<List<int>> downloadPrescription(int citaId) async {
    return await _remoteDataSource.downloadPrescription(citaId);
  }

  @override
  Future<List<int>> downloadReport(int citaId, Map<String, bool> sections) async {
    return await _remoteDataSource.downloadReport(citaId, sections);
  }

  @override
  Future<ConsultationDetail?> saveConsultation(ConsultationDetail consultation) async {
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
        sintomasPrincipales: consultation.enfermedadActual.sintomasPrincipales,
      ),
      examenFisico: PhysicalExamModel(
        cabezaCuello: consultation.examenFisico.cabezaCuello,
        torax: consultation.examenFisico.torax,
        abdomen: consultation.examenFisico.abdomen,
        extremidades: consultation.examenFisico.extremidades,
        neurologico: consultation.examenFisico.neurologico,
        piel: consultation.examenFisico.piel,
        genitourinario: consultation.examenFisico.genitourinario,
        observaciones: consultation.examenFisico.observaciones,
      ),
      diagnostico: ClinicalSectionModel(
        descripcion: consultation.diagnostico.descripcion,
        codigoCIE10: consultation.diagnostico.codigoCIE10,
      ),
      indicaciones: consultation.indicaciones.map((e) => IndicationItemModel(
        medicamento: e.medicamento,
        dosis: e.dosis,
        frecuencia: e.frecuencia,
        viaAdministracion: e.viaAdministracion,
        duracionDias: e.duracionDias,
        indicaciones: e.indicaciones,
        fechaInicio: e.fechaInicio,
      )).toList(),
      examenesSolicitados: consultation.examenesSolicitados.map((e) => ExamRequestItemModel(
        nombreExamen: e.nombreExamen,
        tipoExamen: e.tipoExamen,
        indicaciones: e.indicaciones,
      )).toList(),
      receta: PrescriptionModel(
        descripcion: consultation.receta.descripcion,
        indicaciones: consultation.receta.indicaciones,
        fechaEmision: consultation.receta.fechaEmision,
        fechaVencimiento: consultation.receta.fechaVencimiento,
      ),
      informe: MedicalReportModel(
        titulo: consultation.informe.titulo,
        resumen: consultation.informe.resumen,
        conclusiones: consultation.informe.conclusiones,
        recomendaciones: consultation.informe.recomendaciones,
        fechaInforme: consultation.informe.fechaInforme,
        adjuntoUrl: consultation.informe.adjuntoUrl,
      ),
    );
    return await _remoteDataSource.saveConsultation(model);
  }
}
