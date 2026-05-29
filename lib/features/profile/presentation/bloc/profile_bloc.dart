import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_catalog.dart';
import '../../domain/repositories/profile_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class FetchProfileRequested extends ProfileEvent {}

class FetchProfileCatalogsRequested extends ProfileEvent {}

class FetchCitiesRequested extends ProfileEvent {
  final int countryId;
  const FetchCitiesRequested(this.countryId);
  @override
  List<Object?> get props => [countryId];
}

class UpdatePersonalInfoRequested extends ProfileEvent {
  final PersonalInfo info;
  final String? newPassword;
  const UpdatePersonalInfoRequested(this.info, {this.newPassword});
  @override
  List<Object?> get props => [info, newPassword];
}

class UpdateMedicalDataRequested extends ProfileEvent {
  final MedicalData data;
  const UpdateMedicalDataRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class FetchSpecialtiesCatalogRequested extends ProfileEvent {}

class FetchSubSpecialtiesCatalogRequested extends ProfileEvent {
  final int specialtyId;
  const FetchSubSpecialtiesCatalogRequested(this.specialtyId);
  @override
  List<Object?> get props => [specialtyId];
}

class AssignSpecialtyRequested extends ProfileEvent {
  final int specialtyId;
  final int? subSpecialtyId;
  const AssignSpecialtyRequested(this.specialtyId, {this.subSpecialtyId});
  @override
  List<Object?> get props => [specialtyId, subSpecialtyId];
}

class RemoveSpecialtyRequested extends ProfileEvent {
  final int id;
  const RemoveSpecialtyRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileCatalogLoading extends ProfileState {}
class ProfileSpecialtiesCatalogLoading extends ProfileState {}
class ProfileActionInProgress extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileCatalogsLoaded extends ProfileState {
  final ProfileCatalog catalogs;
  const ProfileCatalogsLoaded(this.catalogs);
  @override
  List<Object?> get props => [catalogs];
}

class ProfileCitiesLoaded extends ProfileState {
  final List<CatalogItem> cities;
  const ProfileCitiesLoaded(this.cities);
  @override
  List<Object?> get props => [cities];
}

class ProfileSpecialtiesCatalogLoaded extends ProfileState {
  final List<Specialty> specialties;
  const ProfileSpecialtiesCatalogLoaded(this.specialties);
  @override
  List<Object?> get props => [specialties];
}

class ProfileSubSpecialtiesCatalogLoaded extends ProfileState {
  final List<SubSpecialty> subSpecialties;
  const ProfileSubSpecialtiesCatalogLoaded(this.subSpecialties);
  @override
  List<Object?> get props => [subSpecialties];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  const ProfileUpdateSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(ProfileInitial()) {
    on<FetchProfileRequested>(_onFetchProfile);
    on<FetchProfileCatalogsRequested>(_onFetchCatalogs);
    on<FetchCitiesRequested>(_onFetchCities);
    on<UpdatePersonalInfoRequested>(_onUpdatePersonalInfo);
    on<UpdateMedicalDataRequested>(_onUpdateMedicalData);
    on<FetchSpecialtiesCatalogRequested>(_onFetchSpecialtiesCatalog);
    on<FetchSubSpecialtiesCatalogRequested>(_onFetchSubSpecialtiesCatalog);
    on<AssignSpecialtyRequested>(_onAssignSpecialty);
    on<RemoveSpecialtyRequested>(_onRemoveSpecialty);
  }

  Future<void> _onFetchProfile(FetchProfileRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getFullProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onFetchCatalogs(FetchProfileCatalogsRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileCatalogLoading());
    try {
      final catalogs = await _repository.getProfileCatalogs();
      emit(ProfileCatalogsLoaded(catalogs));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onFetchCities(FetchCitiesRequested event, Emitter<ProfileState> emit) async {
    try {
      final cities = await _repository.getCities(event.countryId);
      emit(ProfileCitiesLoaded(cities));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdatePersonalInfo(UpdatePersonalInfoRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileActionInProgress());
    try {
      await _repository.updatePersonalInfo(event.info, newPassword: event.newPassword);
      emit(const ProfileUpdateSuccess("Información personal actualizada correctamente"));
      add(FetchProfileRequested());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateMedicalData(UpdateMedicalDataRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileActionInProgress());
    try {
      await _repository.updateMedicalData(event.data);
      emit(const ProfileUpdateSuccess("Datos médicos actualizados correctamente"));
      add(FetchProfileRequested());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onFetchSpecialtiesCatalog(FetchSpecialtiesCatalogRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileSpecialtiesCatalogLoading());
    try {
      final specialties = await _repository.getSpecialtiesCatalog();
      emit(ProfileSpecialtiesCatalogLoaded(specialties));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onFetchSubSpecialtiesCatalog(FetchSubSpecialtiesCatalogRequested event, Emitter<ProfileState> emit) async {
    try {
      final subSpecialties = await _repository.getSubSpecialtiesCatalog(event.specialtyId);
      emit(ProfileSubSpecialtiesCatalogLoaded(subSpecialties));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onAssignSpecialty(AssignSpecialtyRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileActionInProgress());
    try {
      await _repository.assignSpecialty(event.specialtyId, event.subSpecialtyId);
      emit(const ProfileUpdateSuccess("Especialidad asignada correctamente"));
      add(FetchProfileRequested());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onRemoveSpecialty(RemoveSpecialtyRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileActionInProgress());
    try {
      await _repository.removeSpecialty(event.id);
      emit(const ProfileUpdateSuccess("Especialidad removida correctamente"));
      add(FetchProfileRequested());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
