import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/postgres_service.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';
import 'add_place_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostgresService _postgresService = PostgresService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: themeProvider.getScaffoldBackgroundColor(),
      appBar: AppBar(
        title: const Text('Админ-панель'),
        backgroundColor: themeProvider.getAppBarColor(),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Места'),
            Tab(text: 'Пользователи'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlacesTab(themeProvider),
          _buildUsersTab(themeProvider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlaceScreen()),
          );
          if (result == true) {
            setState(() {}); // Обновить список после добавления
          }
        },
        backgroundColor: themeProvider.getFloatingActionButtonColor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlacesTab(ThemeProvider themeProvider) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _postgresService.getPlaces(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        final places = snapshot.data ?? [];

        if (places.isEmpty) {
          return const Center(child: Text('Нет мест. Добавьте первое!'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return Card(
              color: themeProvider.getCardColor(),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: place['image_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: place['image_url'].startsWith('http')
                            ? Image.network(
                                place['image_url'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                              )
                            : Image.file(
                                File(place['image_url']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                              ),
                      )
                    : const Icon(Icons.place),
                title: Text(
                  place['title'] ?? 'Без названия',
                  style: TextStyle(color: themeProvider.getTextColor()),
                ),
                subtitle: Text(
                  place['category'] ?? 'Без категории',
                  style: TextStyle(color: themeProvider.getSecondaryTextColor()),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPlaceScreen(place: place),
                          ),
                        );
                        if (result == true) {
                          setState(() {});
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(place['id'], place['title']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersTab(ThemeProvider themeProvider) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _postgresService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              color: themeProvider.getCardColor(),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  user['email'] ?? 'Нет Email',
                  style: TextStyle(color: themeProvider.getTextColor()),
                ),
                subtitle: Text(
                  'ID: ${user['id']} | Создан: ${user['created_at']?.toString().split('.').first ?? '-'}',
                  style: TextStyle(color: themeProvider.getSecondaryTextColor()),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(int id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление'),
        content: Text('Вы уверены, что хотите удалить "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _postgresService.deletePlace(id);
        setState(() {}); // Обновить список
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Место удалено')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка удаления: $e')),
          );
        }
      }
    }
  }
}
