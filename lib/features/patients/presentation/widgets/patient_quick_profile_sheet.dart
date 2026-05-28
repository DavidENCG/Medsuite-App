import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/medsuite_toast.dart';
import '../../domain/entities/patient.dart';

class PatientQuickProfileSheet extends StatelessWidget {
  final Patient patient;

  const PatientQuickProfileSheet({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra superior de cierre
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header Perfil
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: primaryBlue.withValues(alpha: 0.1),
                child: Text(
                  patient.nombreCompleto.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nombreCompleto,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    Text(
                      'Cédula: ${patient.identificacion}',
                      style: GoogleFonts.inter(color: textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Acciones Rápidas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickAction(
                icon: Icons.phone_outlined,
                label: 'Llamar',
                onTap: () => MedSuiteToast.show(context, message: 'Iniciando llamada...'),
              ),
              _QuickAction(
                icon: Icons.chat_outlined,
                label: 'WhatsApp',
                onTap: () => MedSuiteToast.show(context, message: 'Abriendo chat...'),
              ),
              _QuickAction(
                icon: Icons.email_outlined,
                label: 'Correo',
                onTap: () => MedSuiteToast.show(context, message: 'Redactando email...'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Información Adicional
          Text(
            'DATOS CLÍNICOS RÁPIDOS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textLight,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(label: 'Edad: ${patient.edad ?? "N/A"}'),
              const SizedBox(width: 8),
              _InfoChip(
                label: patient.tieneHistoria ? 'Historia Activa' : 'Sin Historia',
                color: patient.tieneHistoria ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Acciones de Gestión
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/patient/edit', extra: patient.usuarioId);
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  label: const Text('Editar Perfil'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: primaryBlue.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/cases', extra: {
                      'patientId': patient.usuarioId,
                      'patientName': patient.nombreCompleto,
                    });
                  },
                  icon: const Icon(Icons.folder_open_rounded, size: 20),
                  label: const Text('Casos / Citas'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: primaryBlue.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Botón Principal
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/patient/history', extra: {
                'patientId': patient.usuarioId,
                'patientName': patient.nombreCompleto,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Ver Historia Clínica Completa',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          icon: Icon(icon, color: const Color(0xFF2563EB)),
          padding: const EdgeInsets.all(16),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color? color;

  const _InfoChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: baseColor,
        ),
      ),
    );
  }
}
