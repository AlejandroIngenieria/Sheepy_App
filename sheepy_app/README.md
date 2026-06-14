# sheepy_app

Aprende a leer la Biblia con ovejas, capítulos y quizzes estilo Duolingo.

## Requisitos previos

Para levantar y ejecutar este proyecto, necesitas tener instaladas las siguientes herramientas en tu sistema:

- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (versión `^3.12.1`). Asegúrate de que `flutter` esté agregado a las variables de entorno (PATH) de tu sistema.
- **Dart SDK**: Viene incluido con Flutter.
- Un IDE como **Visual Studio Code** o **Android Studio** con las extensiones de Flutter y Dart instaladas.
- Un emulador (Android/iOS) configurado, o un dispositivo físico conectado.

### Solución de problemas: `flutter: command not found`
Si al intentar ejecutar un comando obtienes el error de que el comando `flutter` no se reconoce, esto significa que Flutter no está instalado o no está en tu PATH:
1. Sigue las instrucciones de la [documentación oficial](https://docs.flutter.dev/get-started/install/windows) para descargar e instalar Flutter en Windows.
2. Agrega la ruta de la carpeta `bin` de tu instalación de Flutter a la variable de entorno `PATH`.
3. Reinicia tu terminal o tu IDE para que los cambios tengan efecto.
4. Ejecuta `flutter doctor` para verificar que tu entorno esté correctamente configurado.

## Instalación y Ejecución

1. **Abrir el proyecto**
   Abre la carpeta de este proyecto en tu IDE preferido o navega hasta ella en tu terminal.

2. **Instalar dependencias**
   Abre una terminal en la raíz del proyecto y descarga las dependencias ejecutando:
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   Asegúrate de tener un emulador abierto o un dispositivo conectado. Luego, ejecuta:
   ```bash
   flutter run
   ```

## Dependencias principales

Este proyecto utiliza las siguientes librerías clave según el archivo `pubspec.yaml`:
- [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod): Manejo de estado de la aplicación.
- [`http`](https://pub.dev/packages/http): Cliente para realizar peticiones de red y conectar con APIs.
- [`shared_preferences`](https://pub.dev/packages/shared_preferences): Almacenamiento local persistente en el dispositivo.
- [`google_fonts`](https://pub.dev/packages/google_fonts): Uso de tipografías dinámicas y personalizadas.
- [`lottie`](https://pub.dev/packages/lottie): Renderizado de animaciones vectoriales complejas.
