import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Estado interno del visor QR.
enum _ScannerStatus { scanning, processing, success, error }

/// [QRScannerWidget] — Widget crítico #1
///
/// Visor de cámara completo para escanear credenciales universitarias:
/// - Overlay con marco de enfoque animado + esquinas neón
/// - Botón de flash/linterna toggle
/// - Feedback háptico en éxito/error
/// - Control de estados: escaneando, procesando, éxito, error
/// - Debounce para evitar lecturas duplicadas
class QRScannerWidget extends StatefulWidget {
  final void Function(String rawValue)? onScanned;
  final bool showGuideText;

  const QRScannerWidget({
    super.key,
    this.onScanned,
    this.showGuideText = true,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget>
    with TickerProviderStateMixin {
  // ── Controller del scanner nativo ────────────────────────
  final MobileScannerController _scannerCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  // ── Estado del widget ────────────────────────────────────
  _ScannerStatus _status = _ScannerStatus.scanning;
  bool _torchOn = false;
  bool _debouncing = false;

  // ── Animación del marco de enfoque ───────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Lógica de escaneo ────────────────────────────────────

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_debouncing || _status != _ScannerStatus.scanning) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final rawValue = barcode!.rawValue!;
    _debouncing = true;

    setState(() => _status = _ScannerStatus.processing);

    // Parar el escáner para no procesar múltiples lecturas
    _scannerCtrl.stop();

    // Delegar al BLoC (validará el payload)
    context.read<AuthBloc>().add(AuthQRScanned(rawQRValue: rawValue));
    widget.onScanned?.call(rawValue);
  }

  void _resetScanner() {
    setState(() {
      _status = _ScannerStatus.scanning;
      _debouncing = false;
    });
    _scannerCtrl.start();

    // Reanudar debounce después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _debouncing = false;
    });
  }

  Future<void> _toggleTorch() async {
    await _scannerCtrl.toggleTorch();
    if (mounted) setState(() => _torchOn = !_torchOn);
    HapticUtils.light();
  }

  // ── UI ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthQRValidated) {
          await HapticUtils.success();
          if (mounted) setState(() => _status = _ScannerStatus.success);
        } else if (state is AuthQRError) {
          await HapticUtils.error();
          if (mounted) {
            setState(() => _status = _ScannerStatus.error);
            // Auto-reset después de 2.5 segundos
            Future.delayed(const Duration(milliseconds: 2500), _resetScanner);
          }
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Cámara nativa ──────────────────────────────────
          MobileScanner(
            controller: _scannerCtrl,
            onDetect: _onBarcodeDetected,
          ),

          // ── Overlay oscuro con recorte central ─────────────
          _buildDimmedOverlay(),

          // ── Marco de enfoque animado ───────────────────────
          Center(child: _buildScanFrame()),

          // ── Texto guía ─────────────────────────────────────
          if (widget.showGuideText) _buildGuideText(),

          // ── Controles (flash + estado) ─────────────────────
          _buildControls(),

          // ── Overlay de estado (procesando/éxito/error) ─────
          if (_status != _ScannerStatus.scanning) _buildStatusOverlay(),
        ],
      ),
    );
  }

  /// Overlay semitransparente alrededor del área de escaneo.
  Widget _buildDimmedOverlay() {
    return CustomPaint(
      painter: _ScannerOverlayPainter(
        frameSize: _frameSize,
        borderRadius: 16,
      ),
    );
  }

  static const double _frameSize = 260.0;

  /// Marco con esquinas neón animadas.
  Widget _buildScanFrame() {
    final color = _statusColor;
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) {
        return Transform.scale(
          scale: _status == _ScannerStatus.scanning ? _pulseAnim.value : 1.0,
          child: SizedBox(
            width: _frameSize,
            height: _frameSize,
            child: CustomPaint(
              painter: _CornerPainter(color: color),
            ),
          ),
        );
      },
    );
  }

  /// Texto de instrucción debajo del marco.
  Widget _buildGuideText() {
    final messages = {
      _ScannerStatus.scanning: '📋 Enfoca el QR de tu credencial universitaria',
      _ScannerStatus.processing: '⏳ Verificando credencial...',
      _ScannerStatus.success: '✅ ¡Credencial válida!',
      _ScannerStatus.error: '❌ QR no reconocido. Intenta de nuevo.',
    };
    return Positioned(
      bottom: 120,
      left: 24,
      right: 24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          messages[_status] ?? '',
          key: ValueKey(_status),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: _statusColor,
            shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
          ),
        ),
      ),
    );
  }

  /// Botón de flash + indicador de estado en la parte inferior.
  Widget _buildControls() {
    return Positioned(
      bottom: 48,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flash toggle
          _ControlButton(
            icon: _torchOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
            label: _torchOn ? 'Flash On' : 'Flash Off',
            onTap: _toggleTorch,
            color: _torchOn ? AppColors.accentCyan : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  /// Overlay de estado sobre la cámara (procesando / éxito / error).
  Widget _buildStatusOverlay() {
    if (_status == _ScannerStatus.processing) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accentCyan,
          strokeWidth: 3,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color get _statusColor {
    switch (_status) {
      case _ScannerStatus.scanning:    return AppColors.accentCyan;
      case _ScannerStatus.processing:  return AppColors.warning;
      case _ScannerStatus.success:     return AppColors.success;
      case _ScannerStatus.error:       return AppColors.error;
    }
  }
}

// ── Sub-widgets internos ─────────────────────────────────────────────────────

/// Botón circular de control (flash, etc.)
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.bgOverlay,
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(color: color, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ── Custom Painters ──────────────────────────────────────────────────────────

/// Pinta el overlay oscuro con recorte rectangular central.
class _ScannerOverlayPainter extends CustomPainter {
  final double frameSize;
  final double borderRadius;

  const _ScannerOverlayPainter({
    required this.frameSize,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.65);
    final center = Offset(size.width / 2, size.height / 2);

    final frame = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: frameSize, height: frameSize),
      Radius.circular(borderRadius),
    );

    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(full)
      ..addRRect(frame)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pinta las 4 esquinas neón del marco de enfoque.
class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Añadir glow/sombra
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    const cornerLen = 28.0;
    const r = 12.0;

    void drawCorner(Offset origin, bool flipX, bool flipY) {
      final dx = flipX ? -1.0 : 1.0;
      final dy = flipY ? -1.0 : 1.0;

      final path = Path()
        ..moveTo(origin.dx + dx * cornerLen, origin.dy)
        ..lineTo(origin.dx + dx * r, origin.dy)
        ..arcToPoint(
          Offset(origin.dx, origin.dy + dy * r),
          radius: const Radius.circular(r),
          clockwise: !(flipX ^ flipY),
        )
        ..lineTo(origin.dx, origin.dy + dy * cornerLen);

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }

    drawCorner(Offset.zero, false, false);               // top-left
    drawCorner(Offset(size.width, 0), true, false);      // top-right
    drawCorner(Offset(0, size.height), false, true);     // bottom-left
    drawCorner(Offset(size.width, size.height), true, true); // bottom-right
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => old.color != color;
}
