import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/qr_scanner_page.dart';
import '../../features/marketplace/presentation/pages/home_page.dart';
import '../../features/marketplace/presentation/pages/feed_page.dart';

/// Rutas de la aplicación Mercalli.
abstract class AppRoutes {
  static const String splash     = '/';
  static const String welcome    = '/welcome';
  static const String login      = '/login';
  static const String register   = '/register';
  static const String qrScanner  = '/qr-scanner';
  static const String home       = '/home';
  static const String feed       = '/feed'; // ← Feed Principal v2 (landing)
}

/// Configuración del router con AuthGuard integrado.
///
/// El [redirect] se ejecuta en cada navegación.
/// Si el usuario no está autenticado, es redirigido a [AppRoutes.welcome].
/// Si ya está autenticado e intenta ir a auth, se redirige a [AppRoutes.home].
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: _routeGuard,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, __) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.qrScanner,
        builder: (context, state) {
          // Determinar modo: login o registro
          final mode = state.uri.queryParameters['mode'] ?? 'register';
          return QRScannerPage(mode: mode);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.feed,
        builder: (_, __) => const FeedPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );

  /// Guard de autenticación.
  /// Retorna `null` para permitir la navegación, o una ruta para redirigir.
  String? _routeGuard(BuildContext context, GoRouterState state) {
    final authState = authBloc.state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isInitializing  = authState is AuthInitial || authState is AuthLoading;

    final isAuthRoute = [
      AppRoutes.welcome,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.qrScanner,
    ].contains(state.matchedLocation);

    final isProtectedRoute = [
      AppRoutes.home,
      AppRoutes.feed,
    ].contains(state.matchedLocation);

    // En splash, esperar sin redirigir
    if (state.matchedLocation == AppRoutes.splash) return null;

    // Si aún está inicializando, quedarse en splash
    if (isInitializing) return AppRoutes.splash;

    // Si autenticado e intenta acceder a pantallas de auth → Home
    if (isAuthenticated && isAuthRoute) return AppRoutes.home;

    // Si NO autenticado e intenta acceder a rutas protegidas → Welcome
    if (!isAuthenticated && !isAuthRoute) return AppRoutes.welcome;
    return null; // Permitir la navegación
  }
}

/// Adaptador para refrescar go_router cuando el Stream de BLoC emite.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
