class RegistrationValidation {
  final bool existe;
  final bool emailExiste;

  const RegistrationValidation({
    required this.existe,
    required this.emailExiste,
  });

  bool get isAvailable => !existe && !emailExiste;
}
