import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo MedSuite en el centro del Splash
            Image.asset(
              'assets/images/logo_medsuite.png',
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.health_and_safety_rounded, color: primaryBlue, size: 80);
              },
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: primaryBlue,
              strokeWidth: 3,
            ),
            const SizedBox(height: 48),
            Text(
              'MedSuite CMO',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
