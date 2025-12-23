import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          _buildProfileHeader(user?.fullName ?? 'MUSA', user?.email ?? 'musamwange2@gmail.com'),
          const SizedBox(height: 32),
          _buildSection('Account Settings'),
          _buildSettingItem(Icons.person_outline, 'Edit Profile', () {
             Navigator.of(context).push(
               MaterialPageRoute(builder: (context) => const EditProfileScreen()),
             );
          }),
          _buildSettingItem(Icons.notifications_none, 'Notifications', () {}, trailing: Switch(value: true, onChanged: (v) {})),
          _buildSettingItem(
            Icons.dark_mode_outlined, 
            'Dark Mode', 
            () {}, 
            trailing: Switch(
              value: themeMode == ThemeMode.dark, 
              onChanged: (v) => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSection('App Information'),
          _buildSettingItem(Icons.info_outline, 'About Komiut', () {}),
          _buildSettingItem(Icons.help_outline, 'Help & Support', () {}),
          _buildSettingItem(Icons.description_outlined, 'Terms of Service', () {}),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.1),
              foregroundColor: AppColors.error,
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: AppColors.navy,
          child: Icon(Icons.person, color: Colors.white, size: 40),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.navy),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
