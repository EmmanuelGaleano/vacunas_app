// =============================================================================
// api_config.dart
// Decide a qué dirección le habla la app para llegar a la API MyVaccine,
// que corre dentro de Docker en el puerto 38791 del computador.
//
// Cada plataforma ve "el computador" con una dirección distinta:
//   - Emulador de Android -> 10.0.2.2 (es el alias del computador anfitrión)
//   - Windows / Chrome     -> localhost
//   - Versión web en Docker (nginx) -> la misma dirección de la página,
//     porque nginx reenvía las peticiones /api/ hacia la API.
//
// También se puede forzar una dirección al ejecutar, por ejemplo con un
// celular físico en la misma red WiFi:
//   flutter run --dart-define=API_URL=http://192.168.1.21:38791
// =============================================================================

import 'package:flutter/foundation.dart';

class ApiConfig {
  // Valor que llega con --dart-define=API_URL=... (vacío si no se envía).
  static const String _apiUrl = String.fromEnvironment('API_URL');

  // Puerto que publica el docker-compose del profesor (38791:80).
  static const int puertoApi = 38791;

  static String get baseUrl {
    // 1. El Dockerfile compila la versión web con API_URL=mismo-origen.
    //    En ese caso se usa la misma dirección desde donde se abrió la página
    //    (por ejemplo http://localhost:8080) y nginx hace el resto.
    if (_apiUrl == 'mismo-origen') {
      return Uri.base.origin;
    }

    // 2. Si se envió una dirección a mano, se respeta.
    if (_apiUrl.isNotEmpty) {
      return _apiUrl;
    }

    // 3. Valores automáticos según la plataforma.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$puertoApi';
    }
    return 'http://localhost:$puertoApi';
  }
}
