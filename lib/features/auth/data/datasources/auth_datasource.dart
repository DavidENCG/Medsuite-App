import 'package:medsuite_cmo/core/network/api_client.dart';

import '../models/auth_response_model.dart';

import '../models/identification_type_model.dart';
import '../models/registration_role_model.dart';
import '../models/registration_validation_model.dart';
import '../models/registration_request_model.dart';
import '../models/location_model.dart';
import '../models/clinic_creation_request.dart';

abstract class AuthDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> selectRole({
    required int userId,
    required int roleId,
    required String tokenTemporal,
  });
  Future<AuthResponseModel> selectClinic({
    required int userId,
    required int roleId,
    required int? clinicId,
    required String tokenTemporal,
  });

  // Registro
  Future<List<IdentificationTypeModel>> getIdentificationTypes();
  Future<RegistrationValidationModel> validateRegistration({
    required int tipoIdentificacionId,
    required String identificacion,
    required String email,
  });
  Future<List<RegistrationRoleModel>> getRegistrationRoles();
  Future<void> register(RegistrationRequest request);
  Future<void> sendWelcomeEmail({
    required String email,
    required String nombre,
    required String usuario,
    required String password,
  });

  // Creación de Consultorio
  Future<List<CountryModel>> getCountries();
  Future<List<CityModel>> getCitiesByCountry(int countryId);
  Future<AuthResponseModel> createClinic(ClinicCreationRequest request);
}

class AuthDataSourceImpl implements AuthDataSource {
  final ApiClient _apiClient;

  AuthDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _apiClient.post(
      '/api/Auth/login',
      data: {
        'NombreUsuario': email,
        'Contraseña': password,
      },
    );
    
    if (response.data is! Map) {
      throw Exception('El servidor no devolvió una respuesta válida');
    }
    
    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> selectRole({
    required int userId,
    required int roleId,
    required String tokenTemporal,
  }) async {
    final response = await _apiClient.post(
      '/api/Auth/select-role',
      data: {
        'UsuarioId': userId,
        'RolId': roleId,
        'TokenTemporal': tokenTemporal,
      },
    );

    if (response.data is! Map) {
      throw Exception('Error al seleccionar rol');
    }

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> selectClinic({
    required int userId,
    required int roleId,
    required int? clinicId,
    required String tokenTemporal,
  }) async {
    final response = await _apiClient.post(
      '/api/Auth/select-clinic',
      data: {
        'UsuarioId': userId,
        'RolId': roleId,
        'ConsultorioId': clinicId,
        'TokenTemporal': tokenTemporal,
      },
    );

    if (response.data is! Map) {
      throw Exception('Error al seleccionar consultorio');
    }

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<List<IdentificationTypeModel>> getIdentificationTypes() async {
    final response = await _apiClient.get('/api/auth/tipos-identificacion');
    final List data = response.data is List 
        ? response.data 
        : (response.data['tipos'] ?? response.data['Tipos'] ?? response.data['data'] ?? response.data['Data'] ?? []);
    return data.map((e) => IdentificationTypeModel.fromJson(e)).toList();
  }

  @override
  Future<RegistrationValidationModel> validateRegistration({
    required int tipoIdentificacionId,
    required String identificacion,
    required String email,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/validar-registro',
      data: {
        'tipoIdentificacionId': tipoIdentificacionId,
        'identificacion': identificacion,
        'email': email,
      },
    );
    // Si el objeto ya contiene 'existe' o 'emailExiste' directly, lo usamos
    final data = (response.data['existe'] != null || response.data['emailExiste'] != null)
        ? response.data
        : (response.data['data'] ?? response.data['Data'] ?? response.data);
    return RegistrationValidationModel.fromJson(data);
  }

  @override
  Future<List<RegistrationRoleModel>> getRegistrationRoles() async {
    final response = await _apiClient.get('/api/auth/roles-registro');
    final List data = response.data is List 
        ? response.data 
        : (response.data['roles'] ?? response.data['Roles'] ?? response.data['data'] ?? response.data['Data'] ?? []);
    return data.map((e) => RegistrationRoleModel.fromJson(e)).toList();
  }

  @override
  Future<void> register(RegistrationRequest request) async {
    final response = await _apiClient.post(
      '/api/auth/register',
      data: request.toJson(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = response.data['message'] ?? 'Error al registrar usuario';
      throw Exception(message);
    }
  }

  @override
  Future<List<CountryModel>> getCountries() async {
    final response = await _apiClient.get('/api/ubicacion/paises');
    final List data = response.data is List ? response.data : (response.data['data'] ?? response.data['Data'] ?? []);
    return data.map((e) => CountryModel.fromJson(e)).toList();
  }

  @override
  Future<List<CityModel>> getCitiesByCountry(int countryId) async {
    final response = await _apiClient.get('/api/ubicacion/paises/$countryId/ciudades');
    final List data = response.data is List ? response.data : (response.data['data'] ?? response.data['Data'] ?? []);
    return data.map((e) => CityModel.fromJson(e)).toList();
  }

  @override
  Future<AuthResponseModel> createClinic(ClinicCreationRequest request) async {
    final response = await _apiClient.post(
      '/api/auth/crear-consultorio',
      data: request.toJson(),
    );

    if (response.data is! Map) {
      throw Exception('Error al crear consultorio');
    }

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true && data['Success'] != true) {
      throw Exception(data['message'] ?? data['Mensaje'] ?? 'Error al crear consultorio');
    }

    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<void> sendWelcomeEmail({
    required String email,
    required String nombre,
    required String usuario,
    required String password,
  }) async {
    await _apiClient.post(
      '/api/correo/enviar-bienvenida',
      data: {
        'email': email,
        'nombre': nombre,
        'usuario': usuario,
        'password': password,
      },
    );
  }
}
