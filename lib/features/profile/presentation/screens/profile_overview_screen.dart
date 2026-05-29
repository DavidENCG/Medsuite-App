import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_bloc.dart';
import '../../domain/entities/profile.dart';
import '../../../../core/utils/medsuite_toast.dart';

class ProfileOverviewScreen extends StatefulWidget {
  const ProfileOverviewScreen({super.key});

  @override
  State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(FetchProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Mi Perfil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          if (state is ProfileLoaded) {
            return _buildContent(state.profile);
          }

          return const Center(child: Text('No se pudo cargar el perfil'));
        },
      ),
    );
  }

  Widget _buildContent(Profile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPersonalHeader(profile.personalInfo),
          const SizedBox(height: 20),
          _buildSectionCard(
            title: 'Información Personal',
            icon: Icons.person_outline,
            onEdit: () => context.push('/profile/personal'),
            children: [
              _buildInfoRow('Correo', profile.personalInfo.correo ?? 'No especificado'),
              _buildInfoRow('Teléfono', '${profile.personalInfo.codigoTelefono ?? ''} ${profile.personalInfo.telefono ?? ''}'),
              _buildInfoRow('Ubicación', '${profile.personalInfo.ciudad ?? ''}, ${profile.personalInfo.pais ?? ''}'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Datos Médicos',
            icon: Icons.medical_services_outlined,
            onEdit: () => context.push('/profile/medical'),
            children: [
              _buildInfoRow('MSDS', profile.medicalData.numeroMSDS ?? 'No especificado'),
              _buildInfoRow('Colegio Médico', profile.medicalData.colegioMedico ?? 'No especificado'),
              _buildInfoRow('Universidad', profile.medicalData.universidad ?? 'No especificado'),
              _buildInfoRow('RIF', profile.medicalData.rif ?? 'No especificado'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Especialidades',
            icon: Icons.assignment_outlined,
            onEdit: () => context.push('/profile/specialties'),
            children: [
              if (profile.specialties.isEmpty)
                const Text('Sin especialidades asignadas', style: TextStyle(fontSize: 13, color: Colors.grey))
              else
                ...profile.specialties.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          if (s.subSpecialties.isNotEmpty)
                            Text(
                              s.subSpecialties.map((sub) => sub.nombre).join(', '),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalHeader(PersonalInfo info) {
    const primaryBlue = Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: primaryBlue.withOpacity(0.1),
                backgroundImage: info.fotoUrl != null ? NetworkImage(info.fotoUrl!) : null,
                child: info.fotoUrl == null
                    ? const Icon(Icons.person, size: 50, color: primaryBlue)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFF3BB5AB), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${info.nombre ?? ''} ${info.apellido ?? ''}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            info.tipoIdentificacion != null ? '${info.tipoIdentificacion}: ${info.identificacion ?? ''}' : info.identificacion ?? '',
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: const Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF3BB5AB)),
                onPressed: onEdit,
              ),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
