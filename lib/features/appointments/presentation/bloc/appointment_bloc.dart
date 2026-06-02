import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

// Events
abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();
  @override
  List<Object?> get props => [];
}

class FetchDailyAppointments extends AppointmentEvent {}

class FetchAppointmentsByDate extends AppointmentEvent {
  final DateTime date;
  const FetchAppointmentsByDate(this.date);
  @override
  List<Object?> get props => [date];
}

class UpdateAppointmentStatus extends AppointmentEvent {
  final int citaId;
  final int nuevoEstadoId;
  final String? notas;

  const UpdateAppointmentStatus({
    required this.citaId,
    required this.nuevoEstadoId,
    this.notas,
  });

  @override
  List<Object?> get props => [citaId, nuevoEstadoId, notas];
}

class SyncOfflineChanges extends AppointmentEvent {}

// States
abstract class AppointmentState extends Equatable {
  const AppointmentState();
  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentState {}
class AppointmentsLoading extends AppointmentState {}
class AppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;
  final bool isOffline;
  final DateTime selectedDate;
  const AppointmentsLoaded({
    required this.appointments, 
    this.isOffline = false,
    required this.selectedDate,
  });
  @override
  List<Object?> get props => [appointments, isOffline, selectedDate];
}
class AppointmentsError extends AppointmentState {
  final String message;
  const AppointmentsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository _repository;

  AppointmentBloc({required AppointmentRepository repository})
      : _repository = repository,
        super(AppointmentsInitial()) {
    on<FetchDailyAppointments>(_onFetchDailyAppointments);
    on<FetchAppointmentsByDate>(_onFetchAppointmentsByDate);
    on<UpdateAppointmentStatus>(_onUpdateAppointmentStatus);
    on<SyncOfflineChanges>(_onSyncOfflineChanges);
  }

  Future<void> _onFetchDailyAppointments(
    FetchDailyAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    add(FetchAppointmentsByDate(DateTime.now()));
  }

  Future<void> _onFetchAppointmentsByDate(
    FetchAppointmentsByDate event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentsLoading());
    try {
      final appointments = await _repository.getAppointmentsByDate(event.date);
      final isOnline = await _repository.checkConnectivity();
      emit(AppointmentsLoaded(
        appointments: appointments, 
        isOffline: !isOnline,
        selectedDate: event.date,
      ));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  Future<void> _onUpdateAppointmentStatus(
    UpdateAppointmentStatus event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppointmentsLoaded) {
      try {
        final selectedDate = currentState.selectedDate;
        await _repository.updateAppointmentStatus(
          event.citaId,
          event.nuevoEstadoId,
          notas: event.notas,
        );
        // Refresh for the same date
        add(FetchAppointmentsByDate(selectedDate));
      } catch (e) {
        emit(AppointmentsError(e.toString()));
      }
    }
  }

  Future<void> _onSyncOfflineChanges(
    SyncOfflineChanges event,
    Emitter<AppointmentState> emit,
  ) async {
    await _repository.syncPendingChanges();
    final currentState = state;
    if (currentState is AppointmentsLoaded) {
      add(FetchAppointmentsByDate(currentState.selectedDate));
    } else {
      add(FetchDailyAppointments());
    }
  }
}
