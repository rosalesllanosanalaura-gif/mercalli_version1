import '../entities/user_entity.dart';
import '../entities/qr_credential_data.dart';

/// Contrato del repositorio de autenticación.
/// Implementado en la capa de datos; depende de abstracciones, no de concreciones.
abstract class AuthRepository {
  /// Valida y parsea el payload crudo del QR escaneado.
  /// Retorna [QRCredentialData] indicando si el QR es válido.
  Future<QRCredentialData> validateQRPayload(String rawQRValue);

  /// Registra un nuevo usuario usando los datos del QR + contraseña elegida.
  Future<UserEntity> registerWithQR({
    required QRCredentialData credential,
    required String password,
  });

  /// Autenticación con matrícula + contraseña.
  Future<UserEntity> loginWithMatricula({
    required String matricula,
    required String password,
  });

  /// Recupera la sesión persistida localmente (SharedPreferences / SecureStorage).
  Future<UserEntity?> getPersistedSession();

  /// Cierra la sesión y limpia el storage local.
  Future<void> logout();
}
