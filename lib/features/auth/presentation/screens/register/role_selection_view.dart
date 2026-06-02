import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/registration/registration_bloc.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        if (state.status == RegistrationStatus.loading && state.roles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecciona tu perfil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '¿Cómo usarás MedSuite?',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: state.roles.length,
                  itemBuilder: (context, index) {
                    final role = state.roles[index];
                    final isSelected = state.rolId == role.id;
                    final isDoctor = role.tipo.toLowerCase() == 'doctor' || role.nombre.toLowerCase().contains('médico');

                    return GestureDetector(
                      onTap: () => context.read<RegistrationBloc>().add(SelectRole(role.id)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                              child: Icon(
                                isDoctor ? Icons.medical_services_outlined : Icons.person_outline,
                                size: 30,
                                color: isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role.nombre,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    isDoctor ? 'Gestiona tus consultas y pacientes' : 'Accede a tu historial y citas',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.read<RegistrationBloc>().add(PreviousStep()),
                      child: const Text('Anterior'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.rolId == null || state.status == RegistrationStatus.loading
                          ? null
                          : () => context.read<RegistrationBloc>().add(FinalizeRegistration()),
                      child: state.status == RegistrationStatus.loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Finalizar Registro'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
