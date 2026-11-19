import 'package:flutter/material.dart';

/// Sistema de tokens de color para Mercalli.
/// Basado en la identidad visual: Dark Navy + Cyan Eléctrico.
abstract class AppColors {
  // ── Fondos ──────────────────────────────────────────────
  static const Color bgPrimary   = Color(0xFF0A0E1A); // fondo principal
  static const Color bgCard      = Color(0xFF141929); // tarjetas / drawers
  static const Color bgField     = Color(0xFF1E2740); // inputs de formulario
  static const Color bgOverlay   = Color(0x99000000); // overlay semitransparente

  // ── Acentos ─────────────────────────────────────────────
  static const Color accentBlue  = Color(0xFF2563EB); // CTA primario
  static const Color accentCyan  = Color(0xFF00D4FF); // highlights / QR
  static const Color accentGlow  = Color(0x3300D4FF); // halo/glow effect

  // ── Texto ───────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint      = Color(0xFF4A5568);

  // ── Estado ──────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);

  // ── Badges marketplace ──────────────────────────────────
  static const Color badgeNew      = Color(0xFF22C55E);
  static const Color badgeUsed     = Color(0xFFF59E0B);
  static const Color badgeFaculty  = Color(0xFF6366F1);
  static const Color badgeDelivery = Color(0xFF2563EB);

  // ── Gradientes ──────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0E1A), Color(0xFF141929)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2563EB), Color(0xFF00D4FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2035), Color(0xFF0F1624)],
  );
}
