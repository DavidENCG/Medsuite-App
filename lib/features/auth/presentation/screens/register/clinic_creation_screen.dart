import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medsuite_cmo/core/di/injection_container.dart';
import 'package:medsuite_cmo/core/utils/medsuite_toast.dart';
import 'package:medsuite_cmo/features/auth/data/models/clinic_creation_request.dart';
import 'package:medsuite_cmo/features/auth/domain/entities/location.dart';
import 'package:medsuite_cmo/features/auth/domain/repositories/auth_repository.dart';
import 'package:medsuite_cmo/features/auth/presentation/bloc/auth_bloc.dart';

class ClinicCreationScreen extends StatefulWidget {
  const ClinicCreationScreen({super.key});

  @override
  State<ClinicCreationScreen> createState() => _ClinicCreationScreenState();
}

class _ClinicCreationScreenState extends State<ClinicCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  
  List<Country> _countries = [];
  List<City> _cities = [];
  int? _selectedCountryId;
  int? _selectedCityId;
  bool _isLoading = false;
  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await sl<AuthRepository>().getCountries();
      setState(() {
        _countries = countries;
        _isLoadingLocations = false;
      });
    } catch (e) {
      if (mounted) {
        MedSuiteToast.show(context, message: 'Error al cargar países', type: ToastType.error);
        setState(() => _isLoadingLocations = false);
      }
    }
  }

  Future<void> _loadCities(int countryId) async {
    setState(() {
      _isLoadingLocations = true;
      _cities = [];
      _selectedCityId = null;
    });
    try {
      final cities = await sl<AuthRepository>().getCitiesByCountry(countryId);
      setState(() {
        _cities = cities;
        _isLoadingLocations = false;
      });
    } catch (e) {
      if (mounted) {
        MedSuiteToast.show(context, message: 'Error al cargar ciudades', type: ToastType.error);
        setState(() => _isLoadingLocations = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCityId == null) {
      MedSuiteToast.show(context, message: 'Seleccione una ciudad', type: ToastType.warning);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authBloc = context.read<AuthBloc>();
      // Necesitamos obtener los datos temporales del BLoC de Auth para la creación
      // Como no están expuestos directamente en el estado AuthNeedsClinicCreation, 
      // asumimos que el BLoC los tiene en sus variables privadas y nos los proveerá 
      // a través de un nuevo método o evento si fuera necesario, pero para esta 
      // implementación directa usaremos los datos que ya sabemos que el BLoC maneja.
      
      // NOTA: Para que esto funcione, el BLoC debe tener guardados userId, roleId y tokenTemporal
      // de la respuesta del login.
      
      final request = ClinicCreationRequest(
        nombre: _nameController.text.trim(),
        direccion: _addressController.text.trim(),
        ciudadId: _selectedCityId!,
        usuarioId: authBloc.userId ?? 0, // Necesitamos exponer estos campos en AuthBloc
        rolId: authBloc.roleId ?? 0,
        tokenTemporal: authBloc.tokenTemporal ?? '',
      );

      final session = await sl<AuthRepository>().createClinic(request);
      if (mounted) {
        authBloc.add(ClinicCreated(session));
        MedSuiteToast.show(context, message: '¡Consultorio creado con éxito!', type: ToastType.success);
      }
    } catch (e) {
      if (mounted) {
        MedSuiteToast.show(context, message: e.toString().replaceFirst('Exception: ', ''), type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Consultorio'),
        automaticallyImplyLeading: false, // No volver atrás al login sin querer
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.medical_services_outlined, size: 80, color: primaryBlue),
              const SizedBox(height: 24),
              const Text(
                '¡Bienvenido, Doctor!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Para comenzar, configure su primer consultorio donde atenderá a sus pacientes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // Nombre del Consultorio
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Consultorio',
                  prefixIcon: Icon(Icons.business_outlined),
                  hintText: 'Ej: Consultorio Médico San José',
                ),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),

              // País
              DropdownButtonFormField<int>(
                value: _selectedCountryId,
                decoration: const InputDecoration(
                  labelText: 'País',
                  prefixIcon: Icon(Icons.public_outlined),
                ),
                items: _countries.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
                onChanged: _isLoadingLocations ? null : (val) {
                  setState(() => _selectedCountryId = val);
                  if (val != null) _loadCities(val);
                },
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),

              // Ciudad
              DropdownButtonFormField<int>(
                value: _selectedCityId,
                decoration: InputDecoration(
                  labelText: 'Ciudad',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  hintText: _selectedCountryId == null ? 'Seleccione primero un país' : 'Seleccione ciudad',
                ),
                items: _cities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
                onChanged: _isLoadingLocations || _selectedCountryId == null ? null : (val) => setState(() => _selectedCityId = val),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 20),

              // Dirección
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección Exacta',
                  prefixIcon: Icon(Icons.map_outlined),
                  hintText: 'Av, calle, edificio, local...',
                ),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading || _isLoadingLocations ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Crear y Empezar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                child: const Text('Cancelar y salir', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
