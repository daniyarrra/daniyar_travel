import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routes_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'create_route_screen.dart';

/// Экран маршрутов путешествий
/// Показывает все созданные маршруты и позволяет создавать новые
class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Инициализируем данные при загрузке экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutesProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final routesProvider = context.watch<RoutesProvider>();
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveRoutes(routesProvider.activeRoutes),
                _buildUpcomingRoutes(routesProvider.upcomingRoutes),
                _buildCompletedRoutes(routesProvider.completedRoutes),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
          'Маршруты',
          'Маршруттар'
        ),
        style: TextStyle(
          color: themeProvider.getTextColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.analytics,
            color: themeProvider.getIconColor(),
          ),
          onPressed: _showStatistics,
        ),
      ],
    );
  }

  /// Создание TabBar
  Widget _buildTabBar() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      color: themeProvider.getAppBarColor(),
      child: TabBar(
        controller: _tabController,
        indicatorColor: themeProvider.getPrimaryColor(),
        labelColor: themeProvider.getTextColor(),
        unselectedLabelColor: themeProvider.getUnselectedTabColor(),
        tabs: [
          Tab(
            text: languageProvider.getLocalizedText(
              'Активные',
              'Белсенді'
            ),
          ),
          Tab(
            text: languageProvider.getLocalizedText(
              'Предстоящие',
              'Алдағы'
            ),
          ),
          Tab(
            text: languageProvider.getLocalizedText(
              'Завершенные',
              'Аяқталған'
            ),
          ),
        ],
      ),
    );
  }

  /// Активные маршруты
  Widget _buildActiveRoutes(List activeRoutes) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    if (activeRoutes.isEmpty) {
      return EmptyState(
        icon: Icons.route,
        title: languageProvider.getLocalizedText(
          'Нет активных маршрутов',
          'Белсенді маршруттар жоқ'
        ),
        subtitle: languageProvider.getLocalizedText(
          'Создайте новый маршрут для начала путешествия',
          'Саяхатты бастау үшін жаңа маршрут жасаңыз'
        ),
        action: CustomButton(
          text: languageProvider.getLocalizedText(
            'Создать маршрут',
            'Маршрут жасау'
          ),
          onPressed: _createNewRoute,
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<RoutesProvider>().loadRoutes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: activeRoutes.length,
        itemBuilder: (context, index) {
          final route = activeRoutes[index];
          return _buildRouteCard(route);
        },
      ),
    );
  }

  /// Предстоящие маршруты
  Widget _buildUpcomingRoutes(List upcomingRoutes) {
    final languageProvider = context.watch<LanguageProvider>();
    
    if (upcomingRoutes.isEmpty) {
      return EmptyState(
        icon: Icons.schedule,
        title: languageProvider.getLocalizedText(
          'Нет предстоящих маршрутов',
          'Алдағы маршруттар жоқ'
        ),
        subtitle: languageProvider.getLocalizedText(
          'Создайте маршрут на будущее',
          'Болашаққа маршрут жасаңыз'
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<RoutesProvider>().loadRoutes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: upcomingRoutes.length,
        itemBuilder: (context, index) {
          final route = upcomingRoutes[index];
          return _buildRouteCard(route);
        },
      ),
    );
  }

  /// Завершенные маршруты
  Widget _buildCompletedRoutes(List completedRoutes) {
    final languageProvider = context.watch<LanguageProvider>();
    
    if (completedRoutes.isEmpty) {
      return EmptyState(
        icon: Icons.check_circle,
        title: languageProvider.getLocalizedText(
          'Нет завершенных маршрутов',
          'Аяқталған маршруттар жоқ'
        ),
        subtitle: languageProvider.getLocalizedText(
          'Завершите свои путешествия, чтобы они появились здесь',
          'Саяхаттарыңызды аяқтаңыз, олар осы жерде пайда болады'
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<RoutesProvider>().loadRoutes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: completedRoutes.length,
        itemBuilder: (context, index) {
          final route = completedRoutes[index];
          return _buildRouteCard(route);
        },
      ),
    );
  }

  /// Карточка маршрута
  Widget _buildRouteCard(route) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: themeProvider.getCardColor(),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: () => _openRouteDetails(route),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      route.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.getTextColor(),
                      ),
                    ),
                  ),
                  _buildRouteStatusChip(route),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${AppHelpers.formatDateShort(route.startDate)} - ${AppHelpers.formatDateShort(route.endDate)}',
                    style: TextStyle(
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${route.places.length} ${languageProvider.getLocalizedText('мест', 'орындар')}',
                    style: TextStyle(
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppHelpers.formatCurrency(route.budget, route.currency),
                    style: TextStyle(
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(route),
            ],
          ),
        ),
      ),
    );
  }

  /// Чип статуса маршрута
  Widget _buildRouteStatusChip(route) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    String statusText;
    Color statusColor;
    
    if (route.isCompleted) {
      statusText = languageProvider.getLocalizedText('Завершен', 'Аяқталды');
      statusColor = themeProvider.getSuccessColor();
    } else if (route.hasStarted) {
      statusText = languageProvider.getLocalizedText('В процессе', 'Жүріп жатыр');
      statusColor = themeProvider.getPrimaryColor();
    } else {
      statusText = languageProvider.getLocalizedText('Запланирован', 'Жоспарланған');
      statusColor = themeProvider.getWarningColor();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Прогресс-бар маршрута
  Widget _buildProgressBar(route) {
    final themeProvider = context.watch<ThemeProvider>();
    final progress = route.getProgress();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Прогресс',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.getSecondaryTextColor(),
              ),
            ),
            Text(
              AppHelpers.formatProgress(progress),
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.getSecondaryTextColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: themeProvider.getProgressBarColor().withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            themeProvider.getProgressBarColor(),
          ),
        ),
      ],
    );
  }

  /// Floating Action Button
  Widget _buildFloatingActionButton() {
    final themeProvider = context.watch<ThemeProvider>();
    
    return FloatingActionButton(
      onPressed: _createNewRoute,
      backgroundColor: themeProvider.getFloatingActionButtonColor(),
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  /// Создание нового маршрута
  void _createNewRoute() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateRouteScreen(),
      ),
    );
  }

  /// Открытие деталей маршрута
  void _openRouteDetails(route) {
    // TODO: Реализовать экран деталей маршрута
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Открытие деталей маршрута: ${route.name}'),
        backgroundColor: context.read<ThemeProvider>().getSnackBarColor(),
      ),
    );
  }

  /// Показ статистики
  void _showStatistics() {
    // TODO: Реализовать экран статистики
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Статистика будет реализована'),
        backgroundColor: context.read<ThemeProvider>().getSnackBarColor(),
      ),
    );
  }
}
