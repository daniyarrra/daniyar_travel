import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/supabase_config.dart';

// Providers
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/places_provider.dart';
import 'providers/routes_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/checklist_provider.dart';
import 'providers/auth_provider.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/routes_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

// Utils
import 'utils/constants.dart';

/// Главный файл приложения TravelKZ
/// Инициализирует все Provider'ы и настраивает навигацию
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Hive для локального хранения данных
  await Hive.initFlutter();
  
  // Инициализация Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  runApp(const TravelKZApp());
}

class TravelKZApp extends StatelessWidget {
  const TravelKZApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider для управления языком
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        
        // Provider для управления темой
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Provider для управления местами
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
        
        // Provider для управления маршрутами
        ChangeNotifierProvider(create: (_) => RoutesProvider()),
        
        // Provider для управления бюджетом
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        
        // Provider для управления чек-листом
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        
        // Provider для управления аутентификацией
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            
            // Локализация
            locale: Locale(languageProvider.currentLanguage),
            supportedLocales: const [
              Locale('ru', 'RU'),
              Locale('kk', 'KZ'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // Тема
            theme: _buildLightTheme(themeProvider),
            darkTheme: _buildDarkTheme(themeProvider),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            
            // Главный экран
            home: const MainScreen(),
          );
        },
      ),
    );
  }

  /// Создание светлой темы
  ThemeData _buildLightTheme(ThemeProvider themeProvider) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeProvider.getPrimaryColor(),
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeProvider.getAppBarColor(),
        foregroundColor: themeProvider.getTextColor(),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: themeProvider.getCardColor(),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.getButtonColor(),
          foregroundColor: themeProvider.getButtonTextColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: themeProvider.getInputFieldColor(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getInputFieldBorderColor(),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getInputFieldBorderColor(),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getInputFieldFocusColor(),
            width: 2,
          ),
        ),
      ),
    );
  }

  /// Создание темной темы
  ThemeData _buildDarkTheme(ThemeProvider themeProvider) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeProvider.getPrimaryColor(),
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeProvider.getAppBarColor(),
        foregroundColor: themeProvider.getTextColor(),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: themeProvider.getCardColor(),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.getButtonColor(),
          foregroundColor: themeProvider.getButtonTextColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: themeProvider.getInputFieldColor(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getInputFieldBorderColor(),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getInputFieldBorderColor(),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(
            color: themeProvider.getInputFieldFocusColor(),
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Главный экран с BottomNavigationBar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const RoutesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Инициализируем Provider'ы при запуске приложения
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LanguageProvider>().initialize();
      context.read<ThemeProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: themeProvider.getBottomNavigationBarColor(),
        selectedItemColor: themeProvider.getSelectedTabColor(),
        unselectedItemColor: themeProvider.getUnselectedTabColor(),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            activeIcon: const Icon(Icons.home),
            label: languageProvider.getLocalizedText(
              'Главная',
              'Басты'
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: languageProvider.getLocalizedText(
              'Избранное',
              'Таңдаулы'
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.route),
            activeIcon: const Icon(Icons.route),
            label: languageProvider.getLocalizedText(
              'Маршруты',
              'Маршруттар'
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: languageProvider.getLocalizedText(
              'Профиль',
              'Профиль'
            ),
          ),
        ],
      ),
    );
  }
}