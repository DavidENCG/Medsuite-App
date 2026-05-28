import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/medsuite_toast.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/case_bloc.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';

class CreateCaseScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const CreateCaseScreen({super.key, required this.patientId, required this.patientName});

  @override
  State<CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<CreateCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _motivoController = TextEditingController();
  
  bool _agendarCita = true;
  DateTime _fechaCita = DateTime.now();
  TimeOfDay _horaCita = TimeOfDay.now();

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Nuevo Caso Clínico', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: BlocConsumer<CaseBloc, CaseState>(
        listener: (context, state) {
          if (state is CaseCreateSuccess) {
            MedSuiteToast.show(context, message: 'Caso y cita creados exitosamente', type: ToastType.success);
            context.read<AppointmentBloc>().add(FetchDailyAppointments()); // Refresh agenda
            Navigator.pop(context);
          }
          if (state is CaseError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientHeader(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('INFORMACIÓN DEL CASO'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _tituloController,
                    label: 'Título del Caso',
                    hint: 'Ej: Tratamiento de Ortodoncia',
                    icon: Icons.assignment_outlined,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descripcionController,
                    label: 'Descripción (Opcional)',
                    hint: 'Detalles adicionales...',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('PRIMERA CITA'),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Agendar primera cita ahora', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    value: _agendarCita,
                    onChanged: (v) => setState(() => _agendarCita = v),
                    activeColor: primaryBlue,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_agendarCita) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker(context)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTimePicker(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _motivoController,
                      label: 'Motivo de Consulta',
                      hint: 'Ej: Evaluación inicial',
                      icon: Icons.info_outline,
                      validator: (v) => _agendarCita && v!.isEmpty ? 'Requerido' : null,
                    ),
                  ],
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state is CaseLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: state is CaseLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Crear Caso y Cita', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF2563EB),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paciente seleccionado:', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
              Text(widget.patientName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF64748B),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _fechaCita,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _fechaCita = date);
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 20, color: Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(DateFormat('yyyy-MM-dd').format(_fechaCita), style: GoogleFonts.inter(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _horaCita);
        if (time != null) setState(() => _horaCita = time);
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(_horaCita.format(context), style: GoogleFonts.inter(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _submit() {
    print('--- SUBMITTING NEW CASE ---');
    final authState = context.read<AuthBloc>().state;
    print('Current AuthState: ${authState.runtimeType}');
    
    if (authState is Authenticated) {
      print('Active Clinic ID in State: ${authState.activeClinicId}');
      print('Full Name in State: ${authState.fullName}');
    }

    if (_formKey.currentState!.validate()) {
      if (authState is! Authenticated) {
        MedSuiteToast.show(context, message: 'Debes estar autenticado', type: ToastType.error);
        return;
      }

      if (authState.activeClinicId == null) {
        MedSuiteToast.show(context, message: 'No se detectó un consultorio activo. Por favor reingresa.', type: ToastType.error);
        return;
      }
      
      final String timeStr = '${_horaCita.hour.toString().padLeft(2, '0')}:${_horaCita.minute.toString().padLeft(2, '0')}:00';

      final data = {
        'consultorioId': authState.activeClinicId,
        'tituloCaso': _tituloController.text,
        'descripcionCaso': _descripcionController.text,
        'pacienteExistenteId': widget.patientId,
        'agendarPrimeraCita': _agendarCita,
        'fechaPrimeraCita': DateFormat('yyyy-MM-dd').format(_fechaCita),
        'horaPrimeraCita': timeStr,
        'motivoConsulta': _motivoController.text,
      };

      context.read<CaseBloc>().add(CreateCaseRequested(data));
    }
  }
}
