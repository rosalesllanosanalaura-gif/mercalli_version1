/// Resultado tipado del parseo de un QR de credencial universitaria.
class QRCredentialData {
  final String matricula;
  final String name;
  final String faculty;
  final String role;       // 'student' | 'professor'
  final String issueYear;
  final bool isValid;

  const QRCredentialData({
    required this.matricula,
    required this.name,
    required this.faculty,
    required this.role,
    required this.issueYear,
    required this.isValid,
  });

  /// Parsea el payload del QR. Formato esperado (JSON comprimido):
  /// {"m":"20240189","n":"Ana García","f":"Ingeniería","r":"student","y":"2024"}
  factory QRCredentialData.fromQRPayload(String raw) {
    try {
      // Soporte para payload JSON o formato delimitado por |
      if (raw.startsWith('{')) {
        // Parseo JSON básico sin dependencias externas
        final clean = raw.replaceAll(RegExp(r'[{}" ]'), '');
        final Map<String, String> map = {};
        for (final pair in clean.split(',')) {
          final parts = pair.split(':');
          if (parts.length == 2) map[parts[0]] = parts[1];
        }
        return QRCredentialData(
          matricula: map['m'] ?? '',
          name: map['n'] ?? '',
          faculty: map['f'] ?? '',
          role: map['r'] ?? 'student',
          issueYear: map['y'] ?? '',
          isValid: (map['m']?.isNotEmpty ?? false) && (map['n']?.isNotEmpty ?? false),
        );
      }
      // Fallback: payload delimitado | matricula|nombre|facultad|rol|año
      final parts = raw.split('|');
      if (parts.length >= 5) {
        return QRCredentialData(
          matricula: parts[0],
          name: parts[1],
          faculty: parts[2],
          role: parts[3],
          issueYear: parts[4],
          isValid: true,
        );
      }
      return const QRCredentialData(
        matricula: '', name: '', faculty: '', role: '', issueYear: '', isValid: false,
      );
    } catch (_) {
      return const QRCredentialData(
        matricula: '', name: '', faculty: '', role: '', issueYear: '', isValid: false,
      );
    }
  }

  @override
  String toString() => 'QRCredentialData(matricula: $matricula, valid: $isValid)';
}
