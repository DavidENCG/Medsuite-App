import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medsuite_cmo/features/auth/domain/entities/identification_type.dart';
import '../../domain/repositories/patient_repository.dart';

// Events
abstract class RegisterPatientEvent extends Equatable {
  const RegisterPatientEvent();
  @override
  List<Object?> get props => [];
}

class LoadRegisterData extends RegisterPatientEvent {}

class SubmitPatientRegistration extends RegisterPatientEvent {
  final String nombre;
  final String apellido;
  final int tipoIdentificacionId;
  final String identificacion;

  const SubmitPatientRegistration({
    required this.nombre,
    required this.apellido,
    required this.tipoIdentificacionId,
    required this.identificacion,
  });

  @override
  List<Object?> get props => [nombre, apellido, tipoIdentificacionId, identificacion];
}

// States
abstract class RegisterPatientState extends Equatable {
  const RegisterPatientState();
  @override
  List<Object?> get props => [];
}

class RegisterPatientInitial extends RegisterPatientState {}

class RegisterPatientLoading extends RegisterPatientState {}

class RegisterPatientDataLoaded extends RegisterPatientState {
  final List<IdentificationType> idTypes;
  const RegisterPatientDataLoaded(this.idTypes);
  @override
  List<Object?> get props => [idTypes];
}

class RegisterPatientSubmitting extends RegisterPatientState {}

class RegisterPatientSuccess extends RegisterPatientState {
  final Map<String, dynamic> result;
  const RegisterPatientSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class RegisterPatientError extends RegisterPatientState {
  final String message;
  const RegisterPatientError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class RegisterPatientBloc extends Bloc<RegisterPatientEvent, RegisterPatientState> {
  final PatientRepository _repository;

  RegisterPatientBloc({required PatientRepository repository})
      : _repository = repository,
        super(RegisterPatientInitial()) {
    on<LoadRegisterData>(_onLoadRegisterData);
    on<SubmitPatientRegistration>(_onSubmitPatientRegistration);
  }

  Future<void> _onLoadRegisterData(
    LoadRegisterData event,
    Emitter<RegisterPatientState> emit,
  ) async {
    emit(RegisterPatientLoading());
    try {
      final idTypes = await _repository.getIdentificationTypes();
      emit(RegisterPatientDataLoaded(idTypes));
    } catch (e) {
      emit(RegisterPatientError(e.toString()));
    }
  }

  Future<void> _onSubmitPatientRegistration(
    SubmitPatientRegistration event,
    Emitter<RegisterPatientState> emit,
  ) async {
    emit(RegisterPatientSubmitting());
    try {
      final result = await _repository.createPatient(
        nombre: event.nombre,
        apellido: event.apellido,
        tipoIdentificacionId: event.tipoIdentificacionId,
        identificacion: event.identificacion,
      );
      emit(RegisterPatientSuccess(result));
    } catch (e) {
      emit(RegisterPatientError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
