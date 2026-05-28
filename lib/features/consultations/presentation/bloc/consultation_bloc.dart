import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/consultation_detail.dart';
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

// States
abstract class ConsultationState extends Equatable {
  const ConsultationState();
  @override
  List<Object?> get props => [];
}

class ConsultationInitial extends ConsultationState {}
class ConsultationLoading extends ConsultationState {}
class ConsultationLoaded extends ConsultationState {
  final ConsultationDetail detail;
  const ConsultationLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}
class ConsultationSaveSuccess extends ConsultationState {}
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

  ConsultationBloc({
    required ConsultationRepository repository,
    required AppointmentRepository appointmentRepository,
  })  : _repository = repository,
        _appointmentRepository = appointmentRepository,
        super(ConsultationInitial()) {
    on<FetchConsultationDetail>(_onFetchDetail);
    on<SaveConsultationRequested>(_onSaveRequested);
  }

  Future<void> _onFetchDetail(FetchConsultationDetail event, Emitter<ConsultationState> emit) async {
    emit(ConsultationLoading());
    try {
      final detail = await _repository.getConsultation(event.citaId);
      emit(ConsultationLoaded(detail));
    } catch (e) {
      emit(ConsultationError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onSaveRequested(SaveConsultationRequested event, Emitter<ConsultationState> emit) async {
    emit(ConsultationLoading());
    try {
      final success = await _repository.saveConsultation(event.consultation);
      if (success) {
        // Cierre del ciclo: Marcar como Atendido (nuevoEstadoId: 2)
        await _appointmentRepository.updateAppointmentStatus(event.consultation.citaId, 2, notas: 'Consulta completada');
        emit(ConsultationSaveSuccess());
      } else {
        emit(const ConsultationError('No se pudo guardar la consulta'));
      }
    } catch (e) {
      emit(ConsultationError(_extractErrorMessage(e)));
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        return data['message'] ?? data['Mensaje'] ?? 'Error en el servidor de consultas';
      }
    }
    return e.toString();
  }
}
