import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/qr_scanner_widget.dart';

/// QRScannerPage — Pantalla fullscreen para escanear la credencial.
/// Recibe un [mode] ('login' | 'register') para personalizar el flujo.
class QRScannerPage extends StatelessWidget {
  final String mode;

  const QRScannerPage({super.key, required this.mode});

  bool get isLoginMode => mode == 'login';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthQRValidated) {
          // QR validado → volver a la pantalla anterior (autofill)
          Future.delayed(const Duration(milliseconds: 800), () {
            if (context.canPop()) context.pop();
          });
        } else if (state is AuthAuthenticated && isLoginMode) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgOverlay,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 18),
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            isLoginMode ? 'Verificar Identidad' : 'Escanear Credencial',
            style: AppTextStyles.titleMedium,
          ),
        ),
        body: Stack(
          children: [
            // ── Scanner fullscreen ─────────────────────────
            const QRScannerWidget(showGuideText: true),

            // ── Instrucciones superiores ───────────────────
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgOverlay,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLoginMode
                      ? '🔒 Escanea el QR de tu credencial universitaria para ingresar'
                      : '📋 Coloca tu credencial dentro del recuadro para crear tu cuenta',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
