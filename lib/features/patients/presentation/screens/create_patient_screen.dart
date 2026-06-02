import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medsuite_cmo/core/di/injection_container.dart';
import 'package:medsuite_cmo/core/utils/medsuite_toast.dart';
import 'package:medsuite_cmo/features/patients/presentation/bloc/register_patient_bloc.dart';

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _identificacionController = TextEditingController();
  int? _selectedTypeId;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _identificacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);

    return BlocProvider(
      create: (context) => sl<RegisterPatientBloc>()..add(LoadRegisterData()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Nuevo Paciente',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: textDark,
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        body: BlocConsumer<RegisterPatientBloc, RegisterPatientState>(
          listener: (context, state) {
            if (state is RegisterPatientSuccess) {
              _showSuccessDialog(state.result);
            }
            if (state is RegisterPatientError) {
              MedSuiteToast.show(context, message: state.message, type: ToastType.error);
            }
          },
          builder: (context, state) {
            if (state is RegisterPatientLoading) {
              return const Center(child: CircularProgressIndicator(color: primaryBlue));
            }

            List idTypes = [];
            if (state is RegisterPatientDataLoaded) {
              idTypes = state.idTypes;
            } else if (state is RegisterPatientSubmitting || state is RegisterPatientSuccess || state is RegisterPatientError) {
              // Mantener tipos si ya se cargaron
              final currentState = context.read<RegisterPatientBloc>().state;
              if (currentState is RegisterPatientDataLoaded) idTypes = currentState.idTypes;
              // NOTA: En una app real, el BLoC debería mantener esta lista en un campo del estado
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Registro Directo',
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete los datos básicos para registrar al paciente en su consultorio.',
                      style: GoogleFonts.inter(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),

                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),

                    // Apellido
                    TextFormField(
                      controller: _apellidoController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),

                    // Tipo Identificación
                    DropdownButtonFormField<int>(
                      initialValue: _selectedTypeId,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Documento',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: idTypes.map((t) {
                        return DropdownMenuItem<int>(value: t.id, child: Text(t.nombre));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedTypeId = val),
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),

                    // Identificación
                    TextFormField(
                      controller: _identificacionController,
                      decoration: const InputDecoration(
                        labelText: 'Número de Identificación',
                        prefixIcon: Icon(Icons.numbers_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 48),

                    ElevatedButton(
                      onPressed: state is RegisterPatientSubmitting ? null : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<RegisterPatientBloc>().add(SubmitPatientRegistration(
                            nombre: _nombreController.text.trim(),
                            apellido: _apellidoController.text.trim(),
                            tipoIdentificacionId: _selectedTypeId!,
                            identificacion: _identificacionController.text.trim(),
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state is RegisterPatientSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Registrar Paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    // Extraer datos de la respuesta según la documentación
    final user = result['user'] ?? result['User'] ?? {};
    final username = user['usuario'] ?? user['Usuario'] ?? user['email'] ?? 'Generado';
    final tempPassword = result['contraseñaTemporal'] ?? result['ContraseñaTemporal'] ?? '123456';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('¡Paciente Registrado!', textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'El paciente ha sido creado correctamente. Entregue estas credenciales para que pueda acceder:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            _CredentialBox(label: 'Usuario', value: username.toString()),
            const SizedBox(height: 12),
            _CredentialBox(label: 'Clave Temporal', value: tempPassword.toString(), isPassword: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar dialogo
              Navigator.pop(context, true); // Volver al listado indicando éxito
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class _CredentialBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isPassword;

  const _CredentialBox({required this.label, required this.value, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.firaMono(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
        ],
      ),
    );
  }
}
