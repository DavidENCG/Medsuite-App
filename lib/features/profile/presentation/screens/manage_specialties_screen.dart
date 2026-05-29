import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/profile_bloc.dart';
import '../../domain/entities/profile.dart';
import '../../../../core/utils/medsuite_toast.dart';

class ManageSpecialtiesScreen extends StatefulWidget {
  const ManageSpecialtiesScreen({super.key});

  @override
  State<ManageSpecialtiesScreen> createState() => _ManageSpecialtiesScreenState();
}

class _ManageSpecialtiesScreenState extends State<ManageSpecialtiesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Especialidades', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3BB5AB)),
            onPressed: () => _showAddSpecialtyDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.success);
          }
          if (state is ProfileError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && state is! ProfileLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = (context.read<ProfileBloc>().state is ProfileLoaded)
              ? (context.read<ProfileBloc>().state as ProfileLoaded).profile
              : null;

          if (profile == null) {
            return const Center(child: Text('Cargando...'));
          }

          if (profile.specialties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No tienes especialidades asignadas', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddSpecialtyDialog(context),
                    child: const Text('Agregar Especialidad'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profile.specialties.length,
            itemBuilder: (context, index) {
              final s = profile.specialties[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: s.subSpecialties.isNotEmpty
                      ? Text(s.subSpecialties.map((sub) => sub.nombre).join(', '))
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _confirmRemove(context, s),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmRemove(BuildContext context, Specialty s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Especialidad'),
        content: Text('¿Estás seguro que deseas remover "${s.nombre}" de tu perfil?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(RemoveSpecialtyRequested(s.id));
            },
            child: const Text('Remover', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddSpecialtyDialog(BuildContext context) {
    context.read<ProfileBloc>().add(FetchSpecialtiesCatalogRequested());
    
    Specialty? selectedSpec;
    SubSpecialty? selectedSub;
    List<Specialty> specs = [];
    List<SubSpecialty> subs = [];
    bool isLoadingSpecs = true;
    bool isLoadingSubs = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileSpecialtiesCatalogLoaded) {
                setModalState(() {
                  specs = state.specialties;
                  isLoadingSpecs = false;
                });
              }
              if (state is ProfileSubSpecialtiesCatalogLoaded) {
                setModalState(() {
                  subs = state.subSpecialties;
                  isLoadingSubs = false;
                });
              }
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Asignar Especialidad', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 20),
                  const Text('Especialidad', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Specialty>(
                    value: selectedSpec,
                    hint: const Text('Selecciona una especialidad'),
                    items: specs.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                    onChanged: (v) {
                      setModalState(() {
                        selectedSpec = v;
                        selectedSub = null;
                        subs = [];
                        if (v != null) {
                          isLoadingSubs = true;
                          context.read<ProfileBloc>().add(FetchSubSpecialtiesCatalogRequested(v.id));
                        }
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: isLoadingSpecs ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2))) : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Sub-Especialidad (Opcional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SubSpecialty>(
                    value: selectedSub,
                    hint: const Text('Selecciona una sub-especialidad'),
                    items: subs.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                    onChanged: selectedSpec != null ? (v) => setModalState(() => selectedSub = v) : null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: isLoadingSubs ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2))) : null,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedSpec == null ? null : () {
                        context.read<ProfileBloc>().add(AssignSpecialtyRequested(selectedSpec!.id, subSpecialtyId: selectedSub?.id));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Asignar Especialidad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
