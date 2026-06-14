import 'dart:io';

import 'package:flutter/foundation.dart';

/// URL base de la API RV1909 local.
///
/// - Escritorio / iOS simulador: `localhost:3000`
/// - Emulador Android: `10.0.2.2:3000`
/// - Dispositivo físico: `flutter run --dart-define=BIBLE_API_HOST=192.168.1.10`
class ApiConfig {
  ApiConfig._();

  static const _port = 3000;

  static String get bibleBaseUrl {
    const hostOverride = String.fromEnvironment('BIBLE_API_HOST');
    if (hostOverride.isNotEmpty) {
      return 'http://$hostOverride:$_port';
    }

    if (kIsWeb) return 'http://localhost:$_port';

    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:$_port';
    }

    return 'http://localhost:$_port';
  }

  static Uri chapterUri(int bookNumber, int chapter) => Uri.parse(
        '$bibleBaseUrl/api/book/$bookNumber/chapter/$chapter',
      );
}
