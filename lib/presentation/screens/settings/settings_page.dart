import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nimbrung_mobile/core/utils/extension/spacing_extension.dart';
import 'package:nimbrung_mobile/presentation/themes/color_schemes.dart';
import 'package:nimbrung_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:nimbrung_mobile/presentation/routes/route_name.dart';
import 'package:nimbrung_mobile/presentation/screens/settings/user/user_info_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
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
          'Pengaturan',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Section
            _buildSectionHeader('Umum'),
            12.height,
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: 'Informasi Pengguna',
                subtitle: 'Kelola profil dan informasi akun',
                onTap: () => _navigateToUserInfo(),
                showArrow: true,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.security,
                title: 'Kata sandi & Keamanan',
                subtitle: 'Ubah kata sandi dan pengaturan keamanan',
                onTap: () => _navigateToSecurity(),
                showArrow: true,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Preferensi Notifikasi',
                subtitle: 'Atur jenis notifikasi yang ingin diterima',
                onTap: () => _navigateToNotificationPreferences(),
                showArrow: true,
              ),
            ]),

            24.height,

            // App Settings Section
            _buildSectionHeader('Pengaturan Aplikasi'),
            12.height,
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.notifications,
                title: 'Notifikasi',
                subtitle: 'Aktifkan atau nonaktifkan notifikasi',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.dark_mode_outlined,
                title: 'Mode Gelap',
                subtitle: 'Ubah tema aplikasi ke mode gelap',
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.volume_up_outlined,
                title: 'Suara',
                subtitle: 'Aktifkan suara notifikasi dan efek',
                trailing: Switch(
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ]),

            24.height,

            // Others Section
            _buildSectionHeader('Lainnya'),
            12.height,
            _buildSettingsCard([
              _buildSettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Learn how we handle your information',
                onTap: () => _showPrivacyPolicy(),
                showArrow: true,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () => _showTermsOfService(),
                showArrow: true,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.help_outline,
                title: 'Bantuan',
                subtitle: 'Pusat bantuan dan dukungan',
                onTap: () => _showHelp(),
                showArrow: true,
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                subtitle: 'Versi 1.0.0',
                onTap: () => _showAboutApp(),
                showArrow: true,
              ),
            ]),

            32.height,

            // Logout Button
            _buildLogoutButton(),

            24.height,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    4.height,
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (showArrow) ...[
              8.width,
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 62),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[600]!],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(),
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToUserInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserInfoPage()),
    );
  }

  void _navigateToSecurity() {
    // Navigate to security settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan keamanan akan segera tersedia')),
    );
  }

  void _navigateToNotificationPreferences() {
    // Navigate to notification preferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferensi notifikasi akan segera tersedia'),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const SingleChildScrollView(
              child: Text(
                'Kebijakan Privasi\n\n'
                'Kami menghargai privasi Anda dan berkomitmen untuk melindungi informasi pribadi yang Anda berikan kepada kami.\n\n'
                '1. Informasi yang Kami Kumpulkan\n'
                '- Informasi profil (nama, email, foto)\n'
                '- Data penggunaan aplikasi\n'
                '- Preferensi pengguna\n\n'
                '2. Penggunaan Informasi\n'
                '- Memberikan layanan yang lebih baik\n'
                '- Personalisasi konten\n'
                '- Komunikasi dengan pengguna\n\n'
                '3. Keamanan Data\n'
                'Kami menggunakan enkripsi dan protokol keamanan terbaru untuk melindungi data Anda.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terms of Service'),
            content: const SingleChildScrollView(
              child: Text(
                'Syarat dan Ketentuan\n\n'
                'Dengan menggunakan aplikasi Nimbrung, Anda menyetujui syarat dan ketentuan berikut:\n\n'
                '1. Penggunaan Aplikasi\n'
                '- Aplikasi ini untuk keperluan edukasi dan sosial\n'
                '- Pengguna bertanggung jawab atas konten yang dibagikan\n'
                '- Dilarang menyebarkan konten yang melanggar hukum\n\n'
                '2. Hak dan Kewajiban\n'
                '- Pengguna berhak mendapat layanan sesuai fitur yang tersedia\n'
                '- Pengguna wajib memberikan informasi yang akurat\n'
                '- Kami berhak menangguhkan akun yang melanggar ketentuan\n\n'
                '3. Perubahan Ketentuan\n'
                'Kami dapat mengubah syarat dan ketentuan sewaktu-waktu dengan pemberitahuan kepada pengguna.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Bantuan'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pusat Bantuan Nimbrung\n\n'
                  'Jika Anda memerlukan bantuan, berikut adalah beberapa cara untuk menghubungi kami:\n\n'
                  '📧 Email: support@nimbrung.web.id\n'
                  '📱 WhatsApp: +62 812-3456-7890\n'
                  '🌐 Website: www.nimbrung.web.id/help\n\n'
                  'Tim dukungan kami siap membantu Anda 24/7.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tentang Nimbrung'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nimbrung Mobile\n'
                  'Versi 1.0.0\n\n'
                  'Aplikasi sosial untuk berbagi dan mendiskusikan buku, artikel, dan konten edukasi.\n\n'
                  '© 2025 Nimbrung Team\n'
                  'All rights reserved.\n\n'
                  'Dikembangkan dengan ❤️ untuk komunitas pembaca Indonesia.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Keluar'),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }

  Future<void> _logout() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Perform logout
    await ref.read(appAuthNotifierProvider.notifier).logout();

    // Navigation will be handled by auth state listener
    if (mounted) {
      context.goNamed(RouteNames.login);
    }
  }
}
