// =============================================================================
// main.dart
// Punto de entrada de la app "Vacunas App".
//
// Aquí se hacen tres cosas:
//   1. Se activa la "path URL strategy" para que en web las rutas se vean
//      limpias (/vacunas/2) en vez de con numeral (/#/vacunas/2).
//   2. Se crea UNA sola instancia de AuthService (el estado de la sesión).
//   3. Se crea el GoRouter y se le entrega a MaterialApp.router.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';
import 'services/auth_service.dart';

void main() {
  // Quita el "#" de las URLs cuando la app corre en el navegador.
  // En Android o Windows no hace nada, así que se puede dejar siempre.
  usePathUrlStrategy();

  // El servicio de autenticación se crea una sola vez y se comparte
  // con el router y con las pantallas que lo necesitan.
  final auth = AuthService();

  // El router también se crea una sola vez. Si se creara dentro de build(),
  // cada redibujo reiniciaría la navegación.
  final router = crearRouter(auth);

  runApp(VacunasApp(router: router));
}

class VacunasApp extends StatelessWidget {
  const VacunasApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router (en vez de MaterialApp normal) es lo que permite
    // que GoRouter controle toda la navegación de la app.
    return MaterialApp.router(
      title: 'Vacunas App',
      debugShowCheckedModeBanner: false,
      // Material 3 con un color semilla: Flutter genera toda la paleta.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
