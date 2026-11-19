import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/qr_credential_data.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc — cerebro de la autenticación en Mercalli.
///
/// Gestiona todo el ciclo de vida de sesión:
/// - Verificación de sesión persistida al arrancar
/// - Validación y parseo del QR de credencial universitaria
/// - Registro de cuenta nueva
/// - Login con matrícula + contraseña
/// - Logout
///
/// El [go_router] escucha los cambios de estado via [AuthBloc.stream]
/// para redirigir automáticamente (routing guards).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  /// QR validado temporalmente: se persiste aquí hasta completar el registro.
  QRCredentialData? _pendingCredential;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckSession>(_onCheckSession);
    on<AuthQRScanned>(_onQRScanned);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthClearError>(_onClearError);
  }

  // ── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _onCheckSession(
    AuthCheckSession event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getPersistedSession();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onQRScanned(
    AuthQRScanned event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final credential = await _authRepository.validateQRPayload(event.rawQRValue);
      if (credential.isValid) {
        _pendingCredential = credential;
        emit(AuthQRValidated(credential: credential));
      } else {
        emit(const AuthQRError(
          message: 'QR no reconocido. Usa la credencial física de tu universidad.',
        ));
      }
    } catch (e) {
      emit(AuthQRError(message: 'Error al leer el QR: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (_pendingCredential == null) {
      emit(const AuthError(message: 'Debes escanear tu credencial primero.'));
      return;
    }
    emit(const AuthLoading());
    try {
      final user = await _authRepository.registerWithQR(
        credential: _pendingCredential!,
        password: event.password,
      );
      _pendingCredential = null;
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.loginWithMatricula(
        matricula: event.matricula,
        password: event.password,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  void _onClearError(
    AuthClearError event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthUnauthenticated());
  }

  /// Getter conveniente para usar en go_router redirect
  bool get isAuthenticated => state is AuthAuthenticated;
}
