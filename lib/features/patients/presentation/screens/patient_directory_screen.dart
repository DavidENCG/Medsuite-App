import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../bloc/patient_bloc.dart';
import '../widgets/patient_quick_profile_sheet.dart';
import 'camera_scanner_screen.dart';

class PatientDirectoryScreen extends StatefulWidget {
  const PatientDirectoryScreen({super.key});

  @override
  State<PatientDirectoryScreen> createState() => _PatientDirectoryScreenState();
}

class _PatientDirectoryScreenState extends State<PatientDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(FetchMyPatients());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<PatientBloc>().add(SearchPatientsQuery(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header y Buscador
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Directorio',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      BlocBuilder<PatientBloc, PatientState>(
                        builder: (context, state) {
                          if (state is PatientsLoaded) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${state.totalCount} Pacientes',
                                style: GoogleFonts.inter(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Nombre o identificación...',
                              hintStyle: GoogleFonts.inter(color: textLight, fontSize: 14),
                              prefixIcon: const Icon(Icons.search, color: textLight),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CameraScannerScreen()),
                            );
                            if (result != null) {
                              // Si escaneó y autorizó, mostramos el perfil directamente
                              _showQuickProfile(result);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Banner Offline
            BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                if (state is PatientsLoaded && state.isOffline) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.amber.shade700,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, color: Colors.white, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'Modo Sin Conexión - Lista en Caché',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),

            // Lista de Pacientes
            Expanded(
              child: BlocBuilder<PatientBloc, PatientState>(
                builder: (context, state) {
                  if (state is PatientsLoading) {
                    return const Center(child: CircularProgressIndicator(color: primaryBlue));
                  }

                  if (state is PatientsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is PatientSearchEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No se encontraron pacientes', style: GoogleFonts.inter(color: textLight)),
                        ],
                      ),
                    );
                  }

                  if (state is PatientsLoaded) {
                    if (state.patients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Aún no tienes pacientes registrados',
                              style: GoogleFonts.inter(color: textLight),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.patients.length,
                      itemBuilder: (context, index) {
                        final patient = state.patients[index];
                        final initials = patient.nombreCompleto.isNotEmpty 
                            ? patient.nombreCompleto.substring(0, 1).toUpperCase()
                            : '?';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () => _showQuickProfile(patient),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: primaryBlue.withValues(alpha: 0.1),
                                    child: Text(
                                      initials,
                                      style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patient.nombreCompleto,
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textDark),
                                        ),
                                        Text(
                                          'Cédula: ${patient.identificacion} • ${patient.edad ?? "?"} años',
                                          style: GoogleFonts.inter(color: textLight, fontSize: 12),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (patient.tieneHistoria ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: (patient.tieneHistoria ? Colors.green : Colors.orange).withValues(alpha: 0.2),
                                            ),
                                          ),
                                          child: Text(
                                            patient.tieneHistoria ? 'HISTORIA ACTIVA' : 'SIN HISTORIA',
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: patient.tieneHistoria ? Colors.green.shade700 : Colors.orange.shade700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickProfile(dynamic patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PatientQuickProfileSheet(patient: patient),
    );
  }
}
