import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final PersonalInfo personalInfo;
  final MedicalData medicalData;
  final List<Specialty> specialties;

  const Profile({
    required this.personalInfo,
    required this.medicalData,
    required this.specialties,
  });

  @override
  List<Object?> get props => [personalInfo, medicalData, specialties];
}

class PersonalInfo extends Equatable {
  final String? nombre;
  final String? apellido;
  final String? identificacion;
  final String? tipoIdentificacion;
  final String? sexo;
  final String? fechaNacimiento;
  final String? correo;
  final String? telefono;
  final String? codigoTelefono;
  final String? direccion;
  final String? pais;
  final int? paisId;
  final String? ciudad;
  final int? ciudadId;
  final String? fotoUrl;

  const PersonalInfo({
    this.nombre,
    this.apellido,
    this.identificacion,
    this.tipoIdentificacion,
    this.sexo,
    this.fechaNacimiento,
    this.correo,
    this.telefono,
    this.codigoTelefono,
    this.direccion,
    this.pais,
    this.paisId,
    this.ciudad,
    this.ciudadId,
    this.fotoUrl,
  });

  @override
  List<Object?> get props => [
        nombre,
        apellido,
        identificacion,
        tipoIdentificacion,
        sexo,
        fechaNacimiento,
        correo,
        telefono,
        codigoTelefono,
        direccion,
        pais,
        paisId,
        ciudad,
        ciudadId,
        fotoUrl,
      ];
}

class MedicalData extends Equatable {
  final String? colegioMedico;
  final String? numeroColegio;
  final String? numeroMSDS;
  final String? universidad;
  final String? anoGraduacion;
  final String? rif;

  const MedicalData({
    this.colegioMedico,
    this.numeroColegio,
    this.numeroMSDS,
    this.universidad,
    this.anoGraduacion,
    this.rif,
  });

  @override
  List<Object?> get props => [
        colegioMedico,
        numeroColegio,
        numeroMSDS,
        universidad,
        anoGraduacion,
        rif,
      ];
}

class Specialty extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final List<SubSpecialty> subSpecialties;

  const Specialty({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.subSpecialties = const [],
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, subSpecialties];
}

class SubSpecialty extends Equatable {
  final int id;
  final String nombre;
  final int parentId;

  const SubSpecialty({
    required this.id,
    required this.nombre,
    required this.parentId,
  });

  @override
  List<Object?> get props => [id, nombre, parentId];
}
