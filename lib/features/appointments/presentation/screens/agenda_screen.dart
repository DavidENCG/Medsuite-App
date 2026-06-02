import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/medsuite_toast.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/appointment_bloc.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late DateTime _selectedDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _refreshAppointments();
  }

  void _refreshAppointments() {
    context.read<AppointmentBloc>().add(FetchAppointmentsByDate(_selectedDate));
  }

  Color _getStatusColor(int estadoId) {
    switch (estadoId) {
      case 2: // Atendido
      case 6: // Completado
        return const Color(0xFF10B981); // Verde
      case 1: // En Espera
        return const Color(0xFF2563EB); // Azul
      case 4: // Pendiente
        return const Color(0xFFEAB308); // Amarillo
      default:
        return const Color(0xFF94A3B8); // Otros - Gris
    }
  }

  Widget _buildCalendarCarousel() {
    final now = DateTime.now();
    final primaryColor = Theme.of(context).primaryColor;
    // Iniciar desde hoy para que sea el primer slot
    final days = List.generate(30, (index) => now.add(Duration(days: index)));

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (context, index) {
          final day = days[index];
          // Normalizar fechas para comparación precisa (sin horas)
          final normalizedDay = DateTime(day.year, day.month, day.day);
          final normalizedSelected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
          final normalizedToday = DateTime(now.year, now.month, now.day);

          final isSelected = normalizedDay.isAtSameMomentAs(normalizedSelected);
          final isToday = normalizedDay.isAtSameMomentAs(normalizedToday);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
              context.read<AppointmentBloc>().add(FetchAppointmentsByDate(day));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade100,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'es').format(day).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  if (isToday && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    String doctorName = 'Médico';
    String clinicName = 'Consultorio';

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      doctorName = authState.fullName ?? 'Médico';
      clinicName = authState.activeClinicName ?? 'Consultorio';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header Dinámico Fase 3
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agenda',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '$doctorName • $clinicName',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<AppointmentBloc>().add(SyncOfflineChanges());
                      MedSuiteToast.show(context, message: "Sincronizando...", type: ToastType.info);
                    },
                    icon: Icon(Icons.sync_rounded, color: Theme.of(context).primaryColor),
                    tooltip: 'Sincronizar cambios',
                  ),
                ],
              ),
            ),

            _buildCalendarCarousel(),

            // Banner Offline
            BlocBuilder<AppointmentBloc, AppointmentState>(
              builder: (context, state) {
                if (state is AppointmentsLoaded && state.isOffline) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.amber.shade700,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Modo Sin Conexión - Datos Locales',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            
            Expanded(
              child: BlocBuilder<AppointmentBloc, AppointmentState>(
                builder: (context, state) {
                  if (state is AppointmentsLoaded) {
                    // Actualizar fecha seleccionada si el estado cambia externamente
                    if (state.selectedDate != _selectedDate) {
                      _selectedDate = state.selectedDate;
                    }
                  }

                  if (state is AppointmentsLoading) {
                    return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
                  }

                  if (state is AppointmentsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text('Error al cargar la agenda', style: GoogleFonts.poppins(fontSize: 16)),
                          TextButton(
                            onPressed: () => context.read<AppointmentBloc>().add(FetchAppointmentsByDate(_selectedDate)),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AppointmentsLoaded) {
                    if (state.appointments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No hay citas programadas para el ${DateFormat('dd/MM/yyyy').format(state.selectedDate)}', 
                              style: GoogleFonts.inter(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<AppointmentBloc>().add(FetchAppointmentsByDate(_selectedDate));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: state.appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = state.appointments[index];
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Dismissible(
                              key: Key(appointment.id.toString()),
                              direction: DismissDirection.startToEnd,
                              background: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.check_circle, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                context.read<AppointmentBloc>().add(
                                  UpdateAppointmentStatus(
                                    citaId: appointment.id,
                                    nuevoEstadoId: 2, // Atendido
                                    notas: 'Atendido vía App Móvil',
                                  ),
                                );
                                MedSuiteToast.show(context, message: "Paciente marcado como Atendido", type: ToastType.success);
                                return false; 
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  onTap: () {
                                    context.push('/consultation', extra: {
                                      'citaId': appointment.id,
                                      'patientName': appointment.pacienteNombre,
                                    });
                                  },
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(appointment.estadoId).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        appointment.horaCita.substring(0, 5),
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(appointment.estadoId),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    appointment.pacienteNombre,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(appointment.motivoConsulta, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(appointment.estadoId).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          appointment.estado,
                                          style: TextStyle(
                                            color: _getStatusColor(appointment.estadoId),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_left, color: Color(0xFFCBD5E1)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
