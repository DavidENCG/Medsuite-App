import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final int appointmentsToday;
  final int newPatientsThisMonth;
  final int pendingMedicalRecords;
  final double monthlyRevenue;
  final List<Map<String, dynamic>> upcomingAppointments;

  const DashboardSummary({
    this.appointmentsToday = 0,
    this.newPatientsThisMonth = 0,
    this.pendingMedicalRecords = 0,
    this.monthlyRevenue = 0.0,
    this.upcomingAppointments = const [],
  });

  @override
  List<Object?> get props => [
        appointmentsToday,
        newPatientsThisMonth,
        pendingMedicalRecords,
        monthlyRevenue,
        upcomingAppointments,
      ];
}
