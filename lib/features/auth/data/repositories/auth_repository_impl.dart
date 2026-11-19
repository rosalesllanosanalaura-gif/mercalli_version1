import '../../domain/entities/user_entity.dart';
import '../../domain/entities/qr_credential_data.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementación mock del AuthRepository para desarrollo/prototipado.
/// En producción, reemplazar con llamadas al API universitario real.
class AuthRepositoryImpl implements AuthRepository {

  // Simulación de delay de red
  static const _delay = Duration(milliseconds: 800);

  @override
  Future<QRCredentialData> validateQRPayload(String rawQRValue) async {
    await Future.delayed(_delay);
    return QRCredentialData.fromQRPayload(rawQRValue);
  }

  @override
  Future<UserEntity> registerWithQR({
    required QRCredentialData credential,
    required String password,
  }) async {
    await Future.delayed(_delay);

    if (!credential.isValid) {
      throw Exception('Credencial QR inválida. Solo miembros universitarios activos.');
    }

    // Mock: crear usuario desde los datos del QR
    return UserEntity(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      matricula: credential.matricula,
      name: credential.name,
      email: '${credential.matricula}@universidad.edu.mx',
      role: credential.role == 'professor' ? UserRole.professor : UserRole.student,
      faculty: credential.faculty,
      isActive: true,
      enrolledAt: DateTime.now(),
    );
  }

  @override
  Future<UserEntity> loginWithMatricula({
    required String matricula,
    required String password,
  }) async {
    await Future.delayed(_delay);

    // Mock: validación básica para demo
    if (matricula.isEmpty || password.length < 8) {
      throw Exception('Matrícula o contraseña incorrectos.');
    }

    return UserEntity(
      id: 'usr_$matricula',
      matricula: matricula,
      name: 'Estudiante Demo',
      email: '$matricula@universidad.edu.mx',
      role: UserRole.student,
      faculty: 'Ingeniería',
      isActive: true,
      enrolledAt: DateTime(2024),
    );
  }

  @override
  Future<UserEntity?> getPersistedSession() async {
    // TODO: Implementar con flutter_secure_storage
    return null;
  }

  @override
  Future<void> logout() async {
    // TODO: Limpiar tokens de SharedPreferences / SecureStorage
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
