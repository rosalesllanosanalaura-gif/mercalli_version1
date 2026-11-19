import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/qr_credential_data.dart';

/// Estados del AuthBloc — controlan todo el flujo de sesión en Mercalli.
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Estado inicial: comprobando sesión persistida
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Cargando: validando QR, registrando o haciendo login
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// QR escaneado y validado — listo para completar el registro
class AuthQRValidated extends AuthState {
  final QRCredentialData credential;
  const AuthQRValidated({required this.credential});
  @override
  List<Object?> get props => [credential];
}

/// QR inválido — mostrar error en el scanner
class AuthQRError extends AuthState {
  final String message;
  const AuthQRError({required this.message});
  @override
  List<Object?> get props => [message];
}

/// Autenticado exitosamente
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated({required this.user});
  @override
  List<Object?> get props => [user];
}

/// No autenticado — redirigir a WelcomePage
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error de autenticación (login/registro fallido)
class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}
