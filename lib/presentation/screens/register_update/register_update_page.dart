import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/presentation/widgets/custom_date_form_field.dart';
import 'package:nimbrung_mobile/presentation/widgets/custom_drop_down_field.dart';
import 'package:nimbrung_mobile/presentation/widgets/enhanced_profile_photo_picker.dart';
import 'package:nimbrung_mobile/presentation/themes/color_schemes.dart';
import 'package:nimbrung_mobile/features/auth/auth.dart';
import 'dart:io';

import '../../widgets/custom_text_field.dart';

class RegisterUpdatePage extends ConsumerStatefulWidget {
  const RegisterUpdatePage({super.key});

  @override
  ConsumerState<RegisterUpdatePage> createState() => _RegisterUpdatePageState();
}

class _RegisterUpdatePageState extends ConsumerState<RegisterUpdatePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Store selected preference ID instead of name
  String? _selectedPreferenceId;

  // Store selected avatar file
  File? _selectedAvatarFile;

  @override
  void initState() {
    super.initState();
    // Load current user when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentUserNotifierProvider.notifier).getCurrentUser();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _placeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileUpdateState = ref.watch(
      profileUpdateWithImageNotifierProvider,
    );
    final currentUserState = ref.watch(currentUserNotifierProvider);

    // Listen to profile update state changes
    ref.listen<ProfileUpdateState>(profileUpdateWithImageNotifierProvider, (
      previous,
      next,
    ) {
      if (next is ProfileUpdateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.green),
        );
        // Navigate to home page
        context.go('/home');
      } else if (next is ProfileUpdateFailure) {
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
                SizedBox(
                  width: double.infinity,
                  height: 234,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 234,
                        decoration: BoxDecoration(
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
                      Positioned(
                        bottom: 50,
                        left: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Perbarui Data ya',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                              ),
                            ),
                            4.height,
                            Text(
                              'Biar kami bisa mengenalmu lebih baik :)',
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
                          'assets/images/onboarding-page-image.svg',
                          width: 120,
                          height: 118,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      24.height,
                      Center(
                        child: ProfilePhotoPicker(
                          label: "Foto Profil",
                          onImageSelected: (File? file) {
                            setState(() {
                              _selectedAvatarFile = file;
                            });
                          },
                          initialImageUrl:
                              currentUserState is CurrentUserLoaded &&
                                      currentUserState.user != null
                                  ? currentUserState.user!.avatar
                                  : null,
                        ),
                      ),
                      24.height,
                      8.height,
                      CustomTextField(
                        label: 'Bio',
                        maxLines: 3,
                        hintText: 'Tuliskan tentang dirimu :)',
                        controller: _bioController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'bio tidak boleh kosong';
                          }
                          if (value.length < 3) {
                            return 'bio minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      24.height,
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              label: 'Data Diri',
                              hintText: 'Masukan tempat lahir',
                              controller: _placeController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tempat lahir tidak boleh kosong';
                                }
                                if (value.length < 2) {
                                  return 'Tempat lahir minimal 2 karakter';
                                }
                                return null;
                              },
                            ),
                          ),
                          12.width,
                          Expanded(
                            flex: 2,
                            child: CustomDateField(
                              label: "",
                              hintText: "Masukan tanggal lahir",
                              controller: _dateController,
                            ),
                          ),
                        ],
                      ),
                      24.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                      8.height,
                      // Preferences Dropdown with data from database
                      Consumer(
                        builder: (context, ref, child) {
                          final preferencesAsync = ref.watch(
                            preferencesProvider,
                          );

                          return preferencesAsync.when(
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error:
                                (error, stack) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bidang',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    8.height,
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Gagal memuat data bidang: ${error.toString()}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            data: (preferences) {
                              return CustomDropdownField<String>(
                                label: 'Bidang',
                                hintText: 'Pilih bidang favoritmu',
                                value: _selectedPreferenceId,
                                items:
                                    preferences.map((pref) => pref.id).toList(),
                                itemLabel: (preferenceId) {
                                  // Find the preference name by ID
                                  final preference = preferences.firstWhere(
                                    (pref) => pref.id == preferenceId,
                                    orElse:
                                        () =>
                                            preferences.isNotEmpty
                                                ? preferences.first
                                                : Preference(
                                                  id: '',
                                                  preferencesName: 'Unknown',
                                                  createdAt: DateTime.now(),
                                                ),
                                  );
                                  return preference.preferencesName ??
                                      'Unknown';
                                },
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedPreferenceId = newValue;
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),

                      32.height,
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed:
                            profileUpdateState is ProfileUpdateLoading
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_selectedPreferenceId == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Silakan pilih bidang favorit',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // Get current user from state
                                    String? currentUserId;
                                    if (currentUserState is CurrentUserLoaded &&
                                        currentUserState.user != null) {
                                      currentUserId = currentUserState.user!.id;
                                    }

                                    if (currentUserId == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Sesi login telah berakhir',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      context.go('/');
                                      return;
                                    }

                                    // Parse date of birth
                                    DateTime? dateBirth;
                                    if (_dateController.text.isNotEmpty) {
                                      try {
                                        // Handle DD/MM/YYYY format from CustomDateField
                                        final dateText =
                                            _dateController.text.trim();
                                        if (dateText.contains('/')) {
                                          // Split DD/MM/YYYY format
                                          final parts = dateText.split('/');
                                          if (parts.length == 3) {
                                            final day = int.parse(parts[0]);
                                            final month = int.parse(parts[1]);
                                            final year = int.parse(parts[2]);
                                            dateBirth = DateTime(
                                              year,
                                              month,
                                              day,
                                            );
                                          } else {
                                            throw const FormatException(
                                              'Invalid date format',
                                            );
                                          }
                                        } else {
                                          // Try to parse as ISO format
                                          dateBirth = DateTime.parse(dateText);
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Format tanggal tidak valid. Gunakan format DD/MM/YYYY',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                    }

                                    // Call profile update method with image
                                    await ref
                                        .read(
                                          profileUpdateWithImageNotifierProvider
                                              .notifier,
                                        )
                                        .updateProfileWithImage(
                                          userId: currentUserId,
                                          bio: _bioController.text.trim(),
                                          birthPlace:
                                              _placeController.text.trim(),
                                          dateBirth: dateBirth,
                                          preferenceId: _selectedPreferenceId,
                                          avatarFile: _selectedAvatarFile,
                                          existingAvatarUrl:
                                              currentUserState
                                                          is CurrentUserLoaded &&
                                                      currentUserState.user !=
                                                          null
                                                  ? currentUserState
                                                      .user!
                                                      .avatar
                                                  : null,
                                        );
                                  }
                                },
                        child: Text(
                          profileUpdateState is ProfileUpdateLoading
                              ? 'Memperbarui...'
                              : 'Selesai',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                28.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
