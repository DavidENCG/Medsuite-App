import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/medsuite_toast.dart';
import '../bloc/consultation_bloc.dart';
import '../../domain/entities/consultation_detail.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';

class ConsultationScreen extends StatefulWidget {
  final int citaId;
  final String? patientNameFallback;

  const ConsultationScreen({super.key, required this.citaId, this.patientNameFallback});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  // Signos Vitales
  final _tensionController = TextEditingController();
  final _tempController = TextEditingController();
  final _fcController = TextEditingController();
  final _frController = TextEditingController();
  final _satController = TextEditingController();
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();

  // Evolución y Diagnóstico
  final _enfermedadController = TextEditingController();
  final _examenController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _cie10Controller = TextEditingController();
  final _recetaController = TextEditingController();
  final _indicacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ConsultationBloc>().add(FetchConsultationDetail(widget.citaId));
  }

  @override
  void dispose() {
    _tensionController.dispose();
    _tempController.dispose();
    _fcController.dispose();
    _frController.dispose();
    _satController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    _enfermedadController.dispose();
    _examenController.dispose();
    _diagnosticoController.dispose();
    _cie10Controller.dispose();
    _recetaController.dispose();
    _indicacionesController.dispose();
    super.dispose();
  }

  void _fillData(ConsultationDetail detail) {
    _tensionController.text = detail.signosVitales.tensionArterial ?? '';
    _tempController.text = detail.signosVitales.temperatura?.toString() ?? '';
    _fcController.text = detail.signosVitales.frecuenciaCardiaca?.toString() ?? '';
    _frController.text = detail.signosVitales.frecuenciaRespiratoria?.toString() ?? '';
    _satController.text = detail.signosVitales.saturacionOxigeno?.toString() ?? '';
    _pesoController.text = detail.signosVitales.pesoKg?.toString() ?? '';
    _tallaController.text = detail.signosVitales.estaturaCm?.toString() ?? '';
    
    _enfermedadController.text = detail.enfermedadActual.descripcion ?? '';
    _examenController.text = detail.examenFisico.descripcion ?? '';
    _diagnosticoController.text = detail.diagnostico.descripcion ?? '';
    _cie10Controller.text = detail.diagnostico.codigoCIE10 ?? '';
    _recetaController.text = detail.receta.medicamentos ?? '';
    _indicacionesController.text = detail.receta.indicaciones ?? '';
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Consulta Médica', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, color: primaryBlue),
            onPressed: _submit,
          ),
        ],
      ),
      body: BlocConsumer<ConsultationBloc, ConsultationState>(
        listener: (context, state) {
          if (state is ConsultationError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
          if (state is ConsultationSaveSuccess) {
            MedSuiteToast.show(context, message: 'Consulta guardada y paciente atendido', type: ToastType.success);
            context.read<AppointmentBloc>().add(FetchDailyAppointments()); // Refresh global agenda
            Navigator.pop(context);
          }
          if (state is ConsultationLoaded) {
            _fillData(state.detail);
          }
        },
        builder: (context, state) {
          if (state is ConsultationLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          if (state is ConsultationLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientBanner(state.detail),
                  const SizedBox(height: 24),
                  _buildSectionTitle('SIGNOS VITALES'),
                  _buildVitalSignsGrid(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('EVOLUCIÓN CLÍNICA'),
                  _buildCardSection([
                    _buildClinicalField(_enfermedadController, 'Enfermedad Actual', Icons.history_edu_outlined, 4),
                    const SizedBox(height: 16),
                    _buildClinicalField(_examenController, 'Examen Físico', Icons.person_search_outlined, 4),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('DIAGNÓSTICO'),
                  _buildCardSection([
                    _buildClinicalField(_diagnosticoController, 'Diagnóstico Definitivo', Icons.biotech_outlined, 3),
                    const SizedBox(height: 16),
                    _buildClinicalField(_cie10Controller, 'Código CIE-10 (Opcional)', Icons.tag, 1),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('TRATAMIENTO'),
                  _buildCardSection([
                    _buildClinicalField(_recetaController, 'Receta (Medicamentos)', Icons.medication_outlined, 3),
                    const SizedBox(height: 16),
                    _buildClinicalField(_indicacionesController, 'Indicaciones Generales', Icons.list_alt_outlined, 3),
                  ]),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text('Finalizar Consulta', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPatientBanner(ConsultationDetail detail) {
    final String name = detail.pacienteNombre != null && detail.pacienteNombre!.isNotEmpty 
        ? detail.pacienteNombre! 
        : 'Paciente No Identificado';
        
    final String initials = name.substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Cédula: ${detail.pacienteCedula ?? "S/I"} • ${detail.pacienteEdad ?? "?"} años', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
    );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildVitalSignsGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 20,
        children: [
          _buildSmallVitalField(_tensionController, 'T.A.', '120/80', icon: Icons.favorite_border),
          _buildSmallVitalField(_tempController, 'Temp °C', '37', isNumber: true, icon: Icons.thermostat_outlined),
          _buildSmallVitalField(_fcController, 'F.C. bpm', '75', isNumber: true, icon: Icons.monitor_heart_outlined),
          _buildSmallVitalField(_frController, 'F.R. rpm', '18', isNumber: true, icon: Icons.air_outlined),
          _buildSmallVitalField(_pesoController, 'Peso kg', '70', isNumber: true, icon: Icons.monitor_weight_outlined),
          _buildSmallVitalField(_tallaController, 'Talla cm', '170', isNumber: true, icon: Icons.height_outlined),
        ],
      ),
    );
  }

  Widget _buildSmallVitalField(TextEditingController controller, String label, String hint, {bool isNumber = false, required IconData icon}) {
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalField(TextEditingController controller, String label, IconData icon, int lines) {
    return TextField(
      controller: controller,
      maxLines: lines,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        alignLabelWithHint: true,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  void _submit() {
    final detail = ConsultationDetail(
      citaId: widget.citaId,
      signosVitales: VitalSigns(
        tensionArterial: _tensionController.text,
        temperatura: double.tryParse(_tempController.text),
        frecuenciaCardiaca: int.tryParse(_fcController.text),
        frecuenciaRespiratoria: int.tryParse(_frController.text),
        saturacionOxigeno: double.tryParse(_satController.text),
        pesoKg: double.tryParse(_pesoController.text),
        estaturaCm: double.tryParse(_tallaController.text),
      ),
      enfermedadActual: ClinicalSection(descripcion: _enfermedadController.text),
      examenFisico: ClinicalSection(descripcion: _examenController.text),
      diagnostico: ClinicalSection(descripcion: _diagnosticoController.text, codigoCIE10: _cie10Controller.text),
      receta: ClinicalSection(medicamentos: _recetaController.text, indicaciones: _indicacionesController.text),
    );

    context.read<ConsultationBloc>().add(SaveConsultationRequested(detail));
  }
}
