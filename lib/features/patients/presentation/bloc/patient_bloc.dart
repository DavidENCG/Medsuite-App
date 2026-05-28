import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';

// Events
abstract class PatientEvent extends Equatable {
  const PatientEvent();
  @override
  List<Object?> get props => [];
}

class FetchMyPatients extends PatientEvent {}

class SearchPatientsQuery extends PatientEvent {
  final String query;
  const SearchPatientsQuery(this.query);
  @override
  List<Object?> get props => [query];
}

// States
abstract class PatientState extends Equatable {
  const PatientState();
  @override
  List<Object?> get props => [];
}

class PatientsInitial extends PatientState {}
class PatientsLoading extends PatientState {}
class PatientsLoaded extends PatientState {
  final List<Patient> patients;
  final int totalCount;
  final bool isOffline;
  const PatientsLoaded({required this.patients, required this.totalCount, this.isOffline = false});
  @override
  List<Object?> get props => [patients, totalCount, isOffline];
}

class PatientSearchEmpty extends PatientState {}
class PatientsError extends PatientState {
  final String message;
  const PatientsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository _repository;

  PatientBloc({required PatientRepository repository})
      : _repository = repository,
        super(PatientsInitial()) {
    on<FetchMyPatients>(_onFetchMyPatients);
    on<SearchPatientsQuery>(_onSearchPatientsQuery);
  }

  Future<void> _onFetchMyPatients(FetchMyPatients event, Emitter<PatientState> emit) async {
    emit(PatientsLoading());
    try {
      final (patients, count) = await _repository.getMyPatients();
      final isOnline = await _repository.checkConnectivity();
      emit(PatientsLoaded(patients: patients, totalCount: count, isOffline: !isOnline));
    } catch (e) {
      emit(PatientsError(e.toString()));
    }
  }

  Future<void> _onSearchPatientsQuery(SearchPatientsQuery event, Emitter<PatientState> emit) async {
    if (event.query.isEmpty) {
      add(FetchMyPatients());
      return;
    }

    emit(PatientsLoading());
    try {
      final (patients, count) = await _repository.searchPatients(event.query);
      if (patients.isEmpty) {
        emit(PatientSearchEmpty());
      } else {
        final isOnline = await _repository.checkConnectivity();
        emit(PatientsLoaded(patients: patients, totalCount: count, isOffline: !isOnline));
      }
    } catch (e) {
      emit(PatientsError(e.toString()));
    }
  }
}
