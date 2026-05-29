import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/profile_bloc.dart';
import '../../domain/entities/profile.dart';
import '../../../../core/utils/medsuite_toast.dart';

class EditMedicalDataScreen extends StatefulWidget {
  const EditMedicalDataScreen({super.key});

  @override
  State<EditMedicalDataScreen> createState() => _EditMedicalDataScreenState();
}

class _EditMedicalDataScreenState extends State<EditMedicalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _msdsController;
  late TextEditingController _colegioController;
  late TextEditingController _numeroColegioController;
  late TextEditingController _universidadController;
  late TextEditingController _anoGraduacionController;
  late TextEditingController _rifController;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    MedicalData? data;
    if (profileState is ProfileLoaded) {
      data = profileState.profile.medicalData;
    }

    _msdsController = TextEditingController(text: data?.numeroMSDS);
    _colegioController = TextEditingController(text: data?.colegioMedico);
    _numeroColegioController = TextEditingController(text: data?.numeroColegio);
    _universidadController = TextEditingController(text: data?.universidad);
    _anoGraduacionController = TextEditingController(text: data?.anoGraduacion);
    _rifController = TextEditingController(text: data?.rif);
  }

  @override
  void dispose() {
    _msdsController.dispose();
    _colegioController.dispose();
    _numeroColegioController.dispose();
    _universidadController.dispose();
    _anoGraduacionController.dispose();
    _rifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Datos Médicos', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.success);
            Navigator.pop(context);
          }
          if (state is ProfileError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_msdsController, 'Número MSDS', 'Ingresa tu número de registro sanitario'),
                  const SizedBox(height: 16),
                  _buildTextField(_colegioController, 'Colegio Médico', 'Nombre del colegio médico'),
                  const SizedBox(height: 16),
                  _buildTextField(_numeroColegioController, 'Número de Colegiatura', 'Ingresa tu número de colegio'),
                  const SizedBox(height: 16),
                  _buildTextField(_universidadController, 'Universidad', 'Universidad de egreso'),
                  const SizedBox(height: 16),
                  _buildTextField(_anoGraduacionController, 'Año de Graduación', 'Ej: 2015', keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildTextField(_rifController, 'RIF', 'Registro de Información Fiscal'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is ProfileActionInProgress ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state is ProfileActionInProgress
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Guardar Datos Médicos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = MedicalData(
        numeroMSDS: _msdsController.text,
        colegioMedico: _colegioController.text,
        numeroColegio: _numeroColegioController.text,
        universidad: _universidadController.text,
        anoGraduacion: _anoGraduacionController.text,
        rif: _rifController.text,
      );
      context.read<ProfileBloc>().add(UpdateMedicalDataRequested(data));
    }
  }
}
