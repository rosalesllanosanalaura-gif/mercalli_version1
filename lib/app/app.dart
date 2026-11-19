import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mercalli_version1/app/theme/app_theme.dart';
import 'package:mercalli_version1/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mercalli_version1/features/auth/presentation/bloc/auth_event.dart';
import 'package:mercalli_version1/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mercalli_version1/app/router/app_router.dart';

/// Widget raíz de Mercalli.
/// Registra los BlocProviders globales y configura el router.
class MercalliApp extends StatefulWidget {
  const MercalliApp({super.key});

  @override
  State<MercalliApp> createState() => _MercalliAppState();
}

class _MercalliAppState extends State<MercalliApp> {
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(authRepository: AuthRepositoryImpl())
      ..add(const AuthCheckSession()); // verificar sesión al iniciar
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Mercalli',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: _appRouter.router,
        builder: (context, child) {
          // Asegurar densidad de texto consistente en Android e iOS
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
      ),
    );
  }
}
