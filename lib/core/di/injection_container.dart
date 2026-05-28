import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/data/datasources/dashboard_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/appointments/data/datasources/clinic_datasource.dart';
import '../../features/appointments/data/datasources/appointment_local_data_source.dart';
import '../../features/appointments/data/datasources/appointment_remote_data_source.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/presentation/bloc/appointment_bloc.dart';
import '../../features/patients/data/datasources/patient_local_data_source.dart';
import '../../features/patients/data/datasources/patient_remote_data_source.dart';
import '../../features/patients/data/datasources/privacy_remote_data_source.dart';
import '../../features/patients/data/repositories/patient_repository_impl.dart';
import '../../features/patients/data/repositories/privacy_repository_impl.dart';
import '../../features/patients/domain/repositories/patient_repository.dart';
import '../../features/patients/domain/repositories/privacy_repository.dart';
import '../../features/patients/presentation/bloc/patient_bloc.dart';
import '../../features/patients/presentation/bloc/patient_detail_bloc.dart';
import '../../features/patients/presentation/bloc/privacy_bloc.dart';
import '../../features/cases/data/datasources/case_remote_data_source.dart';
import '../../features/cases/data/repositories/case_repository_impl.dart';
import '../../features/cases/domain/repositories/case_repository.dart';
import '../../features/cases/presentation/bloc/case_bloc.dart';
import '../../features/medical_history/data/datasources/medical_history_remote_data_source.dart';
import '../../features/medical_history/data/repositories/medical_history_repository_impl.dart';
import '../../features/medical_history/domain/repositories/medical_history_repository.dart';
import '../../features/medical_history/presentation/bloc/medical_history_bloc.dart';
import '../../features/consultations/data/datasources/consultation_remote_data_source.dart';
import '../../features/consultations/data/repositories/consultation_repository_impl.dart';
import '../../features/consultations/domain/repositories/consultation_repository.dart';
import '../../features/consultations/presentation/bloc/consultation_bloc.dart';
import '../routes/app_router.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Router
  sl.registerLazySingleton(() => AppRouter(sl()));

  // Features - Auth
  sl.registerLazySingleton(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      clinicDataSource: sl(),
      storage: sl(),
    ),
  );
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(apiClient: sl()),
  );

  // Features - Dashboard
  sl.registerFactory(() => DashboardBloc(repository: sl()));
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<DashboardDataSource>(
    () => DashboardDataSourceImpl(apiClient: sl()),
  );

  // Features - Appointments
  sl.registerFactory(() => AppointmentBloc(repository: sl()));
  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ClinicDataSource>(
    () => ClinicDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AppointmentLocalDataSource>(
    () => AppointmentLocalDataSourceImpl(),
  );

  // Features - Patients & Privacy
  sl.registerFactory(() => PatientBloc(repository: sl()));
  sl.registerFactory(() => PatientDetailBloc(repository: sl()));
  sl.registerFactory(() => PrivacyBloc(repository: sl()));
  sl.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );
  sl.registerLazySingleton<PrivacyRepository>(
    () => PrivacyRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<PatientLocalDataSource>(
    () => PatientLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<PrivacyRemoteDataSource>(
    () => PrivacyRemoteDataSourceImpl(apiClient: sl()),
  );

  // Features - Cases
  sl.registerFactory(() => CaseBloc(repository: sl()));
  sl.registerLazySingleton<CaseRepository>(
    () => CaseRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CaseRemoteDataSource>(
    () => CaseRemoteDataSourceImpl(apiClient: sl()),
  );

  // Features - Medical History
  sl.registerFactory(() => MedicalHistoryBloc(repository: sl()));
  sl.registerLazySingleton<MedicalHistoryRepository>(
    () => MedicalHistoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MedicalHistoryRemoteDataSource>(
    () => MedicalHistoryRemoteDataSourceImpl(apiClient: sl()),
  );

  // Features - Consultations
  sl.registerFactory(() => ConsultationBloc(repository: sl(), appointmentRepository: sl()));
  sl.registerLazySingleton<ConsultationRepository>(
    () => ConsultationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ConsultationRemoteDataSource>(
    () => ConsultationRemoteDataSourceImpl(apiClient: sl()),
  );

  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(
    () => ApiClient(
      baseUrl: AppConfig.baseUrl,
      storage: sl(),
    ),
  );
}
