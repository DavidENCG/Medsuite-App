import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/privacy_repository.dart';

// Events
abstract class PrivacyEvent extends Equatable {
  const PrivacyEvent();
  @override
  List<Object?> get props => [];
}

class GenerateConsentQr extends PrivacyEvent {}
class ScanQrCode extends PrivacyEvent {
  final String qrToken;
  const ScanQrCode(this.qrToken);
  @override
  List<Object?> get props => [qrToken];
}
class ResetAccessState extends PrivacyEvent {}

// States
abstract class PrivacyState extends Equatable {
  const PrivacyState();
  @override
  List<Object?> get props => [];
}

class PrivacyInitial extends PrivacyState {}
class QrGenerated extends PrivacyState {
  final String token;
  const QrGenerated(this.token);
  @override
  List<Object?> get props => [token];
}
class ScanningActive extends PrivacyState {}
class AuthorizingAccess extends PrivacyState {}
class AccessAuthorized extends PrivacyState {
  final Patient patientProfile;
  const AccessAuthorized(this.patientProfile);
  @override
  List<Object?> get props => [patientProfile];
}
class AccessDenied extends PrivacyState {
  final String message;
  const AccessDenied(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class PrivacyBloc extends Bloc<PrivacyEvent, PrivacyState> {
  final PrivacyRepository _repository;

  PrivacyBloc({required PrivacyRepository repository})
      : _repository = repository,
        super(PrivacyInitial()) {
    on<GenerateConsentQr>(_onGenerateConsentQr);
    on<ScanQrCode>(_onScanQrCode);
    on<ResetAccessState>(_onResetAccessState);
  }

  Future<void> _onGenerateConsentQr(GenerateConsentQr event, Emitter<PrivacyState> emit) async {
    emit(AuthorizingAccess()); // Reusing state for loading
    try {
      final token = await _repository.generateConsentToken();
      if (token != null) {
        emit(QrGenerated(token));
      } else {
        emit(const AccessDenied('No se pudo generar el código QR'));
      }
    } catch (e) {
      emit(AccessDenied(e.toString()));
    }
  }

  Future<void> _onScanQrCode(ScanQrCode event, Emitter<PrivacyState> emit) async {
    emit(AuthorizingAccess());
    try {
      final patient = await _repository.authorizeQr(event.qrToken);
      emit(AccessAuthorized(patient));
    } catch (e) {
      emit(AccessDenied(e.toString()));
    }
  }

  void _onResetAccessState(ResetAccessState event, Emitter<PrivacyState> emit) {
    emit(PrivacyInitial());
  }
}
