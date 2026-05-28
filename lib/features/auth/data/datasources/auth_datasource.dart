import 'package:medsuite_cmo/core/network/api_client.dart';

import '../models/auth_response_model.dart';

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
}
