import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
import 'auth/login_screen.dart';
import 'reports_screen.dart';
import 'admin/admin_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    // Если пользователь не авторизован, показываем экран входа (встроенный в таб)
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Если авторизован - показываем профиль
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: themeProvider.getIconColor(),
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 50,
              backgroundColor: themeProvider.getPrimaryColor().withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 60,
                color: themeProvider.getPrimaryColor(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              authProvider.user?.email ?? 'Пользователь',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.getTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${authProvider.user?.id.length != null && authProvider.user!.id.length > 8 ? authProvider.user!.id.substring(0, 8) + '...' : authProvider.user?.id}',
              style: TextStyle(
                color: themeProvider.getSecondaryTextColor(),
              ),
            ),
            const SizedBox(height: 48),
            ListTile(
              leading: Icon(Icons.bar_chart, color: themeProvider.getPrimaryColor()),
              title: const Text('Статистика'),
              subtitle: const Text('Отчеты из базы данных'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.admin_panel_settings, color: themeProvider.getPrimaryColor()),
              title: const Text('Админ-панель'),
              subtitle: const Text('Управление контентом'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Настройки'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Помощь'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Помощь'),
                    content: const Text('у данияра спроси'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ок'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Выйти',
                backgroundColor: Colors.red.shade400,
                onPressed: () async {
                  await authProvider.signOut();
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
