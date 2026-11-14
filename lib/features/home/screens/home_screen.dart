
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/models/auth_response.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/register_screen.dart';
import '../../pqrs/screens/create_pqrs_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Se conserva la imagen de portada utilizada por el Home.css del proyecto web.
  static const String backgroundImage =
      'https://images.unsplash.com/photo-1534943441045-1009d7cb0bb9?auto=format&fit=crop&w=2000&q=90';

  Future<void> _openRegister(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (!context.mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Ahora puedes iniciar sesión.')),
      );
    }
  }

  Future<void> _openLogin(BuildContext context) async {
    final user = await Navigator.of(context).push<AuthResponse>(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (!context.mounted || user == null) return;

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreatePqrsScreen(user: user)),
    );
    if (!context.mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Tu PQRS fue registrada exitosamente!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 520;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.darkBlue, Color(0xFF081729)],
              ),
            ),
          ),
          Image.network(
            backgroundImage,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const SizedBox.expand(),
            errorBuilder: (_, _, _) => const SizedBox.expand(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.navy.withValues(alpha: 0.97),
                  AppColors.navy.withValues(alpha: 0.88),
                  AppColors.navy.withValues(alpha: 0.70),
                ],
              ),
            ),
          ),
          Positioned(
            top: -130,
            right: -95,
            child: Container(
              height: compact ? 280 : 420,
              width: compact ? 280 : 420,
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.yellow.withValues(alpha: 0.18), width: 1.5),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 30, vertical: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 24 : 54,
                          vertical: compact ? 34 : 48,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.40),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x66000000), blurRadius: 45, offset: Offset(0, 20)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: compact ? 76 : 92,
                              width: compact ? 76 : 92,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.95),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.yellow, width: 2),
                              ),
                              child: Image.asset(
                                'assets/images/hoodvoice-symbol.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.record_voice_over_rounded,
                                  color: AppColors.navy,
                                  size: 44,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [AppColors.yellow, AppColors.white],
                              ).createShader(bounds),
                              child: Text(
                                'HOODVOICE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: compact ? 39 : 58,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: compact ? 2 : 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'C A R T A G E N A',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: compact ? 13 : 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Tu voz construye una mejor Cartagena.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: compact ? 17 : 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'Registra peticiones, quejas, reclamos y sugerencias de tu comunidad de forma sencilla.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFFD5DEE8), height: 1.55, fontSize: 13),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: () => _openRegister(context),
                                icon: const Icon(Icons.person_add_alt_1_rounded),
                                label: const Text('CREAR CUENTA'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.yellow,
                                  foregroundColor: AppColors.navy,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton.icon(
                                onPressed: () => _openLogin(context),
                                icon: const Icon(Icons.login_rounded),
                                label: const Text('YA TENGO UNA CUENTA'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                  side: BorderSide(color: AppColors.white.withValues(alpha: 0.65)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 26),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 18,
                              runSpacing: 10,
                              children: const [
                                _TrustItem(icon: Icons.verified_user_outlined, label: 'Acceso personal'),
                                _TrustItem(icon: Icons.camera_alt_outlined, label: 'Evidencia fotográfica'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              'HOODVOICE CARTAGENA  •  UNA VOZ PARA TU COMUNIDAD',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.yellow, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFFD8E0E8), fontSize: 11)),
        ],
      );
}
