import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../appointments/domain/entities/clinic.dart';
import '../../../../core/utils/medsuite_toast.dart';
import '../bloc/auth_bloc.dart';

class ClinicSelectionScreen extends StatelessWidget {
  final List<Clinic> clinics;

  const ClinicSelectionScreen({super.key, required this.clinics});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const backgroundGrey = Color(0xFFF1F5F9);
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Selecciona Consultorio',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tienes varias clínicas asignadas. Elige una para comenzar tu sesión de trabajo.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: textLight,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (state is AuthLoading)
                    const Expanded(child: Center(child: CircularProgressIndicator(color: primaryBlue)))
                  else if (clinics.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No se encontraron consultorios disponibles.',
                          style: GoogleFonts.inter(color: textLight),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: clinics.length,
                        itemBuilder: (context, index) {
                          final clinic = clinics[index];
                          final clinicId = clinic.id;
                          final clinicName = clinic.nombre;
                          final clinicAddress = clinic.direccion ?? 'Dirección no especificada';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InkWell(
                              onTap: () {
                                context.read<AuthBloc>().add(ClinicSelected(clinicId: clinicId));
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: primaryBlue.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_hospital_rounded,
                                        color: primaryBlue,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            clinicName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            clinicAddress,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: textLight,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Color(0xFFCBD5E1),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
