# 💉 Vacunas App — Flutter + GoRouter + Docker

Aplicación Flutter sencilla hecha para la actividad **"Flutter GoRouter y Screens básicos"**.
Explora la navegación con **GoRouter**, pantallas básicas de Flutter y la conexión con la
**API MyVaccine** (.NET + SQL Server) que corre en **contenedores Docker**.

---

## ✨ ¿Qué hace la app?

| Pantalla | Ruta | Qué muestra |
|---|---|---|
| Login | `/login` | Inicia sesión contra la API (`POST /api/Auth/login`) y recibe un token JWT |
| Registro | `/registro` | Crea un usuario en la API (`POST /api/Auth/register`) |
| Catálogo de vacunas | `/vacunas` | Lista de vacunas (datos locales de ejemplo) |
| Detalle | `/vacunas/:id` | Detalle de una vacuna usando un parámetro de ruta |
| Perfil | `/perfil` | Datos del usuario traídos de la API (`GET /api/Auth/user-info`) con el token |
| 404 | cualquier otra | Pantalla propia para rutas que no existen |

## 🧭 Técnicas de GoRouter usadas

Todas están en [`lib/router/app_router.dart`](lib/router/app_router.dart):

- **`MaterialApp.router` + `routerConfig`**: GoRouter controla toda la navegación.
- **Rutas con nombre** (`name: 'detalle'`) y navegación con `context.goNamed`.
- **Rutas anidadas y parámetros**: `/vacunas/:id` → `state.pathParameters['id']`.
- **`ShellRoute`**: barra de navegación inferior que se mantiene entre `/vacunas` y `/perfil`.
- **`redirect` + `refreshListenable`**: protege las rutas privadas; si no hay sesión manda a `/login`,
  y al iniciar o cerrar sesión la app cambia de pantalla sola.
- **Parámetros de consulta**: si se intenta abrir `/vacunas/3` sin sesión, se guarda en
  `/login?desde=/vacunas/3` y después del login la app lleva directo a esa pantalla.
- **`errorBuilder`**: pantalla 404 personalizada.
- **`go` vs `push` vs `pop`**: `go` reemplaza la ruta (pestañas), `push` apila (registro) y `pop` regresa.
- **URLs limpias en web** con `usePathUrlStrategy()` (sin `#`).

Otros conceptos de Flutter: `StatefulWidget`, `Form` con validadores, `FutureBuilder`,
`ChangeNotifier`, `ListView.builder`, `NavigationBar`, Material 3 con `ColorScheme.fromSeed`
y peticiones HTTP con el paquete `http`.

## 📁 Estructura

```
lib/
├── main.dart                     # Punto de entrada, crea AuthService y el router
├── config/api_config.dart        # Dirección de la API según la plataforma
├── models/vacuna.dart            # Modelo + catálogo local
├── router/app_router.dart        # ⭐ Todas las rutas de GoRouter
├── services/auth_service.dart    # Login, registro, perfil (HTTP) y estado de sesión
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    ├── home_shell.dart           # Barra inferior (ShellRoute)
    ├── vacunas_screen.dart
    ├── vacuna_detalle_screen.dart
    ├── perfil_screen.dart
    └── not_found_screen.dart
Dockerfile                        # Sirve la app compilada para web con nginx
nginx.conf                        # Rutas de GoRouter + proxy hacia la API
docker-compose.yml                # Levanta la app web en el puerto 8080
```

---

## 🐳 Cómo ejecutar el proyecto

### Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (solo si se quiere correr fuera de Docker)

### Paso 1 — Levantar la API MyVaccine (backend en Docker)

La app usa la API del repositorio del profesor:
[juaneangulou/my-vaccine-api](https://github.com/juaneangulou/my-vaccine-api).
Ese repositorio **no** está dentro de este proyecto; se descarga aparte.

```bash
cd my-vaccine-api/MyVaccineAppSln
docker compose up -d --build
```

(En Windows también se puede ejecutar el script `install-myvaccine.bat` que trae el repositorio.)

Esto levanta dos contenedores: la API (.NET) y la base de datos (SQL Server).
Verificar que la API responde abriendo: **http://localhost:38791/swagger**

> ⚠️ **Si el registro falla con un error de base de datos:** la API a veces arranca antes de que
> SQL Server termine de iniciar y no alcanza a crear las tablas. Espera unos 30 segundos y reinicia
> solo la API:
> ```bash
> docker compose restart webapi
> ```

### Paso 2 — Ejecutar la app

#### Opción A: versión web dentro de Docker (recomendada)

Desde la carpeta de este proyecto, primero se compila la app para web y luego se construye el contenedor:

```bash
flutter build web --release --dart-define=API_URL=mismo-origen
docker compose up -d --build
```

Abrir **http://localhost:8080**.

- `API_URL=mismo-origen` hace que la app llame a la API en la misma dirección de la página;
  nginx reenvía las peticiones `/api/` a la API del backend.
- Si se cambia el código, hay que repetir los dos comandos.
- Para detenerla: `docker compose down`

> ¿Por qué se compila fuera de Docker? Compilar dentro del contenedor exige descargar una imagen de
> Flutter de unos 2 GB, cuya versión puede no coincidir con la del proyecto. Compilando con el mismo
> Flutter del desarrollo, la imagen final solo lleva nginx (unos 20 MB).

#### Opción B: con Flutter (emulador Android, Windows o celular)

```bash
flutter pub get
flutter run
```

La dirección de la API se elige sola en [`lib/config/api_config.dart`](lib/config/api_config.dart):

| Dónde corre la app | Dirección usada |
|---|---|
| Emulador Android | `http://10.0.2.2:38791` |
| Windows / macOS / Linux | `http://localhost:38791` |
| Web en Docker | la misma de la página (nginx reenvía `/api/`) |

Con un **celular físico** (misma red WiFi) se pasa la IP del computador:

```bash
flutter run --dart-define=API_URL=http://192.168.1.21:38791
```

> ℹ️ `flutter run -d chrome` contra `localhost:38791` es bloqueado por el navegador (CORS),
> porque la API no tiene CORS habilitado. Por eso para web se usa la Opción A, donde nginx
> hace de intermediario.

---

## 🧪 Cómo probarla

1. Abrir `http://localhost:8080/vacunas/3` → aparece el **login** con `?desde=` en la URL
   (el `redirect` bloquea las rutas privadas y recuerda a dónde se quería ir).
2. Tocar **"¿No tienes cuenta? Regístrate"** y crear un usuario.
   La contraseña debe tener mínimo 8 caracteres, mayúscula, minúscula, número y símbolo.
   Ejemplo: `Vacuna2026*`
3. Iniciar sesión → la app lleva sola al **detalle** de `/vacunas/3`.
4. Volver al **catálogo** y tocar otra vacuna → detalle en `/vacunas/<id>`.
5. Ir a **Perfil** → datos traídos de la API con el token.
6. Escribir `http://localhost:8080/hola` → después del login aparece la **pantalla 404**.
7. **Cerrar sesión** → vuelve al login automáticamente.

> La sesión se guarda en memoria: si se recarga la página hay que iniciar sesión de nuevo.

Prueba automática: `flutter test`

---

## 🛠️ Solución de problemas

| Problema | Solución |
|---|---|
| "No se pudo conectar con la API" | Revisar que los contenedores del backend estén arriba: `docker ps` |
| El registro devuelve error de tablas o base de datos | `docker compose restart webapi` en la carpeta del backend |
| El emulador Android no conecta | Confirmar que el `AndroidManifest.xml` tiene el permiso de INTERNET y `usesCleartextTraffic="true"` |
| En `localhost:8080` sale la versión vieja de la app | Repetir `flutter build web ...` y luego `docker compose up -d --build` |
| El puerto 8080 está ocupado | Cambiar `"8080:80"` por otro, por ejemplo `"8081:80"`, en `docker-compose.yml` |

## 📦 Paquetes

- [`go_router`](https://pub.dev/packages/go_router) — navegación declarativa
- [`http`](https://pub.dev/packages/http) — peticiones a la API
- `flutter_web_plugins` (SDK) — URLs sin `#` en web
