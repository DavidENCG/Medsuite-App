import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medsuite_cmo/core/di/injection_container.dart';
import '../../bloc/registration/registration_bloc.dart';
import 'identity_view.dart';
import 'role_selection_view.dart';
import 'success_view.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RegistrationBloc>()..add(LoadIdentificationTypes()),
      child: BlocListener<RegistrationBloc, RegistrationState>(
        listenWhen: (previous, current) => previous.currentStep != current.currentStep,
        listener: (context, state) {
          _pageController.animateToPage(
            state.currentStep,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Registro de Usuario'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: BlocBuilder<RegistrationBloc, RegistrationState>(
                builder: (context, state) {
                  return LinearProgressIndicator(
                    value: (state.currentStep + 1) / 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  );
                },
              ),
            ),
          ),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              IdentityView(),
              Center(child: CircularProgressIndicator()), // Transición/Validación
              RoleSelectionView(),
              SuccessView(),
            ],
          ),
        ),
      ),
    );
  }
}
