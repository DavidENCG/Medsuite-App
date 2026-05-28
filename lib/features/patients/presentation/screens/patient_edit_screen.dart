import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/medsuite_toast.dart';
import '../../domain/entities/patient.dart';
import '../bloc/patient_detail_bloc.dart';
import '../bloc/patient_bloc.dart';

class PatientEditScreen extends StatefulWidget {
  final int patientId;

  const PatientEditScreen({super.key, required this.patientId});

  @override
  State<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _identificacionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  DateTime? _selectedDate;
  int _sexoId = 1;
  int _tipoIdentificacionId = 1;

  @override
  void initState() {
    super.initState();
    context.read<PatientDetailBloc>().add(LoadPatientDetail(widget.patientId));
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _identificacionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _fillFields(Patient patient) {
    _nombreController.text = patient.nombre ?? '';
    _apellidoController.text = patient.apellido ?? '';
    _identificacionController.text = patient.identificacion;
    _telefonoController.text = patient.telefono ?? '';
    _emailController.text = patient.email ?? '';
    _direccionController.text = patient.direccion ?? '';
    _selectedDate = patient.fechaNacimiento;
    _sexoId = patient.sexoId ?? 1;
    _tipoIdentificacionId = patient.tipoIdentificacionId ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Editar Paciente', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: BlocConsumer<PatientDetailBloc, PatientDetailState>(
        listener: (context, state) {
          if (state is PatientDetailUpdateSuccess) {
            MedSuiteToast.show(context, message: 'Información actualizada con éxito', type: ToastType.success);
            context.read<PatientBloc>().add(FetchMyPatients()); // Refresh list
            Navigator.pop(context);
          }
          if (state is PatientDetailError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
          if (state is PatientDetailLoaded) {
            _fillFields(state.patient);
          }
        },
        builder: (context, state) {
          if (state is PatientDetailLoading && state is! PatientDetailUpdateSuccess) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('DATOS PERSONALES'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre',
                    icon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _apellidoController,
                    label: 'Apellido',
                    icon: Icons.person_outline,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField<int>(
                          label: 'Sexo',
                          value: _sexoId,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Masculino')),
                            DropdownMenuItem(value: 2, child: Text('Femenino')),
                          ],
                          onChanged: (v) => setState(() => _sexoId = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('IDENTIFICACIÓN Y CONTACTO'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _identificacionController,
                    label: 'Cédula / Identificación',
                    icon: Icons.badge_outlined,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Correo Electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _direccionController,
                    label: 'Dirección',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text('Guardar Cambios', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
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
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nacimiento', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime(1990),
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.centerLeft,
            child: Text(
              _selectedDate == null ? 'Seleccionar' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'tipoIdentificacionId': _tipoIdentificacionId,
        'identificacion': _identificacionController.text,
        'telefono': _telefonoController.text,
        'email': _emailController.text,
        'fechaNacimiento': _selectedDate?.toIso8601String().split('T')[0],
        'sexoId': _sexoId,
        'direccion': _direccionController.text,
        'ciudadId': 1, // Defaulting for now
      };
      context.read<PatientDetailBloc>().add(UpdatePatientDetail(patientId: widget.patientId, data: data));
    }
  }
}
