import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';
import 'package:dio/dio.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getFullProfile();
  Future<ProfileCatalogModel> getProfileCatalogs();
  Future<List<CatalogItemModel>> getCities(int countryId);
  Future<void> updatePersonalInfo(PersonalInfoModel info, {String? newPassword});
  Future<void> updateMedicalData(MedicalDataModel data);
  Future<List<SpecialtyModel>> getSpecialtiesCatalog();
  Future<List<SubSpecialtyModel>> getSubSpecialtiesCatalog(int specialtyId);
  Future<void> assignSpecialty(int specialtyId, int? subSpecialtyId);
  Future<void> removeSpecialty(int id);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  Map<String, dynamic> _ensureMap(dynamic data) {
    if (data == null) return {};
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (e) {
        print('PROFILE_DATA_SOURCE: Error decoding JSON string: $e');
      }
    }
    return {};
  }

  @override
  Future<ProfileModel> getFullProfile() async {
    try {
      print('PROFILE_DATA_SOURCE: Requesting GET /api/Perfil/completo');
      final response = await _apiClient.get('/api/Perfil/completo');
      print('PROFILE_DATA_SOURCE: Response Status: ${response.statusCode}');
      print('PROFILE_DATA_SOURCE: Raw Body: ${response.data}');
      
      final data = _ensureMap(response.data);
      return ProfileModel.fromJson(data);
    } catch (e) {
      print('PROFILE_DATA_SOURCE: Error in getFullProfile: $e');
      rethrow;
    }
  }

  @override
  Future<ProfileCatalogModel> getProfileCatalogs() async {
    try {
      print('PROFILE_DATA_SOURCE: Requesting GET /api/Perfil/catalogos');
      final response = await _apiClient.get('/api/Perfil/catalogos');
      print('PROFILE_DATA_SOURCE: Raw Body: ${response.data}');
      
      final data = _ensureMap(response.data);
      return ProfileCatalogModel.fromJson(data);
    } catch (e) {
      print('PROFILE_DATA_SOURCE: Error in getProfileCatalogs: $e');
      rethrow;
    }
  }

  @override
  Future<List<CatalogItemModel>> getCities(int countryId) async {
    try {
      print('PROFILE_DATA_SOURCE: Requesting GET /api/Perfil/catalogos/ciudades/$countryId');
      final response = await _apiClient.get('/api/Perfil/catalogos/ciudades/$countryId');
      print('PROFILE_DATA_SOURCE: Raw Body: ${response.data}');
      
      final resMap = _ensureMap(response.data);
      final data = resMap['data'] ?? resMap['Data'] ?? (response.data is List ? response.data : []);
      
      if (data is List) {
        return data.map((e) => CatalogItemModel.fromJson(_ensureMap(e))).toList();
      }
      return [];
    } catch (e) {
      print('PROFILE_DATA_SOURCE: Error in getCities: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePersonalInfo(PersonalInfoModel info, {String? newPassword}) async {
    try {
      final payload = info.toJson(password: newPassword);
      print('PROFILE_DATA_SOURCE: Requesting PUT /api/Perfil/actualizar-personal Payload: $payload');
      final response = await _apiClient.put('/api/Perfil/actualizar-personal', data: payload);
      print('PROFILE_DATA_SOURCE: Response Body: ${response.data}');
      
      final resMap = _ensureMap(response.data);
      if (resMap['success'] == false || resMap['Success'] == false) {
        throw Exception(resMap['message'] ?? resMap['Mensaje'] ?? 'Error al actualizar información personal');
      }
    } catch (e) {
      print('PROFILE_DATA_SOURCE: Error in updatePersonalInfo: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMedicalData(MedicalDataModel data) async {
    try {
      final payload = data.toJson();
      print('PROFILE_DATA_SOURCE: Requesting PUT /api/Perfil/actualizar-datos-medicos Payload: $payload');
      final response = await _apiClient.put('/api/Perfil/actualizar-datos-medicos', data: payload);
      print('PROFILE_DATA_SOURCE: Response Body: ${response.data}');
      
      final resMap = _ensureMap(response.data);
      if (resMap['success'] == false || resMap['Success'] == false) {
        throw Exception(resMap['message'] ?? resMap['Mensaje'] ?? 'Error al actualizar datos médicos');
      }
    } catch (e) {
      print('PROFILE_DATA_SOURCE: Error in updateMedicalData: $e');
      rethrow;
    }
  }

  @override
  Future<List<SpecialtyModel>> getSpecialtiesCatalog() async {
    try {
      print('PROFILE_DATA_SOURCE: Requesting GET /api/Perfil/especialidades/catalogo');
      final response = await _apiClient.get('/api/Perfil/especialidades/catalogo');
      print('PROFILE_DATA_SOURCE: Raw Body: ${response.data}');
      
      final resMap = _ensureMap(response.data);
      final data = resMap['data'] ?? resMap['Data'] ?? (response.data is List ? response.data : []);
      
      if (data is List) {
        return data.map((e) => SpecialtyModel.fromJson(_ensureMap(e))).toList();
      }
      return [];
    } catch (e) {
      print('PROFILE_DATA_SOURCE: Error in getSpecialtiesCatalog: $e');
      rethrow;
    }
  }

  @override
  Future<List<SubSpecialtyModel>> getSubSpecialtiesCatalog(int specialtyId) async {
    try {
      print('PROFILE_DATA_SOURCE: Requesting GET /api/Perfil/especialidades/sub-catalogo/$specialtyId');
      final response = await _apiClient.get('/api/Perfil/especialidades/sub-catalogo/$specialtyId');
      print('PROFILE_DATA_SOURCE: Raw Body: ${response.data}');
      
      final resMap = _ensureMap(response.data);
      final data = resMap['data'] ?? resMap['Data'] ?? (response.data is List ? response.data : []);
      
      if (data is List) {
        return data.map((e) => SubSpecialtyModel.fromJson(_ensureMap(e))).toList();
      }
      return [];
    } catch (e) {
      print('PROFILE_DATA_SOURCE: Error in getSubSpecialtiesCatalog: $e');
      rethrow;
    }
  }

  @override
  Future<void> assignSpecialty(int specialtyId, int? subSpecialtyId) async {
    final response = await _apiClient.post('/api/Perfil/especialidades/asignar', data: {
      'especialidadId': specialtyId,
      if (subSpecialtyId != null) 'subEspecialidadId': subSpecialtyId,
    });
    final resMap = _ensureMap(response.data);
    if (resMap['success'] == false || resMap['Success'] == false) {
      throw Exception(resMap['message'] ?? resMap['Mensaje'] ?? 'Error al asignar especialidad');
    }
  }

  @override
  Future<void> removeSpecialty(int id) async {
    final response = await _apiClient.delete('/api/Perfil/especialidades/remover/$id');
    final resMap = _ensureMap(response.data);
    if (resMap['success'] == false || resMap['Success'] == false) {
      throw Exception(resMap['message'] ?? resMap['Mensaje'] ?? 'Error al remover especialidad');
    }
  }
}
