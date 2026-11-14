
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop<AuthResponse>(user);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Ocurrió un error inesperado. Inténtalo nuevamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.darkBlue),
      filled: true,
      fillColor: AppColors.lightGray,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E7ED)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.yellow, width: 2),
      ),
    );
  }

  Future<void> _openRegister() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );

    if (!mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Ya puedes iniciar sesión.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text('HoodVoice Cartagena'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 28, offset: Offset(0, 12)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/hoodvoice-symbol.png',
                          height: 76,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.record_voice_over_rounded,
                            size: 62,
                            color: AppColors.yellow,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bienvenido de nuevo',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.navy, fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Ingresa tus datos para continuar en HoodVoice.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, height: 1.4),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _usernameController,
                        enabled: !_loading,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration('Nombre de usuario', Icons.person_outline),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Ingresa tu nombre de usuario.'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !_loading,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        decoration: _decoration('Contraseña', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Ingresa tu contraseña.'
                            : null,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _LoginError(message: _errorMessage!),
                      ],
                      const SizedBox(height: 23),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            foregroundColor: AppColors.navy,
                            disabledBackgroundColor: AppColors.yellowLight,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.navy),
                                )
                              : const Text('INGRESAR', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('¿Todavía no tienes cuenta? ', style: TextStyle(color: AppColors.muted)),
                          TextButton(
                            onPressed: _loading ? null : _openRegister,
                            child: const Text('Crear cuenta', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Tu información de acceso se utiliza para validar tu cuenta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginError extends StatelessWidget {
  final String message;
  const _LoginError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5C2BE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 19, color: AppColors.danger),
          const SizedBox(width: 9),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.danger, fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }
}
