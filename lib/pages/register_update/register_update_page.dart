import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/core/widgets/custom_date_form_field.dart';
import 'package:nimbrung_mobile/core/widgets/custom_drop_down_field.dart';
import 'package:nimbrung_mobile/core/widgets/profile_photo_picker.dart';
import 'package:nimbrung_mobile/themes/color_schemes.dart';

import '../../core/widgets/custom_text_field.dart';

class RegisterUpdatePage extends StatefulWidget {
  const RegisterUpdatePage({super.key});

  @override
  State<RegisterUpdatePage> createState() => _RegisterUpdatePageState();
}

class _RegisterUpdatePageState extends State<RegisterUpdatePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final List<String> _field = ['Teknologi', 'Sains', 'Sejarah', 'Agama'];
  String? _selectedField;

  @override
  void dispose() {
    _dateController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                    Center(child: ProfilePhotoPicker(label: "Foto Profil")),
                    24.height,
                    8.height,
                    CustomTextField(
                      label: 'Bio',
                      maxLines: 3,
                      hintText: 'Tuliskan tentang dirimu :)',
                      controller: null,
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
                            controller: null,
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
                    CustomDropdownField<String>(
                      label: 'Bidang',
                      hintText: 'Pilih bidang favoritmu',
                      value: _selectedField,
                      items: _field,
                      itemLabel: (gender) => gender,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedField = newValue;
                        });
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
                      onPressed: () {
                        // TODO: Handle form submission
                        print('Place of birth: ${_placeController.text}');
                        print('Date of birth: ${_dateController.text}');
                      },
                      child: const Text(
                        'Masuk',
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
    );
  }
}
