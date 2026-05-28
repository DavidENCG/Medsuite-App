import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';

// Events
abstract class PatientDetailEvent extends Equatable {
  const PatientDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadPatientDetail extends PatientDetailEvent {
  final int patientId;
  const LoadPatientDetail(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class UpdatePatientDetail extends PatientDetailEvent {
  final int patientId;
  final Map<String, dynamic> data;
  const UpdatePatientDetail({required this.patientId, required this.data});
  @override
  List<Object?> get props => [patientId, data];
}

// States
abstract class PatientDetailState extends Equatable {
  const PatientDetailState();
  @override
  List<Object?> get props => [];
}

class PatientDetailInitial extends PatientDetailState {}
class PatientDetailLoading extends PatientDetailState {}
class PatientDetailLoaded extends PatientDetailState {
  final Patient patient;
  const PatientDetailLoaded(this.patient);
  @override
  List<Object?> get props => [patient];
}
class PatientDetailUpdateSuccess extends PatientDetailState {}
class PatientDetailError extends PatientDetailState {
  final String message;
  const PatientDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class PatientDetailBloc extends Bloc<PatientDetailEvent, PatientDetailState> {
  final PatientRepository _repository;

  PatientDetailBloc({required PatientRepository repository})
      : _repository = repository,
        super(PatientDetailInitial()) {
    on<LoadPatientDetail>(_onLoadPatientDetail);
    on<UpdatePatientDetail>(_onUpdatePatientDetail);
  }

  Future<void> _onLoadPatientDetail(LoadPatientDetail event, Emitter<PatientDetailState> emit) async {
    emit(PatientDetailLoading());
    try {
      final patient = await _repository.getPatientById(event.patientId);
      emit(PatientDetailLoaded(patient));
    } catch (e) {
      emit(PatientDetailError(e.toString()));
    }
  }

  Future<void> _onUpdatePatientDetail(UpdatePatientDetail event, Emitter<PatientDetailState> emit) async {
    emit(PatientDetailLoading());
    try {
      final success = await _repository.updatePatient(event.patientId, event.data);
      if (success) {
        emit(PatientDetailUpdateSuccess());
      } else {
        emit(const PatientDetailError('No se pudo actualizar la información'));
      }
    } catch (e) {
      emit(PatientDetailError(e.toString()));
    }
  }
}
