// =============================================================================
// not_found_screen.dart
// Pantalla 404. La muestra el "errorBuilder" de GoRouter cuando se navega a
// una ruta que no existe (por ejemplo, escribiendo /hola en el navegador).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.rutaPedida});

  final String rutaPedida;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off, size: 64),
              const SizedBox(height: 16),
              Text(
                'La ruta "$rutaPedida" no existe.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                // go('/') -> la ruta raíz redirige a /vacunas
                // (o a /login si no hay sesión).
                onPressed: () => context.go('/'),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
