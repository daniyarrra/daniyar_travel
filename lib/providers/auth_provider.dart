import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/postgres_service.dart';

/// Provider для управления аутентификацией пользователей
class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  /// Инициализация: проверка текущей сессии
  void _init() {
    _user = _supabase.auth.currentUser;
    
    // Слушаем изменения статуса авторизации
    _supabase.auth.onAuthStateChange.listen((data) {
      if (_isLocalAuth) return;
      _user = data.session?.user;
      notifyListeners();
    });
  }

  bool _isLocalAuth = false;

  final PostgresService _postgresService = PostgresService();

  /// Вход в систему
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Сначала пробуем подключиться к локальной базе donk (pgAdmin)
      try {
        await _postgresService.connect();
        final pgUser = await _postgresService.login(email, password);
        
        if (pgUser != null) {
          debugPrint('Успешный вход через PostgreSQL (donk)!');
          
          // Создаем локального пользователя (эмуляция Supabase User)
          _user = User(
            id: pgUser['id'].toString(),
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: pgUser['created_at'].toString(),
          );
          
          _isLocalAuth = true;
          _isLoading = false;
          notifyListeners();
          return; // Прерываем выполнение, чтобы не вызывать Supabase
        }
      } catch (pgError) {
        debugPrint('Не удалось войти через локальную БД: $pgError');
      }

      // 2. Стандартный вход через Supabase (ТОЛЬКО если локальный не сработал)
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _user = response.user;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Произошла ошибка при входе';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Регистрация
  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Пробуем зарегистрировать в локальной базе donk
      try {
        await _postgresService.register(email, password);
      } catch (pgError) {
        debugPrint('Не удалось зарегистрировать в локальной БД: $pgError');
        // Продолжаем, даже если локальная БД недоступна
      }

      // 2. Стандартная регистрация в Supabase
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      _user = response.user;
      // Примечание: по умолчанию Supabase может требовать подтверждение Email.
      // Если 'Enable email confirmations' выключено в Supabase, пользователь сразу войдет.
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Произошла ошибка при регистрации';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Выход из системы
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    _isLocalAuth = false;
    notifyListeners();
  }
}
