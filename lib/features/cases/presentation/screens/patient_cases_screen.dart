import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/medsuite_toast.dart';
import '../bloc/case_bloc.dart';
import '../../domain/entities/medical_case.dart';
import '../../../../features/patients/domain/entities/patient.dart';

class PatientCasesScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const PatientCasesScreen({super.key, required this.patientId, required this.patientName});

  @override
  State<PatientCasesScreen> createState() => _PatientCasesScreenState();
}

class _PatientCasesScreenState extends State<PatientCasesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CaseBloc>().add(FetchPatientCases(widget.patientId));
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Casos Médicos', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a crear nuevo caso
          // We need a dummy Patient object for the route extra, or just pass ID and name. 
          // Our route expects a Patient object.
          final patient = Patient(
            usuarioId: widget.patientId,
            nombreCompleto: widget.patientName,
            identificacion: '', // Placeholder
            tieneHistoria: false, // Placeholder
          );
          context.push('/cases/new', extra: patient).then((_) {
            // Refrescar al volver
            context.read<CaseBloc>().add(FetchPatientCases(widget.patientId));
          });
        },
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Nuevo Caso', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: BlocConsumer<CaseBloc, CaseState>(
        listener: (context, state) {
          if (state is CaseError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
        },
        builder: (context, state) {
          if (state is CaseLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          if (state is CasesLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paciente', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                      Text(widget.patientName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: textDark)),
                    ],
                  ),
                ),
                Expanded(
                  child: state.cases.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No hay casos registrados', style: GoogleFonts.inter(color: Colors.grey.shade500)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: state.cases.length,
                          itemBuilder: (context, index) {
                            final medicalCase = state.cases[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  context.push('/cases/detail', extra: {
                                    'caseId': medicalCase.id,
                                    'patientId': widget.patientId,
                                    'patientName': widget.patientName,
                                  }).then((_) {
                                    context.read<CaseBloc>().add(FetchPatientCases(widget.patientId));
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: primaryBlue.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.assignment_outlined, color: primaryBlue),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              medicalCase.titulo,
                                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Apertura: ${DateFormat('dd/MM/yyyy').format(medicalCase.fechaApertura)}',
                                              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
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
                        ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
