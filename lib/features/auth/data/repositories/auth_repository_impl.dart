import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../appointments/data/models/clinic_model.dart';
import '../../../appointments/domain/entities/clinic.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../../../appointments/data/datasources/clinic_datasource.dart';
import '../models/auth_response_model.dart';

import '../../domain/entities/identification_type.dart';
import '../../domain/entities/registration_role.dart';
import '../../domain/entities/registration_validation.dart';
import '../models/registration_request_model.dart';

import '../../domain/entities/location.dart';
import '../models/clinic_creation_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _remoteDataSource;
  final ClinicDataSource _clinicDataSource;
  final FlutterSecureStorage _storage;

  AuthRepositoryImpl({
    required AuthDataSource remoteDataSource,
    required ClinicDataSource clinicDataSource,
    required FlutterSecureStorage storage,
  })  : _remoteDataSource = remoteDataSource,
        _clinicDataSource = clinicDataSource,
        _storage = storage;

  @override
  Future<List<Clinic>> getClinics(String token) async {
    return await _clinicDataSource.getMyClinics(token);
  }

  @override
  Future<UserSession> login(String email, String password) async {
    final session = await _remoteDataSource.login(email, password);
    await _saveSession(session);
    return session;
  }

  @override
  Future<UserSession> selectRole({
    required int userId,
    required int roleId,
    required String tokenTemporal,
  }) async {
    final session = await _remoteDataSource.selectRole(
      userId: userId,
      roleId: roleId,
      tokenTemporal: tokenTemporal,
    );
    await _saveSession(session);
    return session;
  }

  @override
  Future<UserSession> selectClinic({
    required int userId,
    required int roleId,
    required int? clinicId,
    required String tokenTemporal,
  }) async {
    final session = await _remoteDataSource.selectClinic(
      userId: userId,
      roleId: roleId,
      clinicId: clinicId,
      tokenTemporal: tokenTemporal,
    );

    // Si la respuesta no trae el ID del consultorio, le inyectamos el que acabamos de elegir
    // para asegurar que la persistencia lo guarde correctamente.
    final sessionWithId = UserSession(
      userId: session.userId ?? userId,
      roleId: session.roleId ?? roleId,
      activeClinicId: session.activeClinicId ?? clinicId,
      fullName: session.fullName,
      activeClinicName: session.activeClinicName,
      token: session.token,
      tokenTemporal: session.tokenTemporal,
      needsClinic: session.needsClinic,
      needsRole: session.needsRole,
      roles: session.roles,
      clinics: session.clinics,
    );

    await _saveSession(sessionWithId);
    return sessionWithId;
  }

  Future<void> _saveSession(UserSession session) async {
    if (session.token != null) {
      await _storage.write(key: 'access_token', value: session.token);
      if (session.userId != null) await _storage.write(key: 'user_id', value: session.userId.toString());
      if (session.roleId != null) await _storage.write(key: 'role_id', value: session.roleId.toString());
      if (session.activeClinicId != null) await _storage.write(key: 'clinic_id', value: session.activeClinicId.toString());
      if (session.fullName != null) await _storage.write(key: 'full_name', value: session.fullName);
      if (session.activeClinicName != null) await _storage.write(key: 'clinic_name', value: session.activeClinicName);
      
      if (session.clinics != null && session.clinics!.isNotEmpty) {
        final List<Map<String, dynamic>> jsonList = session.clinics!.map((e) {
          return {
            'id': e.id,
            'nombre': e.nombre,
            'direccion': e.direccion,
            'ciudad': e.ciudad,
          };
        }).toList();
        await _storage.write(key: 'clinics_list', value: json.encode(jsonList));
      }
    }
  }

  @override
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  @override
  Future<UserSession> getStoredSession() async {
    final token = await _storage.read(key: 'access_token');
    final userId = await _storage.read(key: 'user_id');
    final roleId = await _storage.read(key: 'role_id');
    final clinicId = await _storage.read(key: 'clinic_id');
    final fullName = await _storage.read(key: 'full_name');
    final clinicName = await _storage.read(key: 'clinic_name');
    final clinicsJson = await _storage.read(key: 'clinics_list');

    List<Clinic>? clinics;
    if (clinicsJson != null) {
      try {
        final List decoded = json.decode(clinicsJson);
        clinics = decoded.map((e) => ClinicModel.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }

    return UserSession(
      token: token,
      userId: userId != null ? int.tryParse(userId) : null,
      roleId: roleId != null ? int.tryParse(roleId) : null,
      activeClinicId: clinicId != null ? int.tryParse(clinicId) : null,
      fullName: fullName,
      activeClinicName: clinicName,
      clinics: clinics,
    );
  }

  @override
  Future<bool> checkSubscription() async {
    // TODO: Connect to /api/Cuenta/perfil or /Suscripcion endpoint
    // For now, simulate a valid subscription check (true = active, false = blocked)
    await Future.delayed(const Duration(milliseconds: 500));
    return true; 
  }

  @override
  Future<List<IdentificationType>> getIdentificationTypes() async {
    return await _remoteDataSource.getIdentificationTypes();
  }

  @override
  Future<RegistrationValidation> validateRegistration({
    required int tipoIdentificacionId,
    required String identificacion,
    required String email,
  }) async {
    return await _remoteDataSource.validateRegistration(
      tipoIdentificacionId: tipoIdentificacionId,
      identificacion: identificacion,
      email: email,
    );
  }

  @override
  Future<List<RegistrationRole>> getRegistrationRoles() async {
    return await _remoteDataSource.getRegistrationRoles();
  }

  @override
  Future<void> register(RegistrationRequest request) async {
    return await _remoteDataSource.register(request);
  }

  @override
  Future<void> sendWelcomeEmail({
    required String email,
    required String nombre,
    required String usuario,
    required String password,
  }) async {
    return await _remoteDataSource.sendWelcomeEmail(
      email: email,
      nombre: nombre,
      usuario: usuario,
      password: password,
    );
  }

  @override
  Future<List<Country>> getCountries() async {
    return await _remoteDataSource.getCountries();
  }

  @override
  Future<List<City>> getCitiesByCountry(int countryId) async {
    return await _remoteDataSource.getCitiesByCountry(countryId);
  }

  @override
  Future<UserSession> createClinic(ClinicCreationRequest request) async {
    final session = await _remoteDataSource.createClinic(request);
    await _saveSession(session);
    return session;
  }
}
