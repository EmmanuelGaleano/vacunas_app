// =============================================================================
// vacunas_screen.dart
// Lista de vacunas (ruta protegida: /vacunas).
//
// Usa ListView.builder, que construye solo los elementos visibles, y al
// tocar una vacuna navega al detalle con una RUTA CON NOMBRE y un parámetro:
//   context.goNamed('detalle', pathParameters: {'id': vacuna.id})
// que GoRouter convierte en la URL /vacunas/<id>.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/vacuna.dart';

class VacunasScreen extends StatelessWidget {
  const VacunasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de vacunas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: catalogoVacunas.length,
        itemBuilder: (context, indice) {
          final vacuna = catalogoVacunas[indice];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(vacuna.id)),
              title: Text(vacuna.nombre),
              subtitle: Text(vacuna.protegeContra),
              trailing: const Icon(Icons.chevron_right),
              // goNamed: se navega por el NOMBRE de la ruta ('detalle'),
              // no escribiendo la URL a mano. Si algún día cambia el path,
              // este código no se toca.
              // Se usa go (no push) porque push no actualiza la barra de
              // direcciones del navegador. Como 'detalle' es ruta HIJA de
              // /vacunas, go arma la pila lista -> detalle y la flecha de
              // atrás sigue funcionando.
              onTap: () => context.goNamed(
                'detalle',
                pathParameters: {'id': vacuna.id},
              ),
            ),
          );
        },
      ),
    );
  }
}