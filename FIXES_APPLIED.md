# HoodVoice Mobile - correcciones aplicadas

1. Se movió `PqrsRequest` a `lib/features/pqrs/models/pqrs_request.dart`, que es la ruta importada por la pantalla y el servicio de PQRS.
2. Se eliminó la definición duplicada de `PqrsRequest` dentro de `pqrs_service.dart`; el servicio importa el modelo único.
3. Se agregó el permiso `android.permission.INTERNET` al manifiesto principal de Android para que las compilaciones de la aplicación puedan consumir la API.
4. Se conservaron las demás pantallas, estilos y funciones del mini proyecto.

Después de reemplazar el proyecto local por esta versión, ejecutar:

```bash
flutter pub get
flutter analyze
flutter test
```
