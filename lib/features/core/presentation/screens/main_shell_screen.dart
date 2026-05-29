import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../appointments/presentation/screens/agenda_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../patients/presentation/screens/patient_directory_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AgendaScreen(),
    const PatientDirectoryScreen(),
    const Center(child: Text('Ajustes')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo_medsuite.png', height: 30, 
          errorBuilder: (context, error, stackTrace) => Text('MedSuite', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const _ProfileDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryBlue,
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Agenda'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Pacientes'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Ajustes'),
          ],
        ),
      ),
    );
  }
}

class _ProfileDrawer extends StatelessWidget {
  const _ProfileDrawer();

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);

    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String doctorName = 'Médico Usuario';
          String clinicName = 'MedSuite';
          bool canSwitchClinic = false;

          if (state is Authenticated) {
            doctorName = state.fullName ?? 'Médico Usuario';
            clinicName = state.activeClinicName ?? 'Sede Principal';
            canSwitchClinic = state.clinics.length > 1;
          }

          return Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: primaryBlue),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: primaryBlue),
                ),
                accountName: Text(
                  doctorName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  clinicName,
                  style: GoogleFonts.inter(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.business_outlined),
                title: const Text('Cambiar Consultorio'),
                subtitle: !canSwitchClinic ? const Text('Solo un consultorio registrado', style: TextStyle(fontSize: 10)) : null,
                enabled: canSwitchClinic,
                onTap: () {
                  Navigator.pop(context); // Cerrar drawer
                  context.push('/select-clinic');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Mi Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Información Personal'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/profile/personal');
                },
              ),
              ListTile(
                leading: const Icon(Icons.medical_services_outlined),
                title: const Text('Datos Médicos'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/profile/medical');
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_outlined),
                title: const Text('Especialidades'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/profile/specialties');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Seguridad'),
                onTap: () {},
              ),
              const Divider(),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
