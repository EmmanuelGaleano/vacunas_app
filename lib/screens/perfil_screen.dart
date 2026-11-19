// =============================================================================
// perfil_screen.dart
// Perfil del usuario (ruta protegida: /perfil).
//
// Los datos vienen de la API en Docker: GET /api/Auth/user-info, enviando
// el token JWT que se obtuvo en el login.
//
// Usa FutureBuilder, que dibuja algo distinto según el estado de la
// petición: cargando, error o datos listos.
// =============================================================================

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // El Future se crea UNA vez en initState. Si se creara dentro de build(),
  // se haría una petición nueva cada vez que la pantalla se redibuja.
  late Future<Map<String, dynamic>> _perfil;

  @override
  void initState() {
    super.initState();
    _perfil = widget.auth.obtenerPerfil();
  }

  void _recargar() {
    setState(() => _perfil = widget.auth.obtenerPerfil());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _perfil,
        builder: (context, snapshot) {
          // 1. Mientras llega la respuesta.
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Si la petición falló.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No se pudo cargar el perfil.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _recargar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Datos listos.
          final datos = snapshot.data!;
          final nombre = '${datos['firstName'] ?? ''} ${datos['lastName'] ?? ''}'
              .trim();
          final usuario = datos['userName'] ?? '';
          final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Text(inicial, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                nombre,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('@$usuario', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              const ListTile(
                leading: Icon(Icons.dns),
                title: Text('Origen de los datos'),
                subtitle: Text('API MyVaccine en Docker (/api/Auth/user-info)'),
              ),
              if (widget.auth.expiracion != null)
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('El token vence el'),
                  subtitle: Text(
                    widget.auth.expiracion!.toLocal().toString().split('.').first,
                  ),
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                // logout() borra el token y avisa con notifyListeners().
                // El redirect de GoRouter detecta que no hay sesión y
                // manda al usuario a /login sin escribir ningún context.go.
                onPressed: widget.auth.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          );
        },
      ),
    );
  }
}
