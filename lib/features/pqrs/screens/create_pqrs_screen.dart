
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/models/auth_response.dart';
import '../models/pqrs_request.dart';
import '../services/pqrs_service.dart';
import '../widgets/photo_picker.dart';

class CreatePqrsScreen extends StatefulWidget {
  final AuthResponse user;

  const CreatePqrsScreen({super.key, required this.user});

  @override
  State<CreatePqrsScreen> createState() => _CreatePqrsScreenState();
}

class _CreatePqrsScreenState extends State<CreatePqrsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final PqrsService _pqrsService = PqrsService();

  String? _type;
  XFile? _photo;
  bool _submitting = false;
  String? _errorMessage;

  static const List<Map<String, String>> _types = [
    {'value': 'PETICION', 'label': 'Petición'},
    {'value': 'QUEJA', 'label': 'Queja'},
    {'value': 'RECLAMO', 'label': 'Reclamo'},
    {'value': 'SUGERENCIA', 'label': 'Sugerencia'},
    {'value': 'FELICITACION', 'label': 'Felicitación'},
    {'value': 'DENUNCIA', 'label': 'Denuncia'},
  ];

  @override
  void initState() {
    super.initState();
    _recoverInterruptedCameraResult();
  }

  Future<void> _recoverInterruptedCameraResult() async {
    try {
      final response = await ImagePicker().retrieveLostData();
      if (!mounted || response.isEmpty) return;

      final files = response.files;
      if (files != null && files.isNotEmpty) {
        setState(() => _photo = files.first);
      } else if (response.exception != null) {
        setState(() {
          _errorMessage = 'No se pudo recuperar la fotografía anterior. Puedes tomarla nuevamente.';
        });
      }
    } catch (_) {
      // La recuperación no debe impedir que el formulario se abra.
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_submitting || !_formKey.currentState!.validate()) return;

    if (widget.user.id.isEmpty || widget.user.token.isEmpty) {
      setState(() => _errorMessage = 'La sesión no está disponible. Vuelve a iniciar sesión.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final result = await _pqrsService.crearPQRS(
        solicitud: PqrsRequest(
          tipo: _type!,
          descripcion: _descriptionController.text.trim(),
          usuarioId: widget.user.id,
          archivo: _photo,
        ),
        token: widget.user.token,
      );

      if (!mounted) return;
      final reference = result['id'] ?? result['_id'] ?? result['codigoPQRS'];

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 54),
          title: const Text('¡PQRS registrada!'),
          content: Text(
            reference != null
                ? 'Tu solicitud fue recibida correctamente.\n\nCódigo: $reference'
                : 'Tu solicitud fue recibida correctamente por HoodVoice Cartagena.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: AppColors.white),
              child: const Text('FINALIZAR'),
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
        _errorMessage = 'Ocurrió un error inesperado. Tus datos siguen en el formulario; intenta enviar nuevamente.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.lightGray,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E6EC)),
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
        title: const Text('Nueva PQRS', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(color: Color(0x120B2139), blurRadius: 25, offset: Offset(0, 10)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Registrar una solicitud',
                        style: TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Hola, ${widget.user.nombre.isEmpty ? widget.user.username : widget.user.nombre}. Cuéntanos qué sucede en tu comunidad.',
                        style: const TextStyle(color: AppColors.muted, height: 1.45),
                      ),
                      const SizedBox(height: 25),
                      const _FieldLabel(label: 'Tipo de solicitud'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        isExpanded: true,
                        decoration: _fieldDecoration('Selecciona una categoría'),
                        items: _types.map((item) => DropdownMenuItem<String>(
                          value: item['value'],
                          child: Text(item['label']!),
                        )).toList(),
                        onChanged: _submitting ? null : (value) => setState(() => _type = value),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Selecciona el tipo de solicitud.'
                            : null,
                      ),
                      const SizedBox(height: 21),
                      const _FieldLabel(label: 'Descripción del problema'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        enabled: !_submitting,
                        maxLines: 5,
                        minLines: 4,
                        maxLength: 4000,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _fieldDecoration('Describe la situación que deseas reportar...'),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Escribe una descripción.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      PhotoPicker(
                        photo: _photo,
                        enabled: !_submitting,
                        onPhotoSelected: (image) => setState(() => _photo = image),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 17),
                        _RetryMessage(message: _errorMessage!),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _submitting ? null : _submit,
                          icon: _submitting
                              ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.navy))
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            _submitting ? 'ENVIANDO SOLICITUD...' : (_errorMessage == null ? 'ENVIAR PQRS' : 'REINTENTAR ENVÍO'),
                            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.7),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            foregroundColor: AppColors.navy,
                            disabledBackgroundColor: AppColors.yellowLight,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'HOODVOICE CARTAGENA',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 10),
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

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 13),
      );
}

class _RetryMessage extends StatelessWidget {
  final String message;
  const _RetryMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E2),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFF0D78B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFF8A6412), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$message\n\nNo hemos borrado la descripción ni la fotografía. Corrige la conexión y vuelve a intentarlo.',
              style: const TextStyle(color: Color(0xFF684C12), fontSize: 12, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
