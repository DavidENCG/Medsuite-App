import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/registration_request_model.dart';
import '../../../domain/entities/identification_type.dart';
import '../../../domain/entities/registration_role.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final AuthRepository _authRepository;

  RegistrationBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(RegistrationState()) {
    on<LoadIdentificationTypes>(_onLoadIdentificationTypes);
    on<UpdatePersonalData>(_onUpdatePersonalData);
    on<ValidateAndNext>(_onValidateAndNext);
    on<LoadRoles>(_onLoadRoles);
    on<SelectRole>(_onSelectRole);
    on<FinalizeRegistration>(_onFinalizeRegistration);
    on<PreviousStep>(_onPreviousStep);
  }

  Future<void> _onLoadIdentificationTypes(
    LoadIdentificationTypes event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(status: RegistrationStatus.loading));
    try {
      final types = await _authRepository.getIdentificationTypes();
      emit(state.copyWith(
        status: RegistrationStatus.initial,
        identificationTypes: types,
        tipoIdentificacionId: types.isNotEmpty ? types.first.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RegistrationStatus.failure,
        errorMessage: 'Error al cargar tipos de identificación',
      ));
    }
  }

  void _onUpdatePersonalData(
    UpdatePersonalData event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(
      nombre: event.nombre,
      apellido: event.apellido,
      tipoIdentificacionId: event.tipoIdentificacionId,
      identificacion: event.identificacion,
      email: event.email,
      telefono: event.telefono,
      password: event.password,
    ));
  }

  Future<void> _onValidateAndNext(
    ValidateAndNext event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.tipoIdentificacionId == null) {
      emit(state.copyWith(status: RegistrationStatus.failure, errorMessage: 'Seleccione un tipo de identificación'));
      return;
    }

    emit(state.copyWith(status: RegistrationStatus.validating, currentStep: 1));
    try {
      final validation = await _authRepository.validateRegistration(
        tipoIdentificacionId: state.tipoIdentificacionId!,
        identificacion: state.identificacion,
        email: state.email,
      );

      if (validation.existe) {
        emit(state.copyWith(
          status: RegistrationStatus.failure,
          currentStep: 0,
          errorMessage: 'Esta identificación ya está registrada',
        ));
      } else if (validation.emailExiste) {
        emit(state.copyWith(
          status: RegistrationStatus.failure,
          currentStep: 0,
          errorMessage: 'Este correo ya está en uso',
        ));
      } else {
        // Todo OK, avanzar a roles
        add(LoadRoles());
      }
    } catch (e) {
      print('DEBUG: Error en validación de registro: $e');
      emit(state.copyWith(
        status: RegistrationStatus.failure,
        currentStep: 0,
        errorMessage: 'Error al validar datos',
      ));
    }
  }

  Future<void> _onLoadRoles(
    LoadRoles event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(status: RegistrationStatus.loading));
    try {
      final roles = await _authRepository.getRegistrationRoles();
      emit(state.copyWith(
        status: RegistrationStatus.initial,
        currentStep: 2, // Pantalla de Roles (Paso 3, índice 2)
        roles: roles,
      ));
    } catch (e) {
      print('DEBUG: Error al cargar roles de registro: $e');
      emit(state.copyWith(
        status: RegistrationStatus.failure,
        errorMessage: 'Error al cargar roles',
      ));
    }
  }

  void _onSelectRole(
    SelectRole event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(rolId: event.roleId));
  }

  Future<void> _onFinalizeRegistration(
    FinalizeRegistration event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.rolId == null) {
      emit(state.copyWith(status: RegistrationStatus.failure, errorMessage: 'Seleccione un perfil'));
      return;
    }

    emit(state.copyWith(status: RegistrationStatus.loading));
    try {
      final request = RegistrationRequest(
        nombre: state.nombre,
        apellido: state.apellido,
        tipoIdentificacionId: state.tipoIdentificacionId!,
        identificacion: state.identificacion,
        email: state.email,
        telefono: state.telefono,
        password: state.password,
        rolId: state.rolId!,
      );

      await _authRepository.register(request);
      
      // Intentar enviar correo de bienvenida después del registro exitoso
      try {
        await _authRepository.sendWelcomeEmail(
          email: state.email,
          nombre: '${state.nombre} ${state.apellido}',
          usuario: state.email, // Asumimos el email como usuario por ahora
          password: state.password,
        );
      } catch (e) {
        print('DEBUG: Error al enviar correo de bienvenida: $e');
        // No bloqueamos el éxito del registro si el correo falla
      }

      emit(state.copyWith(status: RegistrationStatus.success, currentStep: 3));
    } catch (e) {
      emit(state.copyWith(
        status: RegistrationStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onPreviousStep(
    PreviousStep event,
    Emitter<RegistrationState> emit,
  ) {
    if (state.currentStep == 2) {
      // Si estamos en roles (Paso 3, index 2), volver directamente al formulario (Paso 1, index 0)
      // saltando la pantalla de carga de validación.
      emit(state.copyWith(currentStep: 0, status: RegistrationStatus.initial));
    } else if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1, status: RegistrationStatus.initial));
    }
  }
}
