// =============================================================================
// app_router.dart
// Toda la navegación de la app está definida en este archivo con GoRouter.
//
// Técnicas de GoRouter que se usan aquí:
//   - GoRoute con "path" y "name"      -> rutas con nombre
//   - Rutas anidadas (routes: [...])   -> /vacunas/:id
//   - Parámetros de ruta (:id)         -> state.pathParameters
//   - Parámetros de consulta (?desde=) -> state.uri.queryParameters
//   - ShellRoute                       -> barra de navegación inferior fija
//   - redirect + refreshListenable     -> proteger rutas si no hay sesión
//   - errorBuilder                     -> pantalla 404 propia
//
// Mapa de rutas:
//   /login                (pública)
//   /registro             (pública)
//   /vacunas              (protegida, dentro del Shell)
//   /vacunas/:id          (protegida, hija de /vacunas)
//   /perfil               (protegida, dentro del Shell)
// =============================================================================

import 'package:go_router/go_router.dart';

import '../screens/home_shell.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/register_screen.dart';
import '../screens/vacuna_detalle_screen.dart';
import '../screens/vacunas_screen.dart';
import '../services/auth_service.dart';

// Rutas que se pueden visitar sin haber iniciado sesión.
const _rutasPublicas = ['/login', '/registro'];

GoRouter crearRouter(AuthService auth) {
  return GoRouter(
    // Primera ruta que se intenta abrir. Como no hay sesión,
    // el redirect la cambia por /login.
    initialLocation: '/vacunas',

    // Muestra en la consola de depuración cada cambio de ruta.
    debugLogDiagnostics: true,

    // GoRouter "escucha" al AuthService. Cuando este llama a
    // notifyListeners() (login o logout), se vuelve a ejecutar el redirect.
    refreshListenable: auth,

    // -------------------------------------------------------------------------
    // REDIRECT (guardián de rutas)
    // Se ejecuta antes de mostrar cualquier pantalla.
    // Devolver null = "deja pasar". Devolver una ruta = "manda para allá".
    // -------------------------------------------------------------------------
    redirect: (context, state) {
      final logueado = auth.estaLogueado;
      final vaAPublica = _rutasPublicas.contains(state.matchedLocation);

      // Sin sesión e intentando entrar a una ruta protegida -> al login.
      // Se guarda a dónde quería ir en un PARÁMETRO DE CONSULTA:
      //   /vacunas/3  ->  /login?desde=%2Fvacunas%2F3
      if (!logueado && !vaAPublica) {
        final destino = state.uri.toString();
        if (destino == '/' || destino == '/vacunas') return '/login';
        return '/login?desde=${Uri.encodeComponent(destino)}';
      }

      // Con sesión y todavía en login o registro -> a donde quería ir
      // (state.uri.queryParameters lee el ?desde=) o, si no hay, a la lista.
      if (logueado && vaAPublica) {
        final desde = state.uri.queryParameters['desde'];
        if (desde != null && desde.startsWith('/')) return desde;
        return '/vacunas';
      }

      // Devolver null = dejar pasar.
      return null;
    },

    // -------------------------------------------------------------------------
    // ERROR BUILDER
    // Si se escribe una ruta que no existe (ej: /hola), se muestra esta
    // pantalla en lugar de la pantalla de error por defecto.
    // -------------------------------------------------------------------------
    errorBuilder: (context, state) =>
        NotFoundScreen(rutaPedida: state.uri.toString()),

    routes: [
      // La raíz "/" no tiene pantalla propia: redirige a la lista.
      GoRoute(
        path: '/',
        redirect: (context, state) => '/vacunas',
      ),

      // ----------------------------- Rutas públicas -------------------------
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(auth: auth),
      ),
      GoRoute(
        path: '/registro',
        name: 'registro',
        builder: (context, state) => RegisterScreen(auth: auth),
      ),

      // ----------------------------- Rutas protegidas -----------------------
      // ShellRoute envuelve varias rutas con una misma estructura (HomeShell),
      // en este caso una barra de navegación inferior que no desaparece al
      // cambiar de pestaña. "child" es la pantalla de la ruta activa.
      ShellRoute(
        builder: (context, state, child) =>
            HomeShell(rutaActual: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/vacunas',
            name: 'vacunas',
            builder: (context, state) => const VacunasScreen(),
            routes: [
              // Ruta HIJA: su path completo queda /vacunas/:id
              // ":id" es un parámetro: /vacunas/3 -> id = "3"
              GoRoute(
                path: ':id',
                name: 'detalle',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return VacunaDetalleScreen(id: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/perfil',
            name: 'perfil',
            builder: (context, state) => PerfilScreen(auth: auth),
          ),
        ],
      ),
    ],
  );
}
