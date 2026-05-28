import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_case.dart';
import '../../domain/entities/case_detail.dart';
import '../../domain/repositories/case_repository.dart';

// Events
abstract class CaseEvent extends Equatable {
  const CaseEvent();
  @override
  List<Object?> get props => [];
}

class FetchPatientCases extends CaseEvent {
  final int patientId;
  const FetchPatientCases(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class CreateCaseRequested extends CaseEvent {
  final Map<String, dynamic> data;
  const CreateCaseRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class FetchCaseDetail extends CaseEvent {
  final int caseId;
  const FetchCaseDetail(this.caseId);
  @override
  List<Object?> get props => [caseId];
}

class ScheduleAppointmentRequested extends CaseEvent {
  final Map<String, dynamic> data;
  final int caseId;
  const ScheduleAppointmentRequested(this.data, this.caseId);
  @override
  List<Object?> get props => [data, caseId];
}

// States
abstract class CaseState extends Equatable {
  const CaseState();
  @override
  List<Object?> get props => [];
}

class CaseInitial extends CaseState {}
class CaseLoading extends CaseState {}
class CasesLoaded extends CaseState {
  final List<MedicalCase> cases;
  const CasesLoaded(this.cases);
  @override
  List<Object?> get props => [cases];
}
class CaseDetailLoaded extends CaseState {
  final CaseDetail caseDetail;
  const CaseDetailLoaded(this.caseDetail);
  @override
  List<Object?> get props => [caseDetail];
}
class CaseCreateSuccess extends CaseState {}
class AppointmentScheduleSuccess extends CaseState {}
class CaseError extends CaseState {
  final String message;
  const CaseError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class CaseBloc extends Bloc<CaseEvent, CaseState> {
  final CaseRepository _repository;

  CaseBloc({required CaseRepository repository})
      : _repository = repository,
        super(CaseInitial()) {
    on<FetchPatientCases>(_onFetchPatientCases);
    on<CreateCaseRequested>(_onCreateCaseRequested);
    on<FetchCaseDetail>(_onFetchCaseDetail);
    on<ScheduleAppointmentRequested>(_onScheduleAppointmentRequested);
  }

  Future<void> _onFetchPatientCases(FetchPatientCases event, Emitter<CaseState> emit) async {
    emit(CaseLoading());
    try {
      final cases = await _repository.getPatientCases(event.patientId);
      emit(CasesLoaded(cases));
    } catch (e) {
      emit(CaseError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onCreateCaseRequested(CreateCaseRequested event, Emitter<CaseState> emit) async {
    emit(CaseLoading());
    try {
      final success = await _repository.createCase(event.data);
      if (success) {
        emit(CaseCreateSuccess());
      } else {
        emit(const CaseError('No se pudo crear el caso médico. Verifica los datos.'));
      }
    } catch (e) {
      emit(CaseError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onFetchCaseDetail(FetchCaseDetail event, Emitter<CaseState> emit) async {
    emit(CaseLoading());
    try {
      final caseDetail = await _repository.getCaseById(event.caseId);
      emit(CaseDetailLoaded(caseDetail));
    } catch (e) {
      emit(CaseError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onScheduleAppointmentRequested(ScheduleAppointmentRequested event, Emitter<CaseState> emit) async {
    emit(CaseLoading());
    try {
      final success = await _repository.scheduleAppointment(event.data);
      if (success) {
        emit(AppointmentScheduleSuccess());
        // Auto-refresh the case detail
        add(FetchCaseDetail(event.caseId));
      } else {
        emit(const CaseError('No se pudo agendar la cita.'));
      }
    } catch (e) {
      emit(CaseError(_extractErrorMessage(e)));
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        return data['message'] ?? data['Mensaje'] ?? 'Error de validación en el servidor';
      }
    }
    return 'Error de comunicación con el servidor';
  }
}
