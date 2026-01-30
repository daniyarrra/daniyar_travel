import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routes_provider.dart';
import '../providers/places_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Экран создания нового маршрута путешествия
/// Позволяет создать маршрут с названием, датами, бюджетом и местами
class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCurrency = 'KZT';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildDateSection(),
              const SizedBox(height: 24),
              _buildBudgetSection(),
              const SizedBox(height: 24),
              _buildDescriptionSection(),
              const SizedBox(height: 24),
              _buildPlacesSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Создание AppBar
  PreferredSizeWidget _buildAppBar() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return AppBar(
      backgroundColor: themeProvider.getAppBarColor(),
      elevation: 0,
      title: Text(
        languageProvider.getLocalizedText(
          'Создать маршрут',
          'Маршрут жасау'
        ),
        style: TextStyle(
          color: themeProvider.getTextColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: themeProvider.getIconColor(),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Секция основной информации
  Widget _buildBasicInfoSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.getLocalizedText(
            'Основная информация',
            'Негізгі ақпарат'
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.getTextColor(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: languageProvider.getLocalizedText(
              'Название маршрута',
              'Маршрут атауы'
            ),
            hintText: languageProvider.getLocalizedText(
              'Введите название маршрута',
              'Маршрут атауын енгізіңіз'
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            filled: true,
            fillColor: themeProvider.getInputFieldColor(),
          ),
          style: TextStyle(color: themeProvider.getTextColor()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return languageProvider.getLocalizedText(
                'Введите название маршрута',
                'Маршрут атауын енгізіңіз'
              );
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Секция дат
  Widget _buildDateSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.getLocalizedText(
            'Даты путешествия',
            'Саяхат күндері'
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.getTextColor(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: languageProvider.getLocalizedText(
                  'Дата начала',
                  'Басталу күні'
                ),
                date: _startDate,
                onTap: () => _selectStartDate(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: languageProvider.getLocalizedText(
                  'Дата окончания',
                  'Аяқталу күні'
                ),
                date: _endDate,
                onTap: () => _selectEndDate(),
              ),
            ),
          ],
        ),
        if (_startDate != null && _endDate != null) ...[
          const SizedBox(height: 12),
          Text(
            languageProvider.getLocalizedText(
              'Продолжительность: ${_calculateDuration()} дней',
              'Ұзақтығы: ${_calculateDuration()} күн'
            ),
            style: TextStyle(
              color: themeProvider.getSecondaryTextColor(),
            ),
          ),
        ],
      ],
    );
  }

  /// Поле выбора даты
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: themeProvider.getInputFieldBorderColor()),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          color: themeProvider.getInputFieldColor(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.getLabelColor(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null 
                  ? AppHelpers.formatDateShort(date)
                  : 'Выберите дату',
              style: TextStyle(
                fontSize: 16,
                color: date != null 
                    ? themeProvider.getTextColor()
                    : themeProvider.getHintColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Секция бюджета
  Widget _buildBudgetSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.getLocalizedText(
            'Бюджет',
            'Бюджет'
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.getTextColor(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: languageProvider.getLocalizedText(
                    'Сумма',
                    'Сома'
                  ),
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  filled: true,
                  fillColor: themeProvider.getInputFieldColor(),
                ),
                style: TextStyle(color: themeProvider.getTextColor()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return languageProvider.getLocalizedText(
                      'Введите сумму',
                      'Соманы енгізіңіз'
                    );
                  }
                  if (double.tryParse(value) == null) {
                    return languageProvider.getLocalizedText(
                      'Введите корректную сумму',
                      'Дұрыс соманы енгізіңіз'
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: languageProvider.getLocalizedText(
                    'Валюта',
                    'Валюта'
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  filled: true,
                  fillColor: themeProvider.getInputFieldColor(),
                ),
                items: AppConstants.currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Секция описания
  Widget _buildDescriptionSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.getLocalizedText(
            'Описание',
            'Сипаттама'
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.getTextColor(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: languageProvider.getLocalizedText(
              'Описание маршрута (необязательно)',
              'Маршрут сипаттамасы (міндетті емес)'
            ),
            hintText: languageProvider.getLocalizedText(
              'Расскажите о вашем путешествии...',
              'Саяхатыңыз туралы айтыңыз...'
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            filled: true,
            fillColor: themeProvider.getInputFieldColor(),
          ),
          style: TextStyle(color: themeProvider.getTextColor()),
        ),
      ],
    );
  }

  /// Секция мест
  Widget _buildPlacesSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              languageProvider.getLocalizedText(
                'Места в маршруте',
                'Маршруттағы орындар'
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.getTextColor(),
              ),
            ),
            TextButton.icon(
              onPressed: _addPlaces,
              icon: Icon(
                Icons.add,
                color: themeProvider.getPrimaryColor(),
              ),
              label: Text(
                languageProvider.getLocalizedText(
                  'Добавить',
                  'Қосу'
                ),
                style: TextStyle(
                  color: themeProvider.getPrimaryColor(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.getSurfaceColor(),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: themeProvider.getBorderColor(),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_on,
                size: 48,
                color: themeProvider.getSecondaryTextColor(),
              ),
              const SizedBox(height: 8),
              Text(
                languageProvider.getLocalizedText(
                  'Места будут добавлены позже',
                  'Орындар кейінірек қосылады'
                ),
                style: TextStyle(
                  color: themeProvider.getSecondaryTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Кнопки действий
  Widget _buildActionButtons() {
    final languageProvider = context.watch<LanguageProvider>();
    
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: languageProvider.getLocalizedText(
              'Отмена',
              'Болдырмау'
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            isOutlined: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: languageProvider.getLocalizedText(
              'Создать',
              'Жасау'
            ),
            onPressed: _isLoading ? null : _createRoute,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  /// Выбор даты начала
  Future<void> _selectStartDate() async {
    final languageProvider = context.read<LanguageProvider>();
    final now = DateTime.now();
    
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: Locale(languageProvider.currentLanguage),
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
        // Если дата окончания раньше даты начала, сбрасываем её
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  /// Выбор даты окончания
  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().getLocalizedText(
              'Сначала выберите дату начала',
              'Алдымен басталу күнін таңдаңыз'
            ),
          ),
          backgroundColor: context.read<ThemeProvider>().getSnackBarColor(),
        ),
      );
      return;
    }
    
    final languageProvider = context.read<LanguageProvider>();
    
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 365)),
      locale: Locale(languageProvider.currentLanguage),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  /// Вычисление продолжительности
  int _calculateDuration() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  /// Добавление мест
  void _addPlaces() {
    // TODO: Реализовать выбор мест
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<LanguageProvider>().getLocalizedText(
            'Выбор мест будет реализован',
            'Орындарды таңдау жүзеге асырылады'
          ),
        ),
        backgroundColor: context.read<ThemeProvider>().getSnackBarColor(),
      ),
    );
  }

  /// Создание маршрута
  Future<void> _createRoute() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LanguageProvider>().getLocalizedText(
              'Выберите даты путешествия',
              'Саяхат күндерін таңдаңыз'
            ),
          ),
          backgroundColor: context.read<ThemeProvider>().getErrorColor(),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await context.read<RoutesProvider>().createRoute(
        name: _nameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        budget: double.parse(_budgetController.text),
        currency: _selectedCurrency,
        description: _descriptionController.text.trim(),
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LanguageProvider>().getLocalizedText(
                'Маршрут создан успешно',
                'Маршрут сәтті жасалды'
              ),
            ),
            backgroundColor: context.read<ThemeProvider>().getSuccessColor(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: context.read<ThemeProvider>().getErrorColor(),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
