// =============================================================================
// vacuna_detalle_screen.dart
// Detalle de una vacuna (ruta protegida: /vacunas/:id).
//
// Recibe el "id" que GoRouter sacó de la URL (state.pathParameters['id']).
// Como el id viene de la URL, alguien podría escribir /vacunas/99: por eso
// se valida y, si no existe, se muestra un mensaje en vez de fallar.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/vacuna.dart';

class VacunaDetalleScreen extends StatelessWidget {
  const VacunaDetalleScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final vacuna = buscarVacuna(id);

    if (vacuna == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vacuna no encontrada')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No existe una vacuna con id "$id".'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.goNamed('vacunas'),
                child: const Text('Ver el catálogo'),
              ),
            ],
          ),
        ),
      );
    }

    final textos = Theme.of(context).textTheme;

    return Scaffold(
      // La flecha de "atrás" aparece sola porque es ruta hija de /vacunas.
      appBar: AppBar(title: Text(vacuna.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(vacuna.nombre, style: textos.headlineSmall),
          const SizedBox(height: 8),
          Text(vacuna.descripcion, style: textos.bodyLarge),
          const SizedBox(height: 20),
          _Dato(
            icono: Icons.shield,
            titulo: 'Protege contra',
            valor: vacuna.protegeContra,
          ),
          _Dato(
            icono: Icons.event_repeat,
            titulo: 'Dosis',
            valor: vacuna.dosis,
          ),
          _Dato(
            icono: vacuna.requiereRefuerzo ? Icons.check_circle : Icons.cancel,
            titulo: '¿Requiere refuerzo?',
            valor: vacuna.requiereRefuerzo ? 'Sí' : 'No',
          ),
          const SizedBox(height: 20),
          // Se muestra la URL actual para evidenciar el parámetro de ruta.
          Text(
            'Ruta actual: ${GoRouterState.of(context).uri}',
            style: textos.bodySmall,
          ),
        ],
      ),
    );
  }
}

// Widget pequeño y reutilizable para cada fila de información.
class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.titulo, required this.valor});

  final IconData icono;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icono, color: Theme.of(context).colorScheme.primary),
      title: Text(titulo),
      subtitle: Text(valor),
    );
  }
}