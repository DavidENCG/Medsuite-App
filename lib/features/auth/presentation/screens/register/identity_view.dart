import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medsuite_cmo/core/utils/medsuite_toast.dart';
import '../../bloc/registration/registration_bloc.dart';

class IdentityView extends StatefulWidget {
  const IdentityView({super.key});

  @override
  State<IdentityView> createState() => _IdentityViewState();
}

class _IdentityViewState extends State<IdentityView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _identificacionController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<RegistrationBloc>().state;
    _nombreController = TextEditingController(text: state.nombre);
    _apellidoController = TextEditingController(text: state.apellido);
    _emailController = TextEditingController(text: state.email);
    _telefonoController = TextEditingController(text: state.telefono);
    _identificacionController = TextEditingController(text: state.identificacion);
    _passwordController = TextEditingController(text: state.password);
    _confirmPasswordController = TextEditingController(text: state.password);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _identificacionController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        if (state.status == RegistrationStatus.failure && state.currentStep == 0) {
          MedSuiteToast.show(
            context,
            message: state.errorMessage ?? 'Error desconocido',
            type: ToastType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoadingTypes = state.status == RegistrationStatus.loading && state.identificationTypes.isEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Datos Personales',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(labelText: 'Apellido', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  value: state.tipoIdentificacionId,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Documento',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    hintText: isLoadingTypes ? 'Cargando tipos...' : 'Seleccione tipo',
                  ),
                  items: state.identificationTypes.map((t) {
                    return DropdownMenuItem(value: t.id, child: Text(t.nombre));
                  }).toList(),
                  onChanged: isLoadingTypes ? null : (val) {
                    context.read<RegistrationBloc>().add(UpdatePersonalData(
                      nombre: _nombreController.text,
                      apellido: _apellidoController.text,
                      tipoIdentificacionId: val!,
                      identificacion: _identificacionController.text,
                      email: _emailController.text,
                      telefono: _telefonoController.text,
                      password: _passwordController.text,
                    ));
                  },
                  validator: (v) => v == null ? 'Requerido' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _identificacionController,
                  decoration: const InputDecoration(labelText: 'Número de Identificación', prefixIcon: Icon(Icons.numbers)),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email', 
                    prefixIcon: Icon(Icons.email_outlined),
                    helperText: 'Escriba bien su correo, aquí llegarán sus credenciales.',
                    helperStyle: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Requerido';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Email inválido';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone_android_outlined)),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (v) {
                    if (v!.isEmpty) return 'Requerido';
                    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: state.status == RegistrationStatus.validating || state.status == RegistrationStatus.loading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<RegistrationBloc>().add(UpdatePersonalData(
                              nombre: _nombreController.text,
                              apellido: _apellidoController.text,
                              tipoIdentificacionId: state.tipoIdentificacionId ?? 0,
                              identificacion: _identificacionController.text,
                              email: _emailController.text,
                              telefono: _telefonoController.text,
                              password: _passwordController.text,
                            ));
                            context.read<RegistrationBloc>().add(ValidateAndNext());
                          }
                        },
                  child: state.status == RegistrationStatus.validating
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Siguiente'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
