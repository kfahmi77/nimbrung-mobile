import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/presentation/extension/snackbar_extension.dart';
import 'package:nimbrung_mobile/presentation/themes/color_schemes.dart';
import 'package:nimbrung_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:nimbrung_mobile/features/auth/presentation/notifiers/app_auth_notifier.dart';
import 'package:nimbrung_mobile/features/user/presentation/providers/user_providers.dart';
import 'package:nimbrung_mobile/features/user/presentation/state/user_state.dart';
import 'package:nimbrung_mobile/presentation/widgets/custom_snackbar.dart';

// Import the new widget components
import 'widgets/user_profile_section.dart';
import 'widgets/personal_info_section.dart';
import 'widgets/bio_info_section.dart';
import 'widgets/preference_info_section.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  const UserInfoPage({super.key});

  @override
  ConsumerState<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _fullnameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _birthPlaceController;

  bool _isEditing = false;
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  String? _selectedPreferenceId;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _fullnameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
    _birthPlaceController = TextEditingController();

    // Initialize with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authState = ref.read(appAuthNotifierProvider);
    if (authState is AppAuthAuthenticated) {
      final user = authState.user;
      _usernameController.text = user.username ?? '';
      _fullnameController.text = user.fullname ?? '';
      _emailController.text = user.email;
      _bioController.text = user.bio ?? '';
      _birthPlaceController.text = user.birthPlace ?? '';
      _selectedGender = user.gender;
      _selectedBirthDate = user.dateBirth;
      _selectedPreferenceId = user.preferenceId;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(appAuthNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Informasi Pengguna',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            child: Text(
              _isEditing ? 'Simpan' : 'Edit',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body:
          authState is AppAuthAuthenticated
              ? _buildUserInfoContent(authState.user)
              : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildUserInfoContent(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Picture Section
            UserProfileSection(
              isEditing: _isEditing,
              onCameraTap: () {
                // TODO: Implement image picker functionality
              },
            ),

            24.height,

            // Personal Information Section
            PersonalInfoSection(
              usernameController: _usernameController,
              fullnameController: _fullnameController,
              emailController: _emailController,
              birthPlaceController: _birthPlaceController,
              selectedGender: _selectedGender,
              selectedBirthDate: _selectedBirthDate,
              isEditing: _isEditing,
              onGenderChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              onBirthDateTap: _selectBirthDate,
            ),

            24.height,

            // Bio Section
            BioInfoSection(
              bioController: _bioController,
              isEditing: _isEditing,
            ),

            24.height,

            // Preference Section
            PreferenceInfoSection(
              selectedPreferenceId: _selectedPreferenceId,
              isEditing: _isEditing,
              onChanged: (preference) {
                setState(() {
                  _selectedPreferenceId = preference?.id;
                });
              },
            ),

            32.height,
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final authState = ref.read(appAuthNotifierProvider);
        if (authState is AppAuthAuthenticated) {
          final userNotifier = ref.read(userProfileNotifierProvider.notifier);

          // Update the profile using the user feature with named parameters
          await userNotifier.updateProfile(
            userId: authState.user.id,
            username:
                _usernameController.text.trim().isNotEmpty
                    ? _usernameController.text.trim()
                    : null,
            fullname:
                _fullnameController.text.trim().isNotEmpty
                    ? _fullnameController.text.trim()
                    : null,
            bio:
                _bioController.text.trim().isNotEmpty
                    ? _bioController.text.trim()
                    : null,
            birthPlace:
                _birthPlaceController.text.trim().isNotEmpty
                    ? _birthPlaceController.text.trim()
                    : null,
            dateBirth: _selectedBirthDate,
            gender: _selectedGender,
            preferenceId: _selectedPreferenceId,
          );

          // Check if update was successful
          final userState = ref.read(userProfileNotifierProvider);
          if (userState is UserLoaded) {
            // Update auth state with new user data
            final authNotifier = ref.read(appAuthNotifierProvider.notifier);
            authNotifier.setAuthenticated(userState.user);

            if (mounted) {
              context.showCustomSnackbar(
                message: 'Informasi berhasil diperbarui',
                type: SnackbarType.success,
              );
            }
            setState(() {
              _isEditing = false;
            });
          } else if (userState is UserError) {
            if (mounted) {
              context.showCustomSnackbar(
                message: 'Gagal memperbarui informasi: ${userState.message}',
                type: SnackbarType.error,
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          context.showCustomSnackbar(
            message: 'Terjadi kesalahan: $e',
            type: SnackbarType.error,
          );
        }
      }
    }
  }
}
