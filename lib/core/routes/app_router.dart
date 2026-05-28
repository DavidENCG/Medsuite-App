import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/appointments/domain/entities/clinic.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/clinic_selection_screen.dart';
import '../../features/auth/presentation/screens/subscription_blocked_screen.dart';
import '../../features/core/presentation/screens/main_shell_screen.dart';
import '../../features/patients/domain/entities/patient.dart';
import '../../features/patients/presentation/screens/patient_edit_screen.dart';
import '../../features/cases/presentation/screens/create_case_screen.dart';
import '../../features/cases/presentation/screens/patient_cases_screen.dart';
import '../../features/cases/presentation/screens/case_detail_screen.dart';
import '../../features/consultations/presentation/screens/consultation_screen.dart';
import '../../features/medical_history/presentation/screens/medical_history_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash', // Ahora iniciamos en Splash
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSplash = state.matchedLocation == '/splash';

      // 1. Estado Inicial (Solo al arrancar la App)
      if (authState is AuthInitial) {
        return isGoingToSplash ? null : '/splash';
      }

      // 2. Mientras carga, permitimos que se quede en la pantalla actual 
      // para mostrar el indicador de carga (CircularProgressIndicator)
      if (authState is AuthLoading) {
        return null; 
      }

      // 3. Si NO está autenticado (y no está ya cargando)
      if (authState is AuthUnauthenticated || authState is AuthFailure) {
        return isGoingToLogin ? null : '/login';
      }

      // 4. Casos especiales de autenticación (Rol, Clínica, Bloqueo)
      if (authState is AuthNeedsRole) {
        return state.matchedLocation == '/select-role' ? null : '/select-role';
      }
      
      if (authState is AuthNeedsClinic) {
        return state.matchedLocation == '/select-clinic' ? null : '/select-clinic';
      }

      if (authState is AuthSubscriptionBlocked) {
        return state.matchedLocation == '/blocked' ? null : '/blocked';
      }

      // 5. Si está plenamente autenticado
      if (authState is Authenticated) {
        // Si está en pantallas de auth o splash, mandarlo al Dashboard (/)
        final bool isAtAuthScreen = isGoingToLogin || 
                                    isGoingToSplash ||
                                    state.matchedLocation == '/select-role' || 
                                    state.matchedLocation == '/select-clinic' ||
                                    state.matchedLocation == '/blocked';
        if (isAtAuthScreen) {
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/select-role',
        builder: (context, state) {
          final authState = authBloc.state;
          final roles = (authState is AuthNeedsRole) ? authState.roles : <Map<String, dynamic>>[];
          return RoleSelectionScreen(roles: roles);
        },
      ),
      GoRoute(
        path: '/select-clinic',
        builder: (context, state) {
          final authState = authBloc.state;
          final clinics = (authState is AuthNeedsClinic) ? authState.clinics : <Clinic>[];
          return ClinicSelectionScreen(clinics: clinics);
        },
      ),
      GoRoute(
        path: '/blocked',
        builder: (context, state) => const SubscriptionBlockedScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: '/patient/edit',
        builder: (context, state) {
          final patientId = state.extra as int;
          return PatientEditScreen(patientId: patientId);
        },
      ),
      GoRoute(
        path: '/cases/new',
        builder: (context, state) {
          final patient = state.extra as Patient;
          return CreateCaseScreen(patientId: patient.usuarioId, patientName: patient.nombreCompleto);
        },
      ),
      GoRoute(
        path: '/cases',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PatientCasesScreen(
            patientId: extra['patientId'] as int,
            patientName: extra['patientName'] as String,
          );
        },
      ),
      GoRoute(
        path: '/cases/detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CaseDetailScreen(
            caseId: extra['caseId'] as int,
            patientId: extra['patientId'] as int,
            patientName: extra['patientName'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/consultation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ConsultationScreen(
            citaId: extra['citaId'] as int,
            patientNameFallback: extra['patientName'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/patient/history',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MedicalHistoryScreen(
            patientId: extra['patientId'] as int,
            patientName: extra['patientName'] as String,
          );
        },
      ),
    ],
  );
}
