import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/presentation/themes/color_schemes.dart';
import 'package:nimbrung_mobile/features/auth/auth.dart';

import '../../routes/route_name.dart';
import '../../widgets/buttons/custom_google_button.dart';
import '../../widgets/buttons/custom_primary_button.dart';
import '../../widgets/custom_drop_down_field.dart';
import '../../widgets/custom_password_field.dart';
import '../../widgets/custom_text_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedGender;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerNotifierProvider);

    // Listen to register state changes
    ref.listen<RegisterState>(registerNotifierProvider, (previous, next) {
      if (next is RegisterSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.green),
        );
        // Navigate to register-update page
        context.go('/register-update');
      } else if (next is RegisterFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section (unchanged)
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
                              'Daftar Dulu',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                              ),
                            ),
                            Text(
                              'Biar Ngerasain Serunya Nimbrung!',
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
                          'assets/images/register-page-image.svg',
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

                      // Username Field
                      CustomTextField(
                        label: 'Username',
                        hintText: 'Masukan username',
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          if (value.length < 3) {
                            return 'Username minimal 3 karakter';
                          }
                          return null;
                        },
                      ),

                      14.height,

                      // Fullname Field
                      CustomTextField(
                        label: 'Nama Lengkap',
                        hintText: 'Masukan nama lengkap',
                        controller: _fullnameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama lengkap tidak boleh kosong';
                          }
                          if (value.length < 2) {
                            return 'Nama lengkap minimal 2 karakter';
                          }
                          return null;
                        },
                      ),

                      14.height,

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

                      // Gender Dropdown
                      CustomDropdownField<String>(
                        label: 'Jenis Kelamin',
                        hintText: 'Pilih jenis kelamin',
                        value: _selectedGender,
                        items: _genders,
                        itemLabel: (gender) => gender,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
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

                      28.height,

                      // Register Button
                      CustomPrimaryButton(
                        text:
                            registerState is RegisterLoading
                                ? 'Mendaftar...'
                                : 'Daftar',
                        onPressed:
                            registerState is RegisterLoading
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_selectedGender == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Silakan pilih jenis kelamin',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // Call register method using Clean Architecture
                                    await ref
                                        .read(registerNotifierProvider.notifier)
                                        .register(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                          username:
                                              _usernameController.text.trim(),
                                          fullname:
                                              _fullnameController.text.trim(),
                                          gender: _selectedGender,
                                        );
                                  }
                                },
                      ),

                      24.height,

                      // Google Register Button
                      const CustomGoogleButton(text: 'Masuk dengan Google'),

                      30.height,

                      // Login Link
                      Center(
                        child: GestureDetector(
                          onTap: () => context.pushNamed(RouteNames.login),
                          child: RichText(
                            text: TextSpan(
                              text: 'Sudah punya akun? ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'masuk disini',
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
    );
  }
}
