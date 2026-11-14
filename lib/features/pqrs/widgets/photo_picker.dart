
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';

class PhotoPicker extends StatelessWidget {
  final XFile? photo;
  final ValueChanged<XFile?> onPhotoSelected;
  final bool enabled;

  const PhotoPicker({
    super.key,
    required this.photo,
    required this.onPhotoSelected,
    this.enabled = true,
  });

  Future<void> _takePhoto(BuildContext context) async {
    if (!enabled) return;

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );

      if (image == null || !context.mounted) return;

      final size = await image.length();
      if (!context.mounted) return;

      if (size > ApiConstants.maxPhotoBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La fotografía supera el límite de 10 MB. Toma otra foto.'),
          ),
        );
        return;
      }

      onPhotoSelected(image);
    } on PlatformException catch (error) {
      if (!context.mounted) return;
      final message = error.code.toLowerCase().contains('permission')
          ? 'Debes permitir el acceso a la cámara para tomar una fotografía.'
          : 'No fue posible abrir la cámara. Comprueba que esté disponible e inténtalo nuevamente.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible obtener la fotografía. Inténtalo nuevamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1B8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: AppColors.navy),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Evidencia fotográfica',
                  style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              const Text('OPCIONAL', style: TextStyle(color: AppColors.muted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.7)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Adjunta una imagen del problema que estás reportando. En Android se abrirá la cámara del dispositivo.',
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 15),
          if (photo != null) ...[
            FutureBuilder<Uint8List>(
              future: photo!.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('No se pudo mostrar la fotografía seleccionada.');
                }
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.memory(
                    snapshot.data!,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: enabled ? () => _takePhoto(context) : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Repetir foto'),
                ),
                TextButton.icon(
                  onPressed: enabled ? () => onPhotoSelected(null) : null,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Quitar foto'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                ),
              ],
            ),
            Text(
              photo!.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ] else
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: enabled ? () => _takePhoto(context) : null,
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text('TOMAR FOTOGRAFÍA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.navy,
                  disabledBackgroundColor: AppColors.yellowLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
