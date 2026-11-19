/// Entidad de dominio del usuario autenticado en Mercalli.
/// Solo contiene lógica de negocio pura, sin dependencias de framework.
class UserEntity {
  final String id;
  final String matricula;
  final String name;
  final String email;
  final UserRole role;
  final String faculty;
  final bool isActive;
  final String? avatarUrl;
  final DateTime enrolledAt;

  const UserEntity({
    required this.id,
    required this.matricula,
    required this.name,
    required this.email,
    required this.role,
    required this.faculty,
    required this.isActive,
    this.avatarUrl,
    required this.enrolledAt,
  });

  /// Iniciales para avatar fallback
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  bool get isStudent  => role == UserRole.student;
  bool get isProfessor => role == UserRole.professor;

  UserEntity copyWith({
    String? id,
    String? matricula,
    String? name,
    String? email,
    UserRole? role,
    String? faculty,
    bool? isActive,
    String? avatarUrl,
    DateTime? enrolledAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      matricula: matricula ?? this.matricula,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      faculty: faculty ?? this.faculty,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserEntity(id: $id, matricula: $matricula, role: $role)';
}

/// Rol del usuario dentro del sistema universitario.
enum UserRole {
  student('Estudiante'),
  professor('Docente');

  final String label;
  const UserRole(this.label);
}
