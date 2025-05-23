import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/themes/color_schemes.dart';

class RegisterUpdatePage extends StatefulWidget {
  const RegisterUpdatePage({super.key});

  @override
  State<RegisterUpdatePage> createState() => _RegisterUpdatePageState();
}

class _RegisterUpdatePageState extends State<RegisterUpdatePage> {
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
                            'Isi Data ya',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                            ),
                          ),
                          4.height,
                          Text(
                            'Biar tau kamu itu suka di bidang apa',
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
                        'assets/images/onboarding-page-image.svg', // Assuming this is the illustration on the right
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
                    const Text(
                      'Tambah Foto',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F4F4F),
                      ),
                    ),
                    16.height,
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.textPrimary,
                            child: CircleAvatar(
                              radius: 59,
                              backgroundColor: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                // TODO: Implement image picker from camera/gallery
                                print(
                                  'Add photo pressed',
                                ); // Placeholder action
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    24.height,
                    const Text(
                      'Bio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F4F4F),
                      ),
                    ),
                    8.height,
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'bisa jelaskan tentang dirimu :)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    24.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Bidang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F4F4F),
                          ),
                        ),
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                      ],
                    ),
                    8.height,
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ), // Adjusted padding
                      ),
                      hint: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: Colors.grey[700],
                          ), // Placeholder icon
                          8.height,
                          const Text('Pilih bidangmu'),
                        ],
                      ),
                      value: 'Psikologi', // Default or selected value
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items:
                          <String>[
                            'Psikologi',
                            'Teknologi',
                            'Seni',
                            'Olahraga',
                          ] // Example items
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        // TODO: Handle field selection
                        print('Selected field: $newValue');
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
                      onPressed: () {},
                      child: const Text(
                        'Lanjut',
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
            ],
          ),
        ),
      ),
    );
  }
}
