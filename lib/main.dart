import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/appointments/presentation/bloc/appointment_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/patients/presentation/bloc/patient_bloc.dart';
import 'features/patients/presentation/bloc/patient_detail_bloc.dart';
import 'features/patients/presentation/bloc/privacy_bloc.dart';
import 'features/cases/presentation/bloc/case_bloc.dart';
import 'features/medical_history/presentation/bloc/medical_history_bloc.dart';
import 'features/consultations/presentation/bloc/consultation_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de formatos de fecha
  await initializeDateFormatting('es', null);
  
  // Inicialización de Hive para modo Offline
  await Hive.initFlutter();
  
  await di.init();
  
  // Configuración de Sincronización Automática (Fase 3)
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
    final hasConnection = !results.contains(ConnectivityResult.none);
    if (hasConnection) {
      di.sl<AppointmentBloc>().add(SyncOfflineChanges());
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<DashboardBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<AppointmentBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<PatientBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<PatientDetailBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<PrivacyBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<CaseBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<MedicalHistoryBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ConsultationBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ProfileBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'MedSuite CMO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: di.sl<AppRouter>().router,
      ),
    );
  }
}
