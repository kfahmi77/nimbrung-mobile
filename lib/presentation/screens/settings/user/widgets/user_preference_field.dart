import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/custom_drop_down_field.dart';
import '../../../../themes/color_schemes.dart';
import '../../../../../features/user/domain/entities/preference.dart';
import '../../../../../features/user/presentation/providers/user_providers.dart';

/// Widget for preference/field selection
class UserPreferenceField extends ConsumerWidget {
  final String? selectedPreferenceId;
  final bool isEditing;
  final ValueChanged<Preference?> onChanged;

  const UserPreferenceField({
    super.key,
    required this.selectedPreferenceId,
    required this.isEditing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(preferencesProvider);

    return preferencesAsync.when(
      data: (preferences) {
        // Find the selected preference, or null if none is selected
        Preference? selectedPreference;
        if (selectedPreferenceId != null) {
          try {
            selectedPreference = preferences.firstWhere(
              (pref) => pref.id == selectedPreferenceId,
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
            onChanged: isEditing ? onChanged : null,
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
}
