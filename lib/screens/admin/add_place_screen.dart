import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/postgres_service.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddPlaceScreen extends StatefulWidget {
  final Map<String, dynamic>? place;

  const AddPlaceScreen({super.key, this.place});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  
  String? _selectedImagePath;
  bool _isLoading = false;
  final PostgresService _postgresService = PostgresService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.place?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.place?['description'] ?? '');
    _categoryController = TextEditingController(text: widget.place?['category'] ?? 'Природа');
    _selectedImagePath = widget.place?['image_url'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isEditing = widget.place != null;

    return Scaffold(
      backgroundColor: themeProvider.getScaffoldBackgroundColor(),
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать место' : 'Добавить место'),
        backgroundColor: themeProvider.getAppBarColor(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: themeProvider.getInputFieldColor(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeProvider.getBorderColor()),
                    image: _selectedImagePath != null
                        ? DecorationImage(
                            image: _selectedImagePath!.startsWith('http')
                                ? NetworkImage(_selectedImagePath!)
                                : FileImage(File(_selectedImagePath!)) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImagePath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 48, color: themeProvider.getHintColor()),
                            const SizedBox(height: 8),
                            Text(
                              'Нажмите, чтобы выбрать фото',
                              style: TextStyle(color: themeProvider.getHintColor()),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                labelText: 'Название',
                prefixIcon: Icons.title,
                validator: (v) => v!.isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Описание',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Введите описание' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _categoryController,
                labelText: 'Категория',
                prefixIcon: Icons.category,
                validator: (v) => v!.isEmpty ? 'Введите категорию' : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: isEditing ? 'Обновить' : 'Сохранить',
                isLoading: _isLoading,
                onPressed: _savePlace,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите изображение')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.place != null) {
        await _postgresService.updatePlace(
          widget.place!['id'],
          _titleController.text,
          _descriptionController.text,
          _selectedImagePath!,
          _categoryController.text,
        );
      } else {
        await _postgresService.addPlace(
          _titleController.text,
          _descriptionController.text,
          _selectedImagePath!,
          _categoryController.text,
        );
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
