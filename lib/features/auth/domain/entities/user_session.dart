import 'package:equatable/equatable.dart';
import '../../../appointments/domain/entities/clinic.dart';

class UserSession extends Equatable {
  final int? userId;
  final int? roleId;
  final int? activeClinicId;
  final String? fullName;
  final String? activeClinicName;
  final String? token;
  final String? tokenTemporal;
  final bool needsRole;
  final bool needsClinic;
  final bool needsClinicCreation;
  final List<Map<String, dynamic>>? roles;
  final List<Clinic>? clinics;

  const UserSession({
    this.userId,
    this.roleId,
    this.activeClinicId,
    this.fullName,
    this.activeClinicName,
    this.token,
    this.tokenTemporal,
    this.needsRole = false,
    this.needsClinic = false,
    this.needsClinicCreation = false,
    this.roles,
    this.clinics,
  });

  @override
  List<Object?> get props => [
        userId,
        roleId,
        activeClinicId,
        fullName,
        activeClinicName,
        token,
        tokenTemporal,
        needsRole,
        needsClinic,
        needsClinicCreation,
        roles,
        clinics,
      ];
}
