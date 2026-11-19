import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// LoginPage — Inicio de sesión con matrícula + contraseña + QR.
/// Replica el mockup de la pantalla de login de Mercalli.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey    = GlobalKey<FormState>();
  final _matriculaCtrl = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _matriculaCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthLoginSubmitted(
      matricula: _matriculaCtrl.text.trim(),
      password: _passwordCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(state.message)),
              ]),
              backgroundColor: AppColors.bgCard,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ── Logo oficial Mercalli ─────────────────────
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentCyan.withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/logo_mercalli.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Ingresa con tu matrícula\nuniversitaria y contraseña',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: 32),

                // ── Formulario ────────────────────────────────
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
                        // Matrícula
                        Text('Matrícula', style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                        )),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _matriculaCtrl,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Ej. 20240189',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.qr_code_scanner_rounded,
                                  color: AppColors.accentCyan),
                              onPressed: () =>
                                  context.push('${AppRoutes.qrScanner}?mode=login'),
                            ),
                          ),
                          validator: (v) =>
                              (v?.trim().isEmpty ?? true) ? 'Ingresa tu matrícula' : null,
                        ),
                        const SizedBox(height: 16),

                        // Contraseña
                        Text('Contraseña', style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                        )),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: !_passwordVisible,
                          style: AppTextStyles.bodyLarge,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_passwordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _passwordVisible = !_passwordVisible),
                            ),
                          ),
                          validator: (v) =>
                              (v?.length ?? 0) < 8 ? 'Mínimo 8 caracteres' : null,
                        ),

                        // Olvidé contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {/* TODO */},
                            child: Text('¿Olvidaste tu contraseña?',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.accentCyan)),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Botón login
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton.icon(
                              onPressed: state is AuthLoading ? null : _submit,
                              icon: state is AuthLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.login_rounded, size: 20),
                              label: Text(
                                  state is AuthLoading ? 'Verificando...' : 'Iniciar sesión →'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Acceso exclusivo note
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 14, color: AppColors.accentBlue),
                    const SizedBox(width: 6),
                    Text(
                      'Acceso exclusivo para estudiantes con credencial física',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text('← Volver',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
