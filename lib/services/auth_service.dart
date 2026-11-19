// =============================================================================
// auth_service.dart
// Maneja la sesión del usuario y las llamadas HTTP a la API MyVaccine
// (la API del repositorio del profesor, que corre en Docker).
//
// Endpoints que se usan:
//   POST /api/Auth/register   -> crea un usuario
//   POST /api/Auth/login      -> devuelve un token JWT
//   GET  /api/Auth/user-info  -> datos del usuario (requiere el token)
//
// Extiende ChangeNotifier: cada vez que se inicia o se cierra sesión llama a
// notifyListeners(). GoRouter escucha ese aviso (refreshListenable) y vuelve
// a evaluar su "redirect", así la app cambia de pantalla sola.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class AuthService extends ChangeNotifier {
  // El token se guarda en memoria. Si se cierra la app, hay que volver a
  // iniciar sesión (se dejó así para mantener el proyecto sencillo).
  String? _token;
  DateTime? _expiracion;

  bool get estaLogueado => _token != null;
  DateTime? get expiracion => _expiracion;

  static const _tiempoMaximo = Duration(seconds: 10);
  static const _mensajeSinConexion =
      'No se pudo conectar con la API. Revisa que los contenedores de '
      'Docker estén corriendo (puerto ${ApiConfig.puertoApi}).';

  Uri _url(String ruta) => Uri.parse('${ApiConfig.baseUrl}$ruta');

  Map<String, String> get _encabezados => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ---------------------------------------------------------------------------
  // LOGIN
  // Devuelve null si todo salió bien, o un mensaje de error para mostrar.
  // ---------------------------------------------------------------------------
  Future<String?> login(String usuario, String clave) async {
    try {
      final respuesta = await http
          .post(
            _url('/api/Auth/login'),
            headers: _encabezados,
            body: jsonEncode({'username': usuario, 'password': clave}),
          )
          .timeout(_tiempoMaximo);

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
        _token = datos['token'] as String?;
        final exp = datos['expiration'] as String?;
        _expiracion = exp != null ? DateTime.tryParse(exp) : null;

        // Aviso a GoRouter: la sesión cambió, vuelve a evaluar el redirect.
        notifyListeners();
        return null;
      }
      if (respuesta.statusCode == 401) {
        return 'Usuario o contraseña incorrectos.';
      }
      return 'La API respondió con el código ${respuesta.statusCode}.';
    } on Exception {
      return _mensajeSinConexion;
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTRO
  // La API usa ASP.NET Identity, que exige una contraseña de mínimo
  // 8 caracteres con mayúscula, minúscula, número y símbolo.
  // ---------------------------------------------------------------------------
  Future<String?> registrar({
    required String nombre,
    required String apellido,
    required String usuario,
    required String clave,
  }) async {
    try {
      final respuesta = await http
          .post(
            _url('/api/Auth/register'),
            headers: _encabezados,
            body: jsonEncode({
              'username': usuario,
              'password': clave,
              'firstName': nombre,
              'lastName': apellido,
            }),
          )
          .timeout(_tiempoMaximo);

      final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
      if (respuesta.statusCode == 200 && datos['isSuccess'] == true) {
        return null;
      }
      // La API devuelve una lista "errors" con los motivos del rechazo.
      final errores = datos['errors'];
      if (errores is List && errores.isNotEmpty) {
        return errores.join('\n');
      }
      return 'No se pudo crear el usuario.';
    } on Exception {
      return _mensajeSinConexion;
    }
  }

  // ---------------------------------------------------------------------------
  // PERFIL
  // Ruta protegida con [Authorize] en la API: por eso se envía el token
  // en el encabezado Authorization (ver _encabezados).
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> obtenerPerfil() async {
    final respuesta = await http
        .get(_url('/api/Auth/user-info'), headers: _encabezados)
        .timeout(_tiempoMaximo);

    if (respuesta.statusCode != 200) {
      throw Exception('Código ${respuesta.statusCode}');
    }
    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // CERRAR SESIÓN
  // Al borrar el token y avisar, el redirect de GoRouter manda al login.
  // ---------------------------------------------------------------------------
  void logout() {
    _token = null;
    _expiracion = null;
    notifyListeners();
  }
}
