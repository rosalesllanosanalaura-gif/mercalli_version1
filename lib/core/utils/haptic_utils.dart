import 'package:flutter/services.dart';

/// Centraliza la retroalimentación háptica en Mercalli.
/// Usar en eventos clave: escaneo QR exitoso, errores, acciones destructivas.
abstract class HapticUtils {
  /// Vibración suave — selección de chips/filtros
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Vibración media — escaneo QR exitoso, confirmaciones
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Vibración fuerte — error de QR, validación fallida
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Patrón de notificación éxito
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Patrón de error (doble vibración corta)
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }
}
