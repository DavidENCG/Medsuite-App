import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/profile_bloc.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_catalog.dart';
import '../../../../core/utils/medsuite_toast.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _identificacionController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _passwordController;

  String? _selectedTipoId;
  String? _selectedSexo;
  int? _selectedPaisId;
  int? _selectedCiudadId;
  String? _selectedPhoneCode;

  ProfileCatalog? _catalogs;
  List<CatalogItem> _cities = [];
  bool _isLoadingCities = false;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    PersonalInfo? info;
    if (profileState is ProfileLoaded) {
      info = profileState.profile.personalInfo;
    }

    _nombreController = TextEditingController(text: info?.nombre);
    _apellidoController = TextEditingController(text: info?.apellido);
    _identificacionController = TextEditingController(text: info?.identificacion);
    _telefonoController = TextEditingController(text: info?.telefono);
    _direccionController = TextEditingController(text: info?.direccion);
    _passwordController = TextEditingController();

    _selectedTipoId = info?.tipoIdentificacion;
    _selectedSexo = info?.sexo;
    _selectedPaisId = info?.paisId;
    _selectedCiudadId = info?.ciudadId;
    _selectedPhoneCode = info?.codigoTelefono;

    context.read<ProfileBloc>().add(FetchProfileCatalogsRequested());
    if (_selectedPaisId != null) {
      context.read<ProfileBloc>().add(FetchCitiesRequested(_selectedPaisId!));
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _identificacionController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Información Personal', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileCatalogsLoaded) {
            setState(() {
              _catalogs = state.catalogs;
              // Validar que los valores seleccionados existan en los nuevos catálogos
              if (_selectedTipoId != null && !_catalogs!.idTypes.any((e) => e.nombre == _selectedTipoId)) {
                _selectedTipoId = null;
              }
              if (_selectedSexo != null && !_catalogs!.genders.any((e) => e.nombre == _selectedSexo)) {
                _selectedSexo = null;
              }
              if (_selectedPhoneCode != null && !_catalogs!.phoneCodes.any((e) => e.nombre == _selectedPhoneCode)) {
                _selectedPhoneCode = null;
              }
              if (_selectedPaisId != null && !_catalogs!.countries.any((e) => e.id == _selectedPaisId)) {
                _selectedPaisId = null;
              }
            });
          }
          if (state is ProfileCitiesLoaded) {
            setState(() {
              _cities = state.cities;
              _isLoadingCities = false;
              // Validar ciudad seleccionada
              if (_selectedCiudadId != null && !_cities.any((e) => e.id == _selectedCiudadId)) {
                _selectedCiudadId = null;
              }
            });
          }
          if (state is ProfileUpdateSuccess) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.success);
            Navigator.pop(context);
          }
          if (state is ProfileError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
        },
        builder: (context, state) {
          if (_catalogs == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_nombreController, 'Nombre', 'Ingresa tu nombre'),
                  const SizedBox(height: 16),
                  _buildTextField(_apellidoController, 'Apellido', 'Ingresa tu apellido'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDropdownField<String>(
                          label: 'Tipo ID',
                          value: _selectedTipoId,
                          items: _catalogs!.idTypes.map((e) => e.nombre).toList(),
                          onChanged: (v) => setState(() => _selectedTipoId = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildTextField(_identificacionController, 'Identificación', 'Número de ID'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField<String>(
                    label: 'Sexo',
                    value: _selectedSexo,
                    items: _catalogs!.genders.map((e) => e.nombre).toList(),
                    onChanged: (v) => setState(() => _selectedSexo = v),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDropdownField<String>(
                          label: 'Cód.',
                          value: _selectedPhoneCode,
                          items: _catalogs!.phoneCodes.map((e) => e.nombre).toList(),
                          onChanged: (v) => setState(() => _selectedPhoneCode = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildTextField(_telefonoController, 'Teléfono', 'Número de teléfono', keyboardType: TextInputType.phone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField<int>(
                    label: 'País',
                    value: _selectedPaisId,
                    items: _catalogs!.countries.map((e) => e.id).toList(),
                    itemLabels: _catalogs!.countries.map((e) => e.nombre).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedPaisId = v;
                        _selectedCiudadId = null;
                        _cities = [];
                        _isLoadingCities = true;
                      });
                      if (v != null) {
                        context.read<ProfileBloc>().add(FetchCitiesRequested(v));
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField<int>(
                    label: 'Ciudad',
                    value: _selectedCiudadId,
                    items: _cities.map((e) => e.id).toList(),
                    itemLabels: _cities.map((e) => e.nombre).toList(),
                    isLoading: _isLoadingCities,
                    onChanged: (v) => setState(() => _selectedCiudadId = v),
                    enabled: _selectedPaisId != null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_direccionController, 'Dirección', 'Dirección de domicilio', maxLines: 2),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Seguridad', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _buildTextField(_passwordController, 'Nueva Contraseña', 'Dejar en blanco si no deseas cambiarla', obscureText: true),
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
                          : const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
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
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
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

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    List<String>? itemLabels,
    required Function(T?) onChanged,
    bool isLoading = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            suffixIcon: isLoading ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2))) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
          items: List.generate(items.length, (index) {
            return DropdownMenuItem<T>(
              value: items[index],
              child: Text(itemLabels != null ? itemLabels[index] : items[index].toString(), style: const TextStyle(fontSize: 14)),
            );
          }),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final info = PersonalInfo(
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        identificacion: _identificacionController.text,
        tipoIdentificacion: _selectedTipoId,
        sexo: _selectedSexo,
        telefono: _telefonoController.text,
        codigoTelefono: _selectedPhoneCode,
        direccion: _direccionController.text,
        paisId: _selectedPaisId,
        ciudadId: _selectedCiudadId,
      );
      context.read<ProfileBloc>().add(UpdatePersonalInfoRequested(info, newPassword: _passwordController.text));
    }
  }
}
