
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../models/register_request.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        RegisterRequest(
          nombre: _nameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColors.success, size: 52),
          title: const Text('¡Cuenta creada!'),
          content: const Text(
            'Tu registro se completó correctamente. Ahora puedes iniciar sesión en HoodVoice Cartagena.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.white,
              ),
              child: const Text('CONTINUAR'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado. Inténtalo nuevamente.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.darkBlue),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.lightGray,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x140B2139),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Únete a HoodVoice',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Crea tu cuenta para registrar solicitudes de tu comunidad.',
                        style: TextStyle(color: AppColors.muted, height: 1.45),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        enabled: !_loading,
                        textCapitalization: TextCapitalization.words,
                        decoration: _decoration('Nombre completo', Icons.badge_outlined),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Escribe tu nombre completo.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _usernameController,
                        enabled: !_loading,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration('Nombre de usuario', Icons.person_outline),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'El nombre de usuario es obligatorio.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        enabled: !_loading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration('Correo electrónico', Icons.email_outlined),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Escribe tu correo electrónico.';
                          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                            return 'Escribe un correo electrónico válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !_loading,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.next,
                        decoration: _decoration(
                          'Contraseña',
                          Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 4) {
                            return 'La contraseña debe tener al menos 4 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: !_loading,
                        obscureText: _hideConfirmation,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _register(),
                        decoration: _decoration(
                          'Confirmar contraseña',
                          Icons.lock_reset_outlined,
                          suffix: IconButton(
                            onPressed: () => setState(() => _hideConfirmation = !_hideConfirmation),
                            icon: Icon(_hideConfirmation ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Confirma tu contraseña.';
                          if (value != _passwordController.text) return 'Las contraseñas no coinciden.';
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _ErrorPanel(message: _errorMessage!),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
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
                              : const Text(
                                  'CREAR MI CUENTA',
                                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(
                            child: Text('¿Ya tienes una cuenta? ', style: TextStyle(color: AppColors.muted)),
                          ),
                          TextButton(
                            onPressed: _loading ? null : () => Navigator.pop(context),
                            child: const Text(
                              'Inicia sesión',
                              style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tus datos se utilizarán para gestionar tus solicitudes ciudadanas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4),
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

class _ErrorPanel extends StatelessWidget {
  final String message;
  const _ErrorPanel({required this.message});

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
          const Icon(Icons.error_outline, color: AppColors.danger, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppColors.danger, fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
