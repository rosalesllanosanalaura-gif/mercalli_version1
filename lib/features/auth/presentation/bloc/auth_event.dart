import 'package:equatable/equatable.dart';

/// Eventos del AuthBloc — acciones que disparan cambios de estado.
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Inicializar: verificar sesión persistida al arrancar la app
class AuthCheckSession extends AuthEvent {
  const AuthCheckSession();
}

/// El usuario escaneó un QR — se debe validar el payload
class AuthQRScanned extends AuthEvent {
  final String rawQRValue;
  const AuthQRScanned({required this.rawQRValue});
  @override
  List<Object?> get props => [rawQRValue];
}

/// El usuario completó el formulario de registro tras el QR
class AuthRegisterSubmitted extends AuthEvent {
  final String password;
  const AuthRegisterSubmitted({required this.password});
  @override
  List<Object?> get props => [password];
}

/// El usuario envió el formulario de login con matrícula + contraseña
class AuthLoginSubmitted extends AuthEvent {
  final String matricula;
  final String password;
  const AuthLoginSubmitted({required this.matricula, required this.password});
  @override
  List<Object?> get props => [matricula, password];
}

/// El usuario cerró sesión
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Limpiar error sin cambiar flujo principal
class AuthClearError extends AuthEvent {
  const AuthClearError();
}
