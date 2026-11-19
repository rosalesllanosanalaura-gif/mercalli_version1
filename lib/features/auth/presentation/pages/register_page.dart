import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// RegisterPage — Registro con credencial universitaria.
/// Replica el mockup de "Crea tu cuenta" de Mercalli.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey        = GlobalKey<FormState>();
  final _matriculaCtrl  = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  bool _passwordVisible = false;
  bool _acceptTerms     = false;

  // Criterios de contraseña
  bool get _hasMinLength    => _passwordCtrl.text.length >= 8;
  bool get _hasUpperLower   => _passwordCtrl.text.contains(RegExp(r'[A-Z]')) &&
                               _passwordCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumberSymbol => _passwordCtrl.text.contains(RegExp(r'[0-9]')) &&
                               _passwordCtrl.text.contains(RegExp(r'[!@#$%^&*]'));

  @override
  void dispose() {
    _matriculaCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit(AuthQRValidated validatedState) {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos para continuar.')),
      );
      return;
    }
    context.read<AuthBloc>().add(
      AuthRegisterSubmitted(password: _passwordCtrl.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthQRValidated) {
          // AutoFill de matrícula desde el QR
          _matriculaCtrl.text = state.credential.matricula;
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isQRValidated = state is AuthQRValidated;
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Header con botón atrás ─────────────────
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary, size: 20),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      // Logo oficial Mercalli en header
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentCyan.withOpacity(0.2),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/logo_mercalli.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40), // balance
                    ],
                  ),

                  const SizedBox(height: 20),
                  Text('Crea tu cuenta', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Acceso exclusivo con credencial física\nuniversitaria activa',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 28),

                  // ── Banner de QR validado ──────────────────
                  if (isQRValidated) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '✅ Credencial verificada: ${(state as AuthQRValidated).credential.name}',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Formulario ────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Matrícula ─────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Matrícula', style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                              )),
                              Text('Verificación escolar',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.accentCyan)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _matriculaCtrl,
                            keyboardType: TextInputType.number,
                            style: AppTextStyles.bodyLarge,
                            readOnly: isQRValidated, // bloqueado si ya fue llenado por QR
                            decoration: InputDecoration(
                              hintText: 'Ej. 20240189',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: isQRValidated
                                      ? AppColors.success
                                      : AppColors.accentCyan,
                                ),
                                onPressed: isQRValidated
                                    ? null
                                    : () => context.push(
                                        '${AppRoutes.qrScanner}?mode=register'),
                              ),
                            ),
                            validator: (v) =>
                                (v?.trim().isEmpty ?? true) ? 'Ingresa tu matrícula' : null,
                          ),
                          const SizedBox(height: 16),

                          // ── Contraseña ────────────────────────
                          Text('Contraseña', style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                          )),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: !_passwordVisible,
                            style: AppTextStyles.bodyLarge,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_passwordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () => setState(
                                    () => _passwordVisible = !_passwordVisible),
                              ),
                            ),
                            validator: (v) {
                              if (!_hasMinLength) return 'Mínimo 8 caracteres';
                              if (!_hasUpperLower) return 'Usa mayúsculas y minúsculas';
                              if (!_hasNumberSymbol) return 'Incluye un número y símbolo';
                              return null;
                            },
                          ),

                          // ── Indicadores de contraseña ─────────
                          const SizedBox(height: 10),
                          _PasswordCriteria(met: _hasMinLength, text: '8+ caracteres'),
                          const SizedBox(height: 4),
                          _PasswordCriteria(met: _hasUpperLower, text: 'Mayúscula y minúscula'),
                          const SizedBox(height: 4),
                          _PasswordCriteria(met: _hasNumberSymbol, text: 'Al menos un número y símbolo'),
                          const SizedBox(height: 16),

                          // ── Confirmar contraseña ──────────────
                          Text('Confirmar contraseña', style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                          )),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: true,
                            style: AppTextStyles.bodyLarge,
                            decoration: const InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: Icon(Icons.lock_reset_outlined),
                            ),
                            validator: (v) => v != _passwordCtrl.text
                                ? 'Las contraseñas no coinciden'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // ── Términos ──────────────────────────
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (v) =>
                                    setState(() => _acceptTerms = v ?? false),
                                activeColor: AppColors.accentBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                              Expanded(
                                child: Text(
                                  'Acepto los términos del marketplace y normas de convivencia del campus escolar.',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Botón crear cuenta ────────────────
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton.icon(
                                onPressed: (isLoading || !_acceptTerms)
                                    ? null
                                    : () {
                                        if (state is AuthQRValidated) {
                                          _submit(state);
                                        }
                                      },
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.arrow_forward_rounded, size: 20),
                                label: Text(isLoading
                                    ? 'Creando cuenta...'
                                    : 'Crear cuenta estudiantil →'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_outlined,
                            size: 14, color: AppColors.accentCyan),
                        const SizedBox(width: 8),
                        Text(
                          'Comunidad universitaria verificada · Cero intermediarios',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Indicador visual de criterio de contraseña (verde/gris).
class _PasswordCriteria extends StatelessWidget {
  final bool met;
  final String text;
  const _PasswordCriteria({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 14,
          color: met ? AppColors.success : AppColors.textHint,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: met ? AppColors.success : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
