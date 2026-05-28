import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/medical_history.dart';
import '../../domain/repositories/medical_history_repository.dart';

// Events
abstract class MedicalHistoryEvent extends Equatable {
  const MedicalHistoryEvent();
  @override
  List<Object?> get props => [];
}

class FetchMedicalHistory extends MedicalHistoryEvent {
  final int patientId;
  const FetchMedicalHistory(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class UpdateBasicDataRequested extends MedicalHistoryEvent {
  final int historyId;
  final Map<String, dynamic> data;
  const UpdateBasicDataRequested({required this.historyId, required this.data});
  @override
  List<Object?> get props => [historyId, data];
}

class AddAntecedentRequested extends MedicalHistoryEvent {
  final int historyId;
  final String category;
  final Map<String, dynamic> data;
  const AddAntecedentRequested({
    required this.historyId, 
    required this.category, 
    required this.data
  });
  @override
  List<Object?> get props => [historyId, category, data];
}

// States
abstract class MedicalHistoryState extends Equatable {
  const MedicalHistoryState();
  @override
  List<Object?> get props => [];
}

class MedicalHistoryInitial extends MedicalHistoryState {}
class MedicalHistoryLoading extends MedicalHistoryState {}
class MedicalHistoryLoaded extends MedicalHistoryState {
  final FullMedicalHistory history;
  const MedicalHistoryLoaded(this.history);
  @override
  List<Object?> get props => [history];
}
class MedicalHistoryUpdateSuccess extends MedicalHistoryState {}
class MedicalHistoryAddSuccess extends MedicalHistoryState {}
class MedicalHistoryError extends MedicalHistoryState {
  final String message;
  const MedicalHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class MedicalHistoryBloc extends Bloc<MedicalHistoryEvent, MedicalHistoryState> {
  final MedicalHistoryRepository _repository;

  MedicalHistoryBloc({required MedicalHistoryRepository repository})
      : _repository = repository,
        super(MedicalHistoryInitial()) {
    on<FetchMedicalHistory>(_onFetchMedicalHistory);
    on<UpdateBasicDataRequested>(_onUpdateBasicData);
    on<AddAntecedentRequested>(_onAddAntecedent);
  }

  Future<void> _onFetchMedicalHistory(FetchMedicalHistory event, Emitter<MedicalHistoryState> emit) async {
    emit(MedicalHistoryLoading());
    try {
      final history = await _repository.getHistoryByPatientId(event.patientId);
      emit(MedicalHistoryLoaded(history));
    } catch (e) {
      emit(MedicalHistoryError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onUpdateBasicData(UpdateBasicDataRequested event, Emitter<MedicalHistoryState> emit) async {
    emit(MedicalHistoryLoading());
    try {
      final success = await _repository.updateBasicData(event.historyId, event.data);
      if (success) {
        emit(MedicalHistoryUpdateSuccess());
      } else {
        emit(const MedicalHistoryError('No se pudieron actualizar los datos básicos'));
      }
    } catch (e) {
      emit(MedicalHistoryError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAddAntecedent(AddAntecedentRequested event, Emitter<MedicalHistoryState> emit) async {
    emit(MedicalHistoryLoading());
    try {
      final success = await _repository.addAntecedent(event.historyId, event.category, event.data);
      if (success) {
        emit(MedicalHistoryAddSuccess());
      } else {
        emit(const MedicalHistoryError('No se pudo guardar el registro clínico'));
      }
    } catch (e) {
      emit(MedicalHistoryError(_extractErrorMessage(e)));
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        return data['message'] ?? data['Mensaje'] ?? 'Error clínico en el servidor';
      }
    }
    return 'Error de conexión con el servidor médico';
  }
}
