import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/medsuite_toast.dart';
import '../bloc/case_bloc.dart';
import '../../domain/entities/case_detail.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class CaseDetailScreen extends StatefulWidget {
  final int caseId;
  final int patientId;
  final String? patientName;

  const CaseDetailScreen({super.key, required this.caseId, required this.patientId, this.patientName});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CaseBloc>().add(FetchCaseDetail(widget.caseId));
  }

  void _showScheduleDialog() {
    final authState = context.read<AuthBloc>().state;
    int? activeClinicId;
    if (authState is Authenticated) {
      activeClinicId = authState.activeClinicId;
    }

    if (activeClinicId == null) {
      MedSuiteToast.show(context, message: 'No se detectó un consultorio activo', type: ToastType.error);
      return;
    }

    DateTime fecha = DateTime.now();
    TimeOfDay hora = TimeOfDay.now();
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Agendar Nueva Cita', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Fecha'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(fecha)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: fecha, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (date != null) setState(() => fecha = date);
                },
              ),
              ListTile(
                title: const Text('Hora'),
                subtitle: Text(hora.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: hora);
                  if (time != null) setState(() => hora = time);
                },
              ),
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(labelText: 'Motivo / Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final timeStr = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}:00';
                final data = {
                  'casoId': widget.caseId,
                  'pacienteId': widget.patientId,
                  'consultorioId': activeClinicId,
                  'fechaCita': DateFormat('yyyy-MM-dd').format(fecha),
                  'horaCita': timeStr,
                  'motivoConsulta': motivoController.text,
                };
                context.read<CaseBloc>().add(ScheduleAppointmentRequested(data, widget.caseId));
                Navigator.pop(context);
              },
              child: const Text('Agendar'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    final lower = estado.toLowerCase();
    if (lower.contains('atendido')) return Colors.green;
    if (lower.contains('espera')) return Colors.blue;
    if (lower.contains('cancelad')) return Colors.red;
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Detalle del Caso', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: BlocConsumer<CaseBloc, CaseState>(
        listener: (context, state) {
          if (state is CaseError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
          if (state is AppointmentScheduleSuccess) {
            MedSuiteToast.show(context, message: 'Cita agendada correctamente', type: ToastType.success);
          }
        },
        builder: (context, state) {
          if (state is CaseLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          if (state is CaseDetailLoaded) {
            final caseDetail = state.caseDetail;
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
                      Text('Caso Clínico', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                      Text(caseDetail.tituloCaso, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: textDark)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('LÍNEA DE TIEMPO (CITAS)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
                      TextButton.icon(
                        onPressed: _showScheduleDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nueva Cita'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: caseDetail.citas.isEmpty
                      ? Center(child: Text('No hay citas registradas en este caso', style: GoogleFonts.inter(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: caseDetail.citas.length,
                          itemBuilder: (context, index) {
                            final cita = caseDetail.citas[index];
                            final color = _getStatusColor(cita.estado);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.1),
                                  child: Icon(Icons.calendar_month, color: color, size: 18),
                                ),
                                onTap: () {
                                  context.push('/consultation', extra: {
                                    'citaId': cita.id,
                                    'patientName': widget.patientName,
                                  });
                                },
                                title: Text(
                                  cita.fechaCita != null ? DateFormat('dd MMM yyyy, hh:mm a').format(cita.fechaCita!) : 'Fecha no definida',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(cita.estado),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    cita.estado.toUpperCase(),
                                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
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
