// =============================================================================
// register_screen.dart
// Pantalla de registro (ruta pública: /registro).
//
// Se abre con context.push('/registro') desde el login, así que queda
// "encima" del login. Al terminar se usa context.pop() para regresar.
//
// Los validadores repiten las reglas de contraseña que exige la API
// (ASP.NET Identity), para avisar al usuario antes de enviar la petición.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _usuarioCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _usuarioCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  // Mismas reglas que configura la API en AuthConfigurations.cs
  String? _validarClave(String? valor) {
    final clave = valor ?? '';
    if (clave.length < 8) return 'Mínimo 8 caracteres';
    if (!clave.contains(RegExp(r'[A-Z]'))) return 'Falta una mayúscula';
    if (!clave.contains(RegExp(r'[a-z]'))) return 'Falta una minúscula';
    if (!clave.contains(RegExp(r'[0-9]'))) return 'Falta un número';
    if (!clave.contains(RegExp(r'[^a-zA-Z0-9]'))) {
      return 'Falta un símbolo (ej: * . - _)';
    }
    return null;
  }

  String? _validarUsuario(String? valor) {
    final usuario = (valor ?? '').trim();
    if (usuario.isEmpty) return 'Escribe un usuario';
    // La API solo acepta letras, números y los símbolos - . _ @ +
    if (!RegExp(r'^[a-zA-Z0-9\-._@+]+$').hasMatch(usuario)) {
      return 'Sin espacios ni tildes';
    }
    return null;
  }

  String? _obligatorio(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Campo obligatorio' : null;

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    final error = await widget.auth.registrar(
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      usuario: _usuarioCtrl.text.trim(),
      clave: _claveCtrl.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _cargando = false;
        _error = error;
      });
      return;
    }

    // Registro exitoso: aviso y regreso al login.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario creado. Ahora inicia sesión.')),
    );
    // pop() quita esta pantalla y deja ver el login que estaba debajo.
    // Si se entró escribiendo /registro en el navegador no hay nada debajo,
    // y en ese caso se usa go() para ir directo al login.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Como esta pantalla se abrió con push, el AppBar muestra
      // automáticamente la flecha para volver.
      appBar: AppBar(title: const Text('Crear cuenta')),
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
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: _obligatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apellidoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                    validator: _obligatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usuarioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validarUsuario,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _claveCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      helperText: 'Mín. 8, con mayúscula, minúscula, número y símbolo',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validarClave,
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: _cargando ? null : _registrar,
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crear cuenta'),
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
