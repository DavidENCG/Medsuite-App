import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/consultation_detail.dart';
import '../../domain/entities/consultation_catalog.dart';
import '../../domain/repositories/consultation_repository.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';

// Events
abstract class ConsultationEvent extends Equatable {
  const ConsultationEvent();
  @override
  List<Object?> get props => [];
}

class FetchConsultationDetail extends ConsultationEvent {
  final int citaId;
  const FetchConsultationDetail(this.citaId);
  @override
  List<Object?> get props => [citaId];
}

class SaveConsultationRequested extends ConsultationEvent {
  final ConsultationDetail consultation;
  const SaveConsultationRequested(this.consultation);
  @override
  List<Object?> get props => [consultation];
}

class DownloadPrescriptionRequested extends ConsultationEvent {
  final int citaId;
  const DownloadPrescriptionRequested(this.citaId);
  @override
  List<Object?> get props => [citaId];
}

class DownloadReportRequested extends ConsultationEvent {
  final int citaId;
  final Map<String, bool> sections;
  const DownloadReportRequested(this.citaId, this.sections);
  @override
  List<Object?> get props => [citaId, sections];
}

// States
abstract class ConsultationState extends Equatable {
  const ConsultationState();
  @override
  List<Object?> get props => [];
}

class ConsultationInitial extends ConsultationState {}
class ConsultationLoading extends ConsultationState {}
class ConsultationDownloading extends ConsultationState {}

class ConsultationLoaded extends ConsultationState {
  final ConsultationDetail detail;
  final ConsultationCatalog catalog;
  const ConsultationLoaded(this.detail, this.catalog);
  @override
  List<Object?> get props => [detail, catalog];
}

class ConsultationSaveSuccess extends ConsultationState {
  final ConsultationDetail updatedDetail;
  const ConsultationSaveSuccess(this.updatedDetail);
  @override
  List<Object?> get props => [updatedDetail];
}

class ConsultationDownloadSuccess extends ConsultationState {
  final List<int> bytes;
  final String fileName;
  const ConsultationDownloadSuccess(this.bytes, this.fileName);
  @override
  List<Object?> get props => [bytes, fileName];
}

class ConsultationError extends ConsultationState {
  final String message;
  const ConsultationError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ConsultationBloc extends Bloc<ConsultationEvent, ConsultationState> {
  final ConsultationRepository _repository;
  final AppointmentRepository _appointmentRepository;
  ConsultationCatalog? _cachedCatalog;

  ConsultationBloc({
    required ConsultationRepository repository,
    required AppointmentRepository appointmentRepository,
  })  : _repository = repository,
        _appointmentRepository = appointmentRepository,
        super(ConsultationInitial()) {
    on<FetchConsultationDetail>(_onFetchDetail);
    on<SaveConsultationRequested>(_onSaveRequested);
    on<DownloadPrescriptionRequested>(_onDownloadPrescription);
    on<DownloadReportRequested>(_onDownloadReport);
  }

  Future<void> _onFetchDetail(FetchConsultationDetail event, Emitter<ConsultationState> emit) async {
    emit(ConsultationLoading());
    try {
      final results = await Future.wait([
        _repository.getConsultation(event.citaId),
        _cachedCatalog != null ? Future.value(_cachedCatalog) : _repository.getCatalogs(),
      ]);

      final detail = results[0] as ConsultationDetail;
      _cachedCatalog = results[1] as ConsultationCatalog;

      emit(ConsultationLoaded(detail, _cachedCatalog!));
    } catch (e) {
      emit(ConsultationError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onSaveRequested(SaveConsultationRequested event, Emitter<ConsultationState> emit) async {
    try {
      final updated = await _repository.saveConsultation(event.consultation);
      final finalDetail = updated ?? await _repository.getConsultation(event.consultation.citaId);
      
      emit(ConsultationSaveSuccess(finalDetail));
      if (_cachedCatalog != null) {
        emit(ConsultationLoaded(finalDetail, _cachedCatalog!));
      }

      try {
        await _appointmentRepository.updateAppointmentStatus(event.consultation.citaId, 2, notas: 'Consulta sincronizada');
      } catch (_) {}
      
    } catch (e) {
      emit(ConsultationError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onDownloadPrescription(DownloadPrescriptionRequested event, Emitter<ConsultationState> emit) async {
    emit(ConsultationDownloading());
    try {
      final bytes = await _repository.downloadPrescription(event.citaId);
      emit(ConsultationDownloadSuccess(bytes, "Receta_${event.citaId}.pdf"));
    } catch (e) {
      emit(ConsultationError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onDownloadReport(DownloadReportRequested event, Emitter<ConsultationState> emit) async {
    emit(ConsultationDownloading());
    try {
      final bytes = await _repository.downloadReport(event.citaId, event.sections);
      emit(ConsultationDownloadSuccess(bytes, "Informe_${event.citaId}.pdf"));
    } catch (e) {
      emit(ConsultationError(_extractErrorMessage(e)));
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map) {
            return errors.values.map((v) => v.toString()).join('\n');
          }
          return errors.toString();
        }
        return data['message'] ?? data['Mensaje'] ?? data.toString();
      } else if (data != null) {
        return data.toString();
      }
      return 'Error HTTP: ${e.response?.statusCode}';
    }
    if (e is Exception) {
      final msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        return msg.replaceFirst('Exception: ', '');
      }
      return msg;
    }
    return e.toString();
  }
}
