import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    super.casoId,
    required super.pacienteId,
    required super.pacienteNombre,
    required super.pacienteIdentificacion,
    required super.consultorioId,
    required super.consultorioNombre,
    required super.fechaCita,
    required super.horaCita,
    required super.motivoConsulta,
    required super.estadoId,
    required super.estado,
    required super.atendido,
    super.notas,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['Id'] ?? json['id'],
      casoId: json['CasoId'] ?? json['casoId'],
      pacienteId: json['PacienteId'] ?? json['pacienteId'],
      pacienteNombre: json['PacienteNombre'] ?? json['pacienteNombre'] ?? '',
      pacienteIdentificacion: json['PacienteIdentificacion'] ?? json['pacienteIdentificacion'] ?? '',
      consultorioId: json['ConsultorioId'] ?? json['consultorioId'],
      consultorioNombre: json['ConsultorioNombre'] ?? json['consultorioNombre'] ?? '',
      fechaCita: DateTime.parse(json['FechaCita'] ?? json['fechaCita']),
      horaCita: json['HoraCita'] ?? json['horaCita'] ?? '',
      motivoConsulta: json['MotivoConsulta'] ?? json['motivoConsulta'] ?? '',
      estadoId: json['EstadoId'] ?? json['estadoId'],
      estado: json['Estado'] ?? json['estado'] ?? '',
      atendido: json['Atendido'] ?? json['atendido'] ?? false,
      notas: json['Notas'] ?? json['notas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'casoId': casoId,
      'pacienteId': pacienteId,
      'pacienteNombre': pacienteNombre,
      'pacienteIdentificacion': pacienteIdentificacion,
      'consultorioId': consultorioId,
      'consultorioNombre': consultorioNombre,
      'fechaCita': fechaCita.toIso8601String(),
      'horaCita': horaCita,
      'motivoConsulta': motivoConsulta,
      'estadoId': estadoId,
      'estado': estado,
      'atendido': atendido,
      'notas': notas,
    };
  }

  AppointmentModel copyWith({
    int? estadoId,
    String? estado,
    bool? atendido,
    String? notas,
  }) {
    return AppointmentModel(
      id: id,
      casoId: casoId,
      pacienteId: pacienteId,
      pacienteNombre: pacienteNombre,
      pacienteIdentificacion: pacienteIdentificacion,
      consultorioId: consultorioId,
      consultorioNombre: consultorioNombre,
      fechaCita: fechaCita,
      horaCita: horaCita,
      motivoConsulta: motivoConsulta,
      estadoId: estadoId ?? this.estadoId,
      estado: estado ?? this.estado,
      atendido: atendido ?? this.atendido,
      notas: notas ?? this.notas,
    );
  }
}
