// refactored_login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/presentation/extension/snackbar_extension.dart';
import 'package:nimbrung_mobile/presentation/routes/route_name.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/presentation/themes/color_schemes.dart';
import 'package:nimbrung_mobile/features/auth/auth.dart';
import 'package:nimbrung_mobile/presentation/widgets/custom_snackbar.dart';

import '../../widgets/buttons/custom_google_button.dart';
import '../../widgets/buttons/custom_primary_button.dart';
import '../../widgets/custom_password_field.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);

    // Listen to app auth state for navigation
    ref.listen<AppAuthState>(appAuthNotifierProvider, (previous, next) {
      if (next is AppAuthAuthenticated) {
        // User is authenticated, navigate based on profile completion
        // Use pushReplacement to completely replace the navigation stack
        if (next.user.isProfileComplete) {
          // Clear the entire navigation stack and go to home
          context.goNamed(RouteNames.home);
          // Alternative: Use pushReplacementNamed if available
          // context.pushReplacementNamed(RouteNames.home);
        } else {
          // Clear the stack and go to profile update
          context.goNamed(RouteNames.registerUpdate);
          // Alternative: Use pushReplacementNamed if available
          // context.pushReplacementNamed(RouteNames.registerUpdate);
        }
      }
    });

    // Listen to login state for UI feedback
    ref.listen<LoginState>(loginNotifierProvider, (previous, next) {
      if (next is LoginSuccess) {
        context.showCustomSnackbar(
          message: 'Login successful!',
          type: SnackbarType.success,
        );
        // Don't navigate here as it's handled by AppAuthState listener above
        // This prevents double navigation which can cause navigation stack issues
      } else if (next is LoginFailure) {
        context.showCustomSnackbar(
          message: next.message,
          type: SnackbarType.error,
        );
      }
    });

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Theme.of(context).primaryColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 234,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 234,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 28,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/images/logo2.svg',
                              fit: BoxFit.contain,
                              width: 158,
                              height: 40,
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 50,
                          left: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Masuk Yuk!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.background,
                                ),
                              ),
                              Text(
                                'Kita Nimbrung Didalem',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          right: 18,
                          child: SvgPicture.asset(
                            'assets/images/login-page-image.svg',
                            width: 120,
                            height: 118,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Section using reusable widgets
                  Padding(
                    padding: const EdgeInsets.only(left: 28, right: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        20.height,

                        // Email Field
                        CustomTextField(
                          label: 'Email',
                          hintText: 'Masukan email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),

                        14.height,

                        // Password Field
                        CustomPasswordField(
                          label: 'Sandi',
                          hintText: 'Masukan sandi',
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Sandi tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Sandi minimal 6 karakter';
                            }
                            return null;
                          },
                        ),

                        14.height,

                        // Forgot Password Link
                        const Text(
                          'Lupa sandi?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        14.height,

                        // Login Button
                        CustomPrimaryButton(
                          text:
                              loginState is LoginLoading ? 'Masuk...' : 'Masuk',
                          onPressed:
                              loginState is LoginLoading
                                  ? null
                                  : () async {
                                    if (_formKey.currentState!.validate()) {
                                      await ref
                                          .read(loginNotifierProvider.notifier)
                                          .login(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                          );
                                    }
                                  },
                        ),
                        24.height,
                        // Google Login Button
                        Builder(
                          builder: (context) {
                            final appAuthState = ref.watch(
                              appAuthNotifierProvider,
                            );
                            final isLoading = appAuthState is AppAuthLoading;
                            return CustomGoogleButton(
                              text:
                                  isLoading
                                      ? 'Memproses...'
                                      : 'Masuk dengan Google',
                              onPressed:
                                  isLoading
                                      ? null
                                      : () async {
                                        await ref
                                            .read(
                                              appAuthNotifierProvider.notifier,
                                            )
                                            .loginWithGoogle();
                                      },
                            );
                          },
                        ),
                        30.height,
                        // Register Link
                        Center(
                          child: GestureDetector(
                            onTap: () => context.pushNamed(RouteNames.register),
                            child: RichText(
                              text: TextSpan(
                                text: 'Belum punya akun? ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Daftar disini',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        20.height,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
