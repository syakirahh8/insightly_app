// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header super simpel
        Row(
          children: [
            const CircleAvatar(
              radius: 28,
              child: Icon(Icons.person, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Name', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('name@email.com', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Kartu ringkas (opsional, bisa dihapus kalau mau lebih minimal)
        Card(
          child: Row(
            children: [
              _QuickStat(icon: Icons.bookmark_border, label: 'Saved', value: '24'),
              _QuickStat(icon: Icons.history, label: 'History', value: '12'),
              _QuickStat(icon: Icons.timer, label: 'Reading', value: '5h'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Toggle Dark/Light mode — inti permintaan
        Card(
          child: SwitchListTile(
            value: isDark,
            onChanged: (v) => Get.changeThemeMode(v ? ThemeMode.dark : ThemeMode.light),
            title: const Text('Dark Mode'),
            subtitle: Text(isDark ? 'On' : 'Off'),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
        ),

        const SizedBox(height: 8),

        // Beberapa aksi sederhana
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text('Saved Articles'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('Notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Logout sederhana
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListTile(
        leading: Icon(icon),
        title: Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(label),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        minLeadingWidth: 0,
      ),
    );
  }
}
