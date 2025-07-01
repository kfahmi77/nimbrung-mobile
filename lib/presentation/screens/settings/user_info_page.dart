import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/presentation/themes/color_schemes.dart';
import 'package:nimbrung_mobile/presentation/widgets/user_avatar.dart';
import 'package:nimbrung_mobile/presentation/widgets/custom_drop_down_field.dart';
import 'package:nimbrung_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:nimbrung_mobile/features/auth/presentation/notifiers/app_auth_notifier.dart';
import 'package:nimbrung_mobile/features/user/presentation/providers/user_providers.dart';
import 'package:nimbrung_mobile/features/user/presentation/state/user_state.dart';
import 'package:nimbrung_mobile/features/user/domain/entities/preference.dart';

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
            _buildProfileSection(),

            24.height,

            // Personal Information Card
            _buildInfoCard(
              title: 'Informasi Pribadi',
              children: [
                _buildInfoField(
                  label: 'Username',
                  controller: _usernameController,
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                _buildInfoField(
                  label: 'Nama Lengkap',
                  controller: _fullnameController,
                  icon: Icons.badge_outlined,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Nama lengkap tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                _buildInfoField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  enabled: false, // Email usually shouldn't be editable
                ),
                _buildGenderField(),
                _buildBirthDateField(),
                _buildInfoField(
                  label: 'Tempat Lahir',
                  controller: _birthPlaceController,
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),

            24.height,

            // Bio Card
            _buildInfoCard(title: 'Bio', children: [_buildBioField()]),

            24.height,

            // Preference Card
            _buildInfoCard(
              title: 'Preferensi',
              children: [_buildPreferenceField()],
            ),

            32.height,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Stack(
        children: [
          UserAvatar(radius: 60, borderColor: Colors.white, borderWidth: 4),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing && enabled,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          filled: true,
          fillColor: _isEditing && enabled ? Colors.white : Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Jenis Kelamin',
          prefixIcon: Icon(Icons.wc_outlined, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey[50],
        ),
        items: const [
          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
        ],
        onChanged:
            _isEditing
                ? (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                }
                : null,
      ),
    );
  }

  Widget _buildBirthDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: TextEditingController(
          text:
              _selectedBirthDate != null
                  ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                  : '',
        ),
        enabled: _isEditing,
        readOnly: true,
        onTap: _isEditing ? () => _selectBirthDate() : null,
        decoration: InputDecoration(
          labelText: 'Tanggal Lahir',
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            color: AppColors.primary,
          ),
          suffixIcon:
              _isEditing
                  ? Icon(Icons.arrow_drop_down, color: AppColors.primary)
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      enabled: _isEditing,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Bio',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Icon(Icons.info_outline, color: AppColors.primary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey[50],
      ),
    );
  }

  Widget _buildPreferenceField() {
    final preferencesAsync = ref.watch(preferencesProvider);

    return preferencesAsync.when(
      data: (preferences) {
        // Find the selected preference, or null if none is selected
        Preference? selectedPreference;
        if (_selectedPreferenceId != null) {
          try {
            selectedPreference = preferences.firstWhere(
              (pref) => pref.id == _selectedPreferenceId,
            );
          } catch (e) {
            selectedPreference = null;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CustomDropdownField<Preference>(
            label: 'Bidang Preferensi',
            hintText: 'Pilih bidang preferensi',
            value: selectedPreference,
            items: preferences,
            itemLabel: (preference) => preference.preferencesName ?? 'Unknown',
            prefixIcon: Icon(Icons.favorite_outline, color: AppColors.primary),
            onChanged:
                _isEditing
                    ? (preference) {
                      setState(() {
                        _selectedPreferenceId = preference?.id;
                      });
                    }
                    : null,
          ),
        );
      },
      loading:
          () => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stackTrace) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                'Error loading preferences: $error',
                style: TextStyle(color: Colors.red[700]),
              ),
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

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Informasi berhasil diperbarui'),
                backgroundColor: AppColors.primary,
              ),
            );

            setState(() {
              _isEditing = false;
            });
          } else if (userState is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Gagal memperbarui informasi: ${userState.message}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
