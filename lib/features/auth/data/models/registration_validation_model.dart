import '../../domain/entities/registration_validation.dart';

class RegistrationValidationModel extends RegistrationValidation {
  const RegistrationValidationModel({
    required super.existe,
    required super.emailExiste,
  });

  factory RegistrationValidationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationValidationModel(
      existe: json['existe'] ?? json['Existe'] ?? false,
      emailExiste: json['emailExiste'] ?? json['EmailExiste'] ?? false,
    );
  }
}
