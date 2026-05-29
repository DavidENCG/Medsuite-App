import '../entities/profile.dart';
import '../entities/profile_catalog.dart';

abstract class ProfileRepository {
  Future<Profile> getFullProfile();
  Future<ProfileCatalog> getProfileCatalogs();
  Future<List<CatalogItem>> getCities(int countryId);
  Future<void> updatePersonalInfo(PersonalInfo info, {String? newPassword});
  Future<void> updateMedicalData(MedicalData data);
  Future<List<Specialty>> getSpecialtiesCatalog();
  Future<List<SubSpecialty>> getSubSpecialtiesCatalog(int specialtyId);
  Future<void> assignSpecialty(int specialtyId, int? subSpecialtyId);
  Future<void> removeSpecialty(int id);
}
