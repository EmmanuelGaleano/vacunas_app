// Prueba básica: al abrir la app sin sesión, el redirect de GoRouter
// debe mostrar la pantalla de login.
//
// Ejecutar con:  flutter test

import 'package:flutter_test/flutter_test.dart';

import 'package:vacunas_app/main.dart';
import 'package:vacunas_app/router/app_router.dart';
import 'package:vacunas_app/services/auth_service.dart';

void main() {
  testWidgets('Sin sesión, la app muestra el login', (tester) async {
    final router = crearRouter(AuthService());

    await tester.pumpWidget(VacunasApp(router: router));
    await tester.pumpAndSettle();

    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('¿No tienes cuenta? Regístrate'), findsOneWidget);
  });
}
