import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_catalog.dart';
import '../../../../core/utils/json_utils.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.personalInfo,
    required super.medicalData,
    required super.specialties,
  });

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Imprimir el JSON completo para que el desarrollador pueda verlo en consola
    print('PROFILE_MODEL: Full JSON received: $json');

    final data = _asMap(json['data'] ?? json['Data'] ?? json);
    print('PROFILE_MODEL: Root Keys found: ${data.keys}');
    
    // Buscar la sección personal en múltiples lugares posibles
    final personalJson = _asMap(
      data['personal'] ?? data['Personal'] ?? 
      data['personalInfo'] ?? data['PersonalInfo'] ?? 
      data['usuario'] ?? data['Usuario'] ?? 
      data['user'] ?? data['User']
    );

    // Buscar la sección médica
    final medicalJson = _asMap(
      data['datosMedicos'] ?? data['DatosMedicos'] ?? 
      data['medicalData'] ?? data['MedicalData'] ??
      data['licencia'] ?? data['Licencia']
    );

    return ProfileModel(
      personalInfo: PersonalInfoModel.fromJson(personalJson),
      medicalData: MedicalDataModel.fromJson(medicalJson),
      specialties: (data['especialidades'] as List? ?? data['Especialidades'] as List? ?? data['specialties'] as List? ?? [])
          .map((e) => SpecialtyModel.fromJson(_asMap(e)))
          .toList(),
    );
  }
}

class PersonalInfoModel extends PersonalInfo {
  const PersonalInfoModel({
    super.nombre,
    super.apellido,
    super.identificacion,
    super.tipoIdentificacion,
    super.sexo,
    super.fechaNacimiento,
    super.correo,
    super.telefono,
    super.codigoTelefono,
    super.direccion,
    super.pais,
    super.paisId,
    super.ciudad,
    super.ciudadId,
    super.fotoUrl,
  });

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    // Si la info personal viene dentro de un objeto 'usuario' o 'persona'
    final userMap = (json['usuario'] is Map) ? json['usuario'] : (json['user'] is Map ? json['user'] : json);
    
    String nombre = JsonUtils.forceString(userMap['nombre'] ?? userMap['Nombre'] ?? userMap['nombres'] ?? userMap['Nombres'] ?? userMap['firstName'] ?? userMap['FirstName']);
    String apellido = JsonUtils.forceString(userMap['apellido'] ?? userMap['Apellido'] ?? userMap['apellidos'] ?? userMap['Apellidos'] ?? userMap['lastName'] ?? userMap['LastName']);
    
    if (nombre.isEmpty && (userMap['nombreCompleto'] != null || userMap['NombreCompleto'] != null)) {
      final fullName = JsonUtils.forceString(userMap['nombreCompleto'] ?? userMap['NombreCompleto']);
      final parts = fullName.trim().split(' ');
      if (parts.length > 1) {
        nombre = parts[0];
        apellido = parts.sublist(1).join(' ');
      } else {
        nombre = fullName;
      }
    }

    return PersonalInfoModel(
      nombre: nombre,
      apellido: apellido,
      identificacion: JsonUtils.forceString(userMap['identificacion'] ?? userMap['Identificacion'] ?? userMap['cedula'] ?? userMap['Cedula'] ?? userMap['numIdentificacion'] ?? userMap['NumIdentificacion']),
      tipoIdentificacion: JsonUtils.forceString(userMap['tipoIdentificacion'] ?? userMap['TipoIdentificacion'] ?? userMap['tipoId'] ?? userMap['TipoId']),
      sexo: JsonUtils.forceString(userMap['sexo'] ?? userMap['Sexo'] ?? userMap['genero'] ?? userMap['Genero']),
      fechaNacimiento: JsonUtils.forceString(userMap['fechaNacimiento'] ?? userMap['FechaNacimiento']),
      correo: JsonUtils.forceString(userMap['correo'] ?? userMap['Correo'] ?? userMap['email'] ?? userMap['Email'] ?? userMap['correoElectronico'] ?? userMap['CorreoElectronico']),
      telefono: JsonUtils.forceString(userMap['telefono'] ?? userMap['Telefono'] ?? userMap['celular'] ?? userMap['Celular'] ?? userMap['movil'] ?? userMap['Movil']),
      codigoTelefono: JsonUtils.forceString(userMap['codigoTelefono'] ?? userMap['CodigoTelefono'] ?? userMap['prefijo'] ?? userMap['Prefijo'] ?? userMap['codPais'] ?? userMap['CodPais']),
      direccion: JsonUtils.forceString(userMap['direccion'] ?? userMap['Direccion'] ?? userMap['domicilio'] ?? userMap['Domicilio']),
      pais: JsonUtils.forceString(userMap['pais'] ?? userMap['Pais']),
      paisId: JsonUtils.forceIntNullable(userMap['paisId'] ?? userMap['PaisId']),
      ciudad: JsonUtils.forceString(userMap['ciudad'] ?? userMap['Ciudad']),
      ciudadId: JsonUtils.forceIntNullable(userMap['ciudadId'] ?? userMap['CiudadId']),
      fotoUrl: JsonUtils.forceString(userMap['fotoUrl'] ?? userMap['FotoUrl'] ?? userMap['imagenUrl'] ?? userMap['ImagenUrl'] ?? userMap['pathFoto'] ?? userMap['PathFoto']),
    );
  }

  Map<String, dynamic> toJson({String? password}) {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'identificacion': identificacion,
      'tipoIdentificacion': tipoIdentificacion,
      'sexo': sexo,
      'fechaNacimiento': fechaNacimiento,
      'correo': correo,
      'telefono': telefono,
      'codigoTelefono': codigoTelefono,
      'direccion': direccion,
      'paisId': paisId,
      'ciudadId': ciudadId,
      if (password != null && password.isNotEmpty) 'password': password,
    };
  }
}

class MedicalDataModel extends MedicalData {
  const MedicalDataModel({
    super.colegioMedico,
    super.numeroColegio,
    super.numeroMSDS,
    super.universidad,
    super.anoGraduacion,
    super.rif,
  });

  factory MedicalDataModel.fromJson(Map<String, dynamic> json) {
    return MedicalDataModel(
      colegioMedico: JsonUtils.forceString(json['colegioMedico'] ?? json['ColegioMedico'] ?? json['colegio'] ?? json['Colegio']),
      numeroColegio: JsonUtils.forceString(json['numeroColegio'] ?? json['NumeroColegio'] ?? json['colegiatura'] ?? json['Colegiatura'] ?? json['numColegio'] ?? json['NumColegio']),
      numeroMSDS: JsonUtils.forceString(json['numeroMSDS'] ?? json['NumeroMSDS'] ?? json['msds'] ?? json['MSDS'] ?? json['numMSDS'] ?? json['NumMSDS']),
      universidad: JsonUtils.forceString(json['universidad'] ?? json['Universidad'] ?? json['almaMater'] ?? json['AlmaMater']),
      anoGraduacion: JsonUtils.forceString(json['anoGraduacion'] ?? json['AnoGraduacion'] ?? json['anioGraduacion'] ?? json['AnioGraduacion'] ?? json['graduacion'] ?? json['Graduacion']),
      rif: JsonUtils.forceString(json['rif'] ?? json['Rif'] ?? json['identificacionFiscal'] ?? json['IdentificacionFiscal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colegioMedico': colegioMedico,
      'numeroColegio': numeroColegio,
      'numeroMSDS': numeroMSDS,
      'universidad': universidad,
      'anoGraduacion': anoGraduacion,
      'rif': rif,
    };
  }
}

class SpecialtyModel extends Specialty {
  const SpecialtyModel({
    required super.id,
    required super.nombre,
    super.descripcion,
    super.subSpecialties,
  });

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    // Debug para ver qué llega en cada especialidad
    print('SPECIALTY_MODEL: JSON for one specialty: $json');
    
    return SpecialtyModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id'] ?? json['especialidadId'] ?? json['EspecialidadId']),
      nombre: JsonUtils.forceString(
        json['nombre'] ?? json['Nombre'] ?? 
        json['especialidad'] ?? json['Especialidad'] ?? 
        json['nombreEspecialidad'] ?? json['NombreEspecialidad'] ??
        json['descripcion'] ?? json['Descripcion'], // Fallback a descripción
        defaultValue: 'Sin Nombre'
      ),
      descripcion: JsonUtils.forceString(json['descripcion'] ?? json['Descripcion']),
      subSpecialties: (json['subEspecialidades'] as List? ?? json['SubEspecialidades'] as List? ?? json['subSpecialties'] as List? ?? [])
          .map((e) => SubSpecialtyModel.fromJson(_asMap(e)))
          .toList(),
    );
  }
}

class SubSpecialtyModel extends SubSpecialty {
  const SubSpecialtyModel({
    required super.id,
    required super.nombre,
    required super.parentId,
  });

  factory SubSpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SubSpecialtyModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id'] ?? json['subEspecialidadId'] ?? json['SubEspecialidadId']),
      nombre: JsonUtils.forceString(
        json['nombre'] ?? json['Nombre'] ?? 
        json['subEspecialidad'] ?? json['SubEspecialidad'] ?? 
        json['nombreSubEspecialidad'] ?? json['NombreSubEspecialidad'], 
        defaultValue: 'Sin Nombre'
      ),
      parentId: JsonUtils.forceInt(json['especialidadId'] ?? json['EspecialidadId'] ?? json['parentId'] ?? json['ParentId'] ?? 0),
    );
  }
}

class CatalogItemModel extends CatalogItem {
  const CatalogItemModel({
    required super.id,
    required super.nombre,
    super.extra,
  });

  factory CatalogItemModel.fromJson(Map<String, dynamic> json) {
    return CatalogItemModel(
      id: JsonUtils.forceInt(json['id'] ?? json['Id']),
      nombre: JsonUtils.forceString(json['nombre'] ?? json['Nombre'], defaultValue: 'Sin Nombre'),
      extra: JsonUtils.forceString(json['extra'] ?? json['Extra']),
    );
  }
}

class ProfileCatalogModel extends ProfileCatalog {
  const ProfileCatalogModel({
    required super.idTypes,
    required super.genders,
    required super.countries,
    required super.phoneCodes,
  });

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  factory ProfileCatalogModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json['Data'] ?? json);
    return ProfileCatalogModel(
      idTypes: (data['tiposIdentificacion'] as List? ?? []).map((e) => CatalogItemModel.fromJson(_asMap(e))).toList(),
      genders: (data['sexos'] as List? ?? []).map((e) => CatalogItemModel.fromJson(_asMap(e))).toList(),
      countries: (data['paises'] as List? ?? []).map((e) => CatalogItemModel.fromJson(_asMap(e))).toList(),
      phoneCodes: (data['codigosTelefono'] as List? ?? []).map((e) => CatalogItemModel.fromJson(_asMap(e))).toList(),
    );
  }
}
