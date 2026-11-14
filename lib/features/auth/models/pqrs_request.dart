
import 'package:image_picker/image_picker.dart';

class PqrsRequest {
  final String tipo;
  final String descripcion;
  final String usuarioId;
  final XFile? archivo;

  const PqrsRequest({
    required this.tipo,
    required this.descripcion,
    required this.usuarioId,
    this.archivo,
  });
}
