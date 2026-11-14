
# HoodVoice Mobile

Mini aplicación móvil en Flutter para demostrar el acceso ciudadano y el registro de PQRS con evidencia fotográfica.

## Alcance

- Portada con identidad visual azul oscuro y amarillo de HoodVoice Cartagena.
- Registro de ciudadanos mediante el endpoint existente.
- Inicio de sesión mediante JWT.
- Formulario de creación de PQRS.
- Captura/selección de fotografía y vista previa.
- Envío de la solicitud como `multipart/form-data` al backend.
- Validación de formularios, tamaño de fotografía y manejo de errores de red/servidor.

## Backend utilizado

Base URL: `https://hoodvoice-api.onrender.com`

| Operación | Método | Endpoint |
|---|---|---|
| Registro ciudadano | POST | `/test/register` |
| Inicio de sesión | POST | `/test/login` |
| Crear PQRS con archivo opcional | POST | `/pqrs` |

El registro envía `nombre`, `username`, `email` y `password`. El backend asigna el rol público `USER` y el estado `ACTIVO`.

El inicio de sesión envía `username` y `password`, y espera `id`, `token`, `username`, `nombre` y `role`.

La creación de PQRS envía `tipo`, `descripcion`, `usuarioId` y `archivo` opcional, junto con `Authorization: Bearer <token>`.

## Preparar el proyecto

Requiere Flutter/Dart compatible con las restricciones de `pubspec.yaml` y Android Studio/SDK Android.

```bash
flutter pub get
flutter analyze
flutter test
```

## Ejecutar en Chrome (pruebas de interfaz)

```bash
flutter run -d chrome
```

En Chrome/PC, `image_picker` puede abrir el selector de archivos del navegador. Eso no demuestra la cámara nativa.

## Ejecutar en Android (prueba real de cámara)

1. Activa las opciones de desarrollador y la depuración USB en el teléfono.
2. Conecta el teléfono y autoriza la depuración.
3. Comprueba el dispositivo:

```bash
flutter devices
```

4. Ejecuta la aplicación:

```bash
flutter run -d <ID_DEL_DISPOSITIVO>
```

En Android, el botón de evidencia usa `ImageSource.camera` para solicitar la cámara del dispositivo.

## APK de demostración

```bash
flutter build apk --release
```

El APK se genera normalmente en `build/app/outputs/flutter-apk/app-release.apk`.

## Manejo de fallos de conexión

- La app utiliza HTTPS hacia el backend desplegado.
- Las peticiones tienen límites de tiempo y mensajes para falta de conexión, timeout, errores HTTP y respuestas inesperadas. El primer acceso puede tardar más cuando el servicio desplegado estuvo inactivo; por eso el login/registro espera hasta 90 segundos y el envío de PQRS hasta 120 segundos.
- Si falla el envío de una PQRS, el formulario no se limpia: mantiene en pantalla el tipo, la descripción y la fotografía para que el ciudadano pueda corregir la conexión y pulsar **Reintentar envío**.
- Se consulta `ImagePicker.retrieveLostData()` al entrar al formulario para intentar recuperar una foto si Android destruyó la actividad durante la captura.
- La información pendiente se conserva mientras la pantalla del formulario siga abierta. No se guarda como borrador permanente al cerrar la aplicación.
- La disponibilidad de Internet no garantiza que el backend esté activo; se valida el resultado real de cada petición.

## Consideraciones de despliegue

- `android/app/src/main/AndroidManifest.xml` incluye el permiso `INTERNET`.
- La URL de la API está centralizada en `lib/core/constants/api_constants.dart`.
- El límite de fotografía del cliente se mantiene en 10 MB, alineado con el límite documentado en el backend.
- El registro público usa el endpoint existente `/test/register`; no se envía un rol privilegiado.
- Esta versión está enfocada al flujo ciudadano y no incluye panel administrativo.

## Nota sobre archivos del backend

El backend recibido guarda las fotografías en el directorio configurado por `app.upload-dir` y almacena el nombre del archivo en la PQRS. En un despliegue con almacenamiento efímero del servidor, conviene revisar posteriormente un almacenamiento persistente de archivos. Para la demostración, la app reutiliza el contrato actual del backend sin cambiarlo.
