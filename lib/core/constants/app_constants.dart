/// Constantes globales de la aplicación Mercalli.
abstract class AppConstants {
  // ── App Info ──────────────────────────────────────────
  static const String appName    = 'Mercalli';
  static const String appSlogan  = 'Compra · Vende · Conecta';
  static const String appVersion = '1.0.0';

  // ── Storage Keys ─────────────────────────────────────
  static const String keyAuthToken   = 'auth_token';
  static const String keyUserData    = 'user_data';
  static const String keyOnboarded   = 'onboarded';

  // ── QR Scanner ───────────────────────────────────────
  /// Tiempo mínimo entre lecturas QR (debounce)
  static const Duration qrDebounce = Duration(seconds: 2);

  // ── Animaciones ───────────────────────────────────────
  static const Duration animFast   = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow   = Duration(milliseconds: 600);

  // ── UI ────────────────────────────────────────────────
  static const double borderRadius     = 14.0;
  static const double borderRadiusCard = 16.0;
  static const double paddingPage      = 24.0;
  static const double paddingCard      = 16.0;

  // ── Marketplace Categories ────────────────────────────
  static const List<String> categories = [
    'Todos',
    'Libros',
    'Batas y Uniformes',
    'Electrónica',
    'Snacks',
    'Papelería',
    'Ropa Académica',
    'Servicios',
    'Otros',
  ];

  // ── Faculties ─────────────────────────────────────────
  static const List<String> faculties = [
    'Todas',
    'Ingeniería',
    'Medicina',
    'Derecho',
    'Ciencias Económicas',
    'Humanidades',
    'Arquitectura',
    'Ciencias Básicas',
  ];

  // ── Campus Delivery Points ────────────────────────────
  static const List<String> deliveryPoints = [
    'Biblioteca Central',
    'Cafetería Norte',
    'Cafetería Sur',
    'Edificio A',
    'Edificio B',
    'Edificio C',
    'Entrada Principal',
  ];
}
