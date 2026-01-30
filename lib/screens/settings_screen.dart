import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

/// Экран настроек приложения
/// Позволяет изменить язык, тему и другие настройки
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          _buildLanguageSection(context),
          const SizedBox(height: 24),
          _buildThemeSection(context),
          const SizedBox(height: 24),
          _buildAppInfoSection(context),
          const SizedBox(height: 24),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  /// Создание AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return AppBar(
      backgroundColor: themeProvider.getAppBarColor(),
      elevation: 0,
      title: Text(
        languageProvider.getLocalizedText(
          'Настройки',
          'Баптаулар'
        ),
        style: TextStyle(
          color: themeProvider.getTextColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Секция языка
  Widget _buildLanguageSection(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return _buildSection(
      context,
      title: languageProvider.getLocalizedText(
        'Язык',
        'Тіл'
      ),
      children: [
        _buildLanguageOption(
          context,
          languageCode: 'ru',
          languageName: 'Русский',
          isSelected: languageProvider.isRussian,
          onTap: () => languageProvider.switchToRussian(),
        ),
        _buildLanguageOption(
          context,
          languageCode: 'kk',
          languageName: 'Қазақша',
          isSelected: languageProvider.isKazakh,
          onTap: () => languageProvider.switchToKazakh(),
        ),
      ],
    );
  }

  /// Секция темы
  Widget _buildThemeSection(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return _buildSection(
      context,
      title: languageProvider.getLocalizedText(
        'Тема',
        'Тақырып'
      ),
      children: [
        _buildThemeOption(
          context,
          themeName: languageProvider.getLocalizedText(
            'Светлая',
            'Жарық'
          ),
          isSelected: themeProvider.isLightMode,
          onTap: () => themeProvider.setLightTheme(),
        ),
        _buildThemeOption(
          context,
          themeName: languageProvider.getLocalizedText(
            'Темная',
            'Қараңғы'
          ),
          isSelected: themeProvider.isDarkMode,
          onTap: () => themeProvider.setDarkTheme(),
        ),
      ],
    );
  }

  /// Секция информации о приложении
  Widget _buildAppInfoSection(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return _buildSection(
      context,
      title: languageProvider.getLocalizedText(
        'Информация о приложении',
        'Қосымша туралы ақпарат'
      ),
      children: [
        _buildInfoTile(
          context,
          icon: Icons.info,
          title: languageProvider.getLocalizedText(
            'Версия',
            'Нұсқа'
          ),
          subtitle: AppConstants.appVersion,
        ),
        _buildInfoTile(
          context,
          icon: Icons.phone_android,
          title: languageProvider.getLocalizedText(
            'Платформа',
            'Платформа'
          ),
          subtitle: 'Flutter',
        ),
        _buildInfoTile(
          context,
          icon: Icons.developer_mode,
          title: languageProvider.getLocalizedText(
            'Разработчик',
            'Әзірлеуші'
          ),
          subtitle: 'Donch1ka',
        ),
      ],
    );
  }

  /// Секция "О приложении"
  Widget _buildAboutSection(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return _buildSection(
      context,
      title: languageProvider.getLocalizedText(
        'О приложении',
        'Қосымша туралы'
      ),
      children: [
        _buildActionTile(
          context,
          icon: Icons.help,
          title: languageProvider.getLocalizedText(
            'Помощь',
            'Көмек'
          ),
          onTap: () => _showHelpDialog(context),
        ),
        _buildActionTile(
          context,
          icon: Icons.privacy_tip,
          title: languageProvider.getLocalizedText(
            'Политика конфиденциальности',
            'Құпиялылық саясаты'
          ),
          onTap: () => _showPrivacyDialog(context),
        ),
        _buildActionTile(
          context,
          icon: Icons.description,
          title: languageProvider.getLocalizedText(
            'Условия использования',
            'Пайдалану шарттары'
          ),
          onTap: () => _showTermsDialog(context),
        ),
        _buildActionTile(
          context,
          icon: Icons.feedback,
          title: languageProvider.getLocalizedText(
            'Обратная связь',
            'Кері байланыс'
          ),
          onTap: () => _showFeedbackDialog(context),
        ),
      ],
    );
  }

  /// Создание секции
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.getTextColor(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: themeProvider.getCardColor(),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: themeProvider.getBorderColor(),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// Опция языка
  Widget _buildLanguageOption(
    BuildContext context, {
    required String languageCode,
    required String languageName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return ListTile(
      title: Text(
        languageName,
        style: TextStyle(
          color: themeProvider.getTextColor(),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: themeProvider.getPrimaryColor(),
            )
          : null,
      onTap: onTap,
    );
  }

  /// Опция темы
  Widget _buildThemeOption(
    BuildContext context, {
    required String themeName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return ListTile(
      title: Text(
        themeName,
        style: TextStyle(
          color: themeProvider.getTextColor(),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: themeProvider.getPrimaryColor(),
            )
          : null,
      onTap: onTap,
    );
  }

  /// Информационная плитка
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return ListTile(
      leading: Icon(
        icon,
        color: themeProvider.getIconColor(),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: themeProvider.getTextColor(),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: themeProvider.getSecondaryTextColor(),
        ),
      ),
    );
  }

  /// Плитка действия
  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return ListTile(
      leading: Icon(
        icon,
        color: themeProvider.getIconColor(),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: themeProvider.getTextColor(),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: themeProvider.getSecondaryTextColor(),
      ),
      onTap: onTap,
    );
  }

  /// Показ диалога помощи
  void _showHelpDialog(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final themeProvider = context.read<ThemeProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.getDialogColor(),
        title: Text(
          languageProvider.getLocalizedText(
            'Помощь',
            'Көмек'
          ),
          style: TextStyle(
            color: themeProvider.getDialogTitleColor(),
          ),
        ),
        content: Text(
          languageProvider.getLocalizedText(
            'TravelKZ - это приложение для планирования путешествий по Казахстану. Вы можете:\n\n• Искать интересные места\n• Создавать маршруты\n• Планировать бюджет\n• Ведить чек-лист\n• Сохранять избранное',
            'TravelKZ - Қазақстан бойынша саяхат жоспарлау қосымшасы. Сіз мынаны жасай аласыз:\n\n• Қызықты орындарды іздеу\n• Маршруттар жасау\n• Бюджет жоспарлау\n• Чек-лист жүргізу\n• Таңдаулыны сақтау'
          ),
          style: TextStyle(
            color: themeProvider.getDialogContentColor(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageProvider.getLocalizedText(
                'Понятно',
                'Түсіндім'
              ),
              style: TextStyle(
                color: themeProvider.getDialogButtonTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Показ диалога политики конфиденциальности
  void _showPrivacyDialog(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final themeProvider = context.read<ThemeProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.getDialogColor(),
        title: Text(
          languageProvider.getLocalizedText(
            'Политика конфиденциальности',
            'Құпиялылық саясаты'
          ),
          style: TextStyle(
            color: themeProvider.getDialogTitleColor(),
          ),
        ),
        content: Text(
          languageProvider.getLocalizedText(
            'Мы заботимся о вашей конфиденциальности. Ваши данные хранятся локально на устройстве и не передаются третьим лицам.',
            'Біз сіздің құпиялылығыңызды қорғаймыз. Сіздің деректеріңіз құрылғыда жергілікті түрде сақталады және үшінші тұлғаларға берілмейді.'
          ),
          style: TextStyle(
            color: themeProvider.getDialogContentColor(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageProvider.getLocalizedText(
                'Закрыть',
                'Жабу'
              ),
              style: TextStyle(
                color: themeProvider.getDialogButtonTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Показ диалога условий использования
  void _showTermsDialog(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final themeProvider = context.read<ThemeProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.getDialogColor(),
        title: Text(
          languageProvider.getLocalizedText(
            'Условия использования',
            'Пайдалану шарттары'
          ),
          style: TextStyle(
            color: themeProvider.getDialogTitleColor(),
          ),
        ),
        content: Text(
          languageProvider.getLocalizedText(
            'Используя приложение TravelKZ, вы соглашаетесь с условиями использования. Приложение предоставляется "как есть" без гарантий.',
            'TravelKZ қосымшасын пайдалану арқылы сіз пайдалану шарттарымен келісесіз. Қосымша кепілдіксіз "қалай болса сондай" беріледі.'
          ),
          style: TextStyle(
            color: themeProvider.getDialogContentColor(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageProvider.getLocalizedText(
                'Закрыть',
                'Жабу'
              ),
              style: TextStyle(
                color: themeProvider.getDialogButtonTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Показ диалога обратной связи
  void _showFeedbackDialog(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final themeProvider = context.read<ThemeProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.getDialogColor(),
        title: Text(
          languageProvider.getLocalizedText(
            'Обратная связь',
            'Кері байланыс'
          ),
          style: TextStyle(
            color: themeProvider.getDialogTitleColor(),
          ),
        ),
        content: Text(
          languageProvider.getLocalizedText(
            'Мы ценим ваше мнение! Поделитесь своими предложениями и замечаниями, чтобы мы могли улучшить приложение.',
            'Біз сіздің пікіріңізді бағалаймыз! Қосымшаны жақсарту үшін ұсыныстарыңызбен және пікірлеріңізбен бөлісіңіз.'
          ),
          style: TextStyle(
            color: themeProvider.getDialogContentColor(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageProvider.getLocalizedText(
                'Закрыть',
                'Жабу'
              ),
              style: TextStyle(
                color: themeProvider.getDialogButtonTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
