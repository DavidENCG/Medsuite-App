import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:medsuite_cmo/features/auth/data/models/auth_response_model.dart';
import '../../../appointments/domain/entities/clinic.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  // State variables for multi-step auth
  int? _userId;
  int? _roleId;
  int? _activeClinicId;
  String? _fullName;
  String? _activeClinicName;
  String? _tokenTemporal;
  List<Clinic> _clinics = [];

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RoleSelected>(_onRoleSelected);
    on<ClinicSelected>(_onClinicSelected);
    on<LogoutRequested>(_onLogoutRequested);

    // Iniciamos la validación automáticamente al crear el Bloc
    add(AuthCheckRequested());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final session = await _authRepository.getStoredSession().timeout(
        const Duration(seconds: 5),
        onTimeout: () => const UserSession(),
      );
      
      if (session.token != null) {
        final isSubActive = await _authRepository.checkSubscription().timeout(
          const Duration(seconds: 5),
          onTimeout: () => false,
        );
        if (isSubActive) {
          _userId = session.userId;
          _roleId = session.roleId;
          _activeClinicId = session.activeClinicId;
          _fullName = session.fullName;
          _activeClinicName = session.activeClinicName;
          _clinics = session.clinics ?? [];
          
          // REINTENTO DE RECUPERACIÓN: Si tenemos ID pero no el nombre (común tras reinicio)
          if (_activeClinicName == null && _activeClinicId != null && _clinics.isNotEmpty) {
            try {
              final matched = _clinics.firstWhere((c) => c.id == _activeClinicId);
              _activeClinicName = matched.nombre;
            } catch (_) {}
          }
          
          emit(Authenticated(
            session.token!,
            fullName: _fullName,
            activeClinicName: _activeClinicName,
            activeClinicId: _activeClinicId,
            clinics: _clinics,
          ));
        } else {
          emit(AuthSubscriptionBlocked());
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final session = await _authRepository.login(event.email, event.password);
      
      // Si el login falló pero no lanzó excepción (ej: 401 manejado por validateStatus)
      if (session is AuthResponseModel && session.token == null && !session.needsRole && !session.needsClinic) {
        // Buscamos un mensaje amigable
        emit(const AuthFailure('Credenciales incorrectas o usuario no autorizado'));
        return;
      }
      
      await _handleSession(session, emit);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(AuthFailure(message));
    } catch (e) {
      emit(AuthFailure('Error de conexión: ${e.toString()}'));
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        return data['message'] ?? data['Mensaje'] ?? 'Error de autenticación';
      }
      if (e.type == DioExceptionType.connectionTimeout) return 'Tiempo de espera agotado';
    }
    return 'Error inesperado en el servidor';
  }

  Future<void> _onRoleSelected(
    RoleSelected event,
    Emitter<AuthState> emit,
  ) async {
    if (_userId == null || _tokenTemporal == null) {
      emit(const AuthFailure('Sesión inválida o expirada'));
      return;
    }

    emit(AuthLoading());
    try {
      _roleId = event.roleId;
      final session = await _authRepository.selectRole(
        userId: _userId!,
        roleId: _roleId!,
        tokenTemporal: _tokenTemporal!,
      );
      await _handleSession(session, emit);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al seleccionar rol';
      emit(AuthFailure(message.toString()));
    } catch (e) {
      emit(AuthFailure('Error de comunicación'));
    }
  }

  Future<void> _onClinicSelected(
    ClinicSelected event,
    Emitter<AuthState> emit,
  ) async {
    if (_userId == null || _roleId == null || _tokenTemporal == null) {
      emit(const AuthFailure('Sesión inválida o expirada'));
      return;
    }

    // Guardamos el nombre de la clínica seleccionada ANTES de la petición
    // por si la respuesta final de C# no lo incluye.
    try {
      final selected = _clinics.firstWhere((c) => c.id == event.clinicId);
      _activeClinicName = selected.nombre;
      _activeClinicId = selected.id;
    } catch (_) {}

    emit(AuthLoading());
    try {
      final session = await _authRepository.selectClinic(
        userId: _userId!,
        roleId: _roleId!,
        clinicId: event.clinicId,
        tokenTemporal: _tokenTemporal!,
      );
      
      // Aseguramos que el objeto session que pasamos a _handleSession 
      // mantenga la lista de clínicas que ya conocemos.
      final sessionWithContext = UserSession(
        userId: session.userId ?? _userId,
        roleId: session.roleId ?? _roleId,
        activeClinicId: session.activeClinicId ?? _activeClinicId,
        fullName: session.fullName ?? _fullName,
        activeClinicName: session.activeClinicName ?? _activeClinicName,
        token: session.token,
        tokenTemporal: session.tokenTemporal,
        needsClinic: session.needsClinic,
        needsRole: session.needsRole,
        roles: session.roles,
        clinics: session.clinics ?? _clinics, // CLAVE: No perder la lista
      );

      await _handleSession(sessionWithContext, emit);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al seleccionar consultorio';
      emit(AuthFailure(message.toString()));
    } catch (e) {
      emit(AuthFailure('Error de comunicación'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    _userId = null;
    _roleId = null;
    _activeClinicId = null;
    _fullName = null;
    _activeClinicName = null;
    _tokenTemporal = null;
    _clinics = [];
    emit(AuthUnauthenticated());
  }

  Future<void> _handleSession(UserSession session, Emitter<AuthState> emit) async {
    _userId = session.userId ?? _userId;
    _roleId = session.roleId ?? _roleId; 
    _activeClinicId = session.activeClinicId ?? _activeClinicId;
    _fullName = session.fullName ?? _fullName;
    _activeClinicName = session.activeClinicName ?? _activeClinicName;
    _tokenTemporal = session.tokenTemporal ?? _tokenTemporal;
    _clinics = (session.clinics != null && session.clinics!.isNotEmpty) 
        ? session.clinics! 
        : _clinics;

    print('--- AUTH DEBUG ---');
    print('Clinic Name: $_activeClinicName');
    print('Clinics Count: ${_clinics.length}');

    if (session.needsRole) {
      emit(AuthNeedsRole(session.roles ?? []));
    } else if (session.needsClinic) {
      List<Clinic> clinics = session.clinics ?? _clinics;
      
      if (clinics.isEmpty && _tokenTemporal != null) {
        try {
          clinics = await _authRepository.getClinics(_tokenTemporal!).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('La carga de consultorios tardó demasiado'),
          );
          _clinics = clinics;
        } catch (e) {
          emit(AuthFailure('Error al cargar consultorios: ${e.toString()}'));
          return;
        }
      }
      
      emit(AuthNeedsClinic(clinics));
    } else if (session.token != null) {
      emit(Authenticated(
        session.token!, 
        fullName: _fullName,
        activeClinicName: _activeClinicName,
        activeClinicId: _activeClinicId,
        clinics: _clinics,
      ));
    } else {
      emit(const AuthFailure('Respuesta de autenticación incompleta'));
    }
  }
}
