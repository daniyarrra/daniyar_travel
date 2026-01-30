import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/places_provider.dart';
import '../providers/theme_provider.dart';
import '../models/place.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameRuController = TextEditingController();
  final _nameKkController = TextEditingController();
  final _descriptionRuController = TextEditingController();
  final _descriptionKkController = TextEditingController();
  final _cityController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String _selectedCategory = AppConstants.placeCategories.first;
  String _selectedPriceRange = 'бесплатно';
  
  final List<String> _priceRanges = ['бесплатно', '\$', '\$\$', '\$\$\$'];

  @override
  void dispose() {
    _nameRuController.dispose();
    _nameKkController.dispose();
    _descriptionRuController.dispose();
    _descriptionKkController.dispose();
    _cityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final placesProvider = context.read<PlacesProvider>();
      
      // Создаем объект места
      // ID будет присвоен базой данных, здесь используем временный
      final newPlace = Place(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        nameRu: _nameRuController.text.trim(),
        nameKk: _nameKkController.text.trim().isEmpty 
            ? _nameRuController.text.trim() // Фолбэк на русский
            : _nameKkController.text.trim(),
        descriptionRu: _descriptionRuController.text.trim(),
        descriptionKk: _descriptionKkController.text.trim().isEmpty
            ? _descriptionRuController.text.trim()
            : _descriptionKkController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        rating: 0.0, // Новое место без рейтинга
        city: _cityController.text.trim(),
        category: _selectedCategory,
        latitude: 0.0, // В будущем можно добавить выбор на карте
        longitude: 0.0,
        priceRange: _selectedPriceRange,
        tags: [_selectedCategory.toLowerCase()],
      );

      try {
        await placesProvider.addPlace(newPlace);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Место успешно добавлено!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context); // Возвращаемся назад
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить место'),
      ),
      body: placesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Основная информация',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameRuController,
                      decoration: const InputDecoration(labelText: 'Название (RU) *'),
                      validator: (value) => value?.isEmpty ?? true ? 'Введите название' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameKkController,
                      decoration: const InputDecoration(labelText: 'Название (KZ)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Город *'),
                      validator: (value) => value?.isEmpty ?? true ? 'Введите город' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Категория'),
                      items: AppConstants.placeCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    Text(
                      'Описание и фото',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Ссылка на фото (URL) *',
                        hintText: 'https://example.com/image.jpg',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Введите ссылку';
                        if (!value.startsWith('http')) return 'Ссылка должна начинаться с http';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionRuController,
                      decoration: const InputDecoration(labelText: 'Описание (RU) *'),
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true ? 'Введите описание' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionKkController,
                      decoration: const InputDecoration(labelText: 'Описание (KZ)'),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedPriceRange,
                      decoration: const InputDecoration(labelText: 'Цена'),
                      items: _priceRanges.map((price) {
                        return DropdownMenuItem(
                          value: price,
                          child: Text(price),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriceRange = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Создать место',
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
