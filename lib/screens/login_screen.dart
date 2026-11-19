// =============================================================================
// login_screen.dart
// Pantalla de inicio de sesión (ruta pública: /login).
//
// Conceptos de Flutter usados:
//   - StatefulWidget + setState para el estado "cargando"
//   - Form + TextFormField con validadores
//   - context.push() de GoRouter para abrir el registro ENCIMA del login
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    // Si algún validador devuelve un texto, el formulario no se envía.
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    final error = await widget.auth.login(
      _usuarioCtrl.text.trim(),
      _claveCtrl.text,
    );

    if (!mounted) return;
    setState(() {
      _cargando = false;
      _error = error;
    });

    // OJO: aquí NO se navega a mano. Si el login fue exitoso, AuthService
    // llama a notifyListeners(), GoRouter vuelve a ejecutar el redirect y
    // como ya hay sesión, nos lleva solo a /vacunas (o a la ruta guardada
    // en ?desde= si el usuario había intentado entrar a otra pantalla).
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.vaccines, size: 72, color: colores.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Vacunas App',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Inicia sesión con tu usuario de la API MyVaccine',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usuarioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) => (valor == null || valor.trim().isEmpty)
                        ? 'Escribe tu usuario'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _claveCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) => (valor == null || valor.isEmpty)
                        ? 'Escribe tu contraseña'
                        : null,
                    onFieldSubmitted: (_) => _ingresar(),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: TextStyle(color: colores.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  FilledButton(
                    onPressed: _cargando ? null : _ingresar,
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Ingresar'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    // push = abre /registro ENCIMA del login, por eso desde
                    // el registro se puede volver con la flecha (pop).
                    onPressed: () => context.push('/registro'),
                    child: const Text('¿No tienes cuenta? Regístrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
