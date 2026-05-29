import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_catalog.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Profile> getFullProfile() async {
    return await _remoteDataSource.getFullProfile();
  }

  @override
  Future<ProfileCatalog> getProfileCatalogs() async {
    return await _remoteDataSource.getProfileCatalogs();
  }

  @override
  Future<List<CatalogItem>> getCities(int countryId) async {
    return await _remoteDataSource.getCities(countryId);
  }

  @override
  Future<void> updatePersonalInfo(PersonalInfo info, {String? newPassword}) async {
    final model = PersonalInfoModel(
      nombre: info.nombre,
      apellido: info.apellido,
      identificacion: info.identificacion,
      tipoIdentificacion: info.tipoIdentificacion,
      sexo: info.sexo,
      fechaNacimiento: info.fechaNacimiento,
      correo: info.correo,
      telefono: info.telefono,
      codigoTelefono: info.codigoTelefono,
      direccion: info.direccion,
      paisId: info.paisId,
      ciudadId: info.ciudadId,
    );
    await _remoteDataSource.updatePersonalInfo(model, newPassword: newPassword);
  }

  @override
  Future<void> updateMedicalData(MedicalData data) async {
    final model = MedicalDataModel(
      colegioMedico: data.colegioMedico,
      numeroColegio: data.numeroColegio,
      numeroMSDS: data.numeroMSDS,
      universidad: data.universidad,
      anoGraduacion: data.anoGraduacion,
      rif: data.rif,
    );
    await _remoteDataSource.updateMedicalData(model);
  }

  @override
  Future<List<Specialty>> getSpecialtiesCatalog() async {
    return await _remoteDataSource.getSpecialtiesCatalog();
  }

  @override
  Future<List<SubSpecialty>> getSubSpecialtiesCatalog(int specialtyId) async {
    return await _remoteDataSource.getSubSpecialtiesCatalog(specialtyId);
  }

  @override
  Future<void> assignSpecialty(int specialtyId, int? subSpecialtyId) async {
    await _remoteDataSource.assignSpecialty(specialtyId, subSpecialtyId);
  }

  @override
  Future<void> removeSpecialty(int id) async {
    await _remoteDataSource.removeSpecialty(id);
  }
}
