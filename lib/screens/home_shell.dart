// =============================================================================
// home_shell.dart
// "Cascarón" de las rutas protegidas. Lo usa el ShellRoute de app_router.dart.
//
// Dibuja la barra de navegación inferior una sola vez, y en el centro
// (body) muestra "child", que es la pantalla de la ruta activa:
// /vacunas, /vacunas/:id o /perfil.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.rutaActual, required this.child});

  final String rutaActual;
  final Widget child;

  // Pestaña seleccionada según la URL. /vacunas/3 también marca "Vacunas".
  int get _indice => rutaActual.startsWith('/perfil') ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) {
          // go() (no push): cambiar de pestaña reemplaza la ruta actual,
          // no apila pantallas una encima de otra.
          if (indice == 0) {
            context.goNamed('vacunas');
          } else {
            context.goNamed('perfil');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.vaccines_outlined),
            selectedIcon: Icon(Icons.vaccines),
            label: 'Vacunas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
